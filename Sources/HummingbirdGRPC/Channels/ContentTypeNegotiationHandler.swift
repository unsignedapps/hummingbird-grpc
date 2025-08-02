//===----------------------------------------------------------------------===//
//
// Copyright (c) 2025 Unsigned Apps
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import DequeModule
import HTTPTypes
import Hummingbird
import NIOCore
import NIOHTTP2
import NIOHTTPTypesHTTP2

/// A negotiation handler inspired by NIOSSL's `NIOTypedApplicationProtocolNegotiationHandler`. It should bs used
/// as the first handler inside a NIOHTTP2 pipeline and will read as far as the HTTP2 headers. Once the headers
/// are received, it passes the Content-Type (if any) to the closure supplied during initialisation. You should
/// use this closure to configure the channel pipeline as appropriate.
///
@preconcurrency
public final class ContentTypeNegotiationHandler<NegotiationResult: Sendable>: ChannelInboundHandler, RemovableChannelHandler {

    public typealias InboundIn = HTTP2Frame.FramePayload
    public typealias InboundOut = Any

    public var protocolNegotiationResult: EventLoopFuture<NegotiationResult> {
        self.negotiatedPromise.futureResult
    }

    private var negotiatedPromise: EventLoopPromise<NegotiationResult> {
        precondition(
            self._negotiatedPromise != nil,
            "Tried to access the protocol negotiation result before the handler was added to a pipeline"
        )
        return self._negotiatedPromise!
    }
    private var _negotiatedPromise: EventLoopPromise<NegotiationResult>?

    private let completionHandler: (MediaType?, Channel) -> EventLoopFuture<NegotiationResult>
    private var stateMachine = ProtocolNegotiationHandlerStateMachine<NegotiationResult>()

    /// Create an `ContentTypeNegotiationHandler` with the given completion callback.
    ///
    /// - Parameter contentTypeCompleteHandler: The closure that will be passed the request content type
    ///
    public init(contentTypeCompleteHandler: @escaping (MediaType?, Channel) -> EventLoopFuture<NegotiationResult>) {
        self.completionHandler = contentTypeCompleteHandler
    }

    /// Create an `ContentTypeNegotiationHandler` with the given completion callback.
    ///
    /// - Parameter contentTypeCompleteHandler: The closure that will be passed the request content type
    ///
    public convenience init(contentTypeCompleteHandler: @escaping (MediaType?) -> EventLoopFuture<NegotiationResult>) {
        self.init { result, _ in
            contentTypeCompleteHandler(result)
        }
    }

    public func handlerAdded(context: ChannelHandlerContext) {
        self._negotiatedPromise = context.eventLoop.makePromise()
    }

    public func handlerRemoved(context: ChannelHandlerContext) {
        switch self.stateMachine.handlerRemoved() {
        case .failPromise:
            self.negotiatedPromise.fail(ChannelError.inappropriateOperationForState)

        case .none:
            break
        }
    }

    public func channelRegistered(context: ChannelHandlerContext) {
        context.fireChannelRegistered()
    }

    public func channelUnregistered(context: ChannelHandlerContext) {
        context.fireChannelUnregistered()
    }

    public func channelActive(context: ChannelHandlerContext) {
        context.fireChannelActive()
    }

    public func channelReadComplete(context: ChannelHandlerContext) {
        context.fireChannelReadComplete()
    }

    public func channelWritabilityChanged(context: ChannelHandlerContext) {
        context.fireChannelWritabilityChanged()
    }

    public func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
        context.fireUserInboundEventTriggered(event)
    }

    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        context.fireErrorCaught(error)
    }

    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let payload = unwrapInboundIn(data)
        switch self.stateMachine.channelRead(payload: payload) {
        case .fireChannelRead:
            context.fireChannelRead(data)

        case let .invokeUserClosure(mediaType):
            invokeUserClosure(context: context, result: mediaType)

        case .none:
            break
        }
    }

    public func channelInactive(context: ChannelHandlerContext) {
        self.stateMachine.channelInactive()

        self.negotiatedPromise.fail(ChannelError.outputClosed)
        context.fireChannelInactive()
    }

    private func invokeUserClosure(context: ChannelHandlerContext, result: MediaType?) {
        let switchFuture = self.completionHandler(result, context.channel)
        let loopBoundSelfAndContext = NIOLoopBound((self, context), eventLoop: context.eventLoop)

        switchFuture
            .hop(to: context.eventLoop)
            .whenComplete { result in
                let (`self`, context) = loopBoundSelfAndContext.value
                self.userFutureCompleted(context: context, result: result)
            }
    }

    private func userFutureCompleted(context: ChannelHandlerContext, result: Result<NegotiationResult, Error>) {
        switch self.stateMachine.userFutureCompleted(with: result) {
        case .fireErrorCaughtAndRemoveHandler(let error):
            self.negotiatedPromise.fail(error)
            context.fireErrorCaught(error)
            context.pipeline.syncOperations.removeHandler(self, promise: nil)

        case .fireErrorCaughtAndStartUnbuffering(let error):
            self.negotiatedPromise.fail(error)
            context.fireErrorCaught(error)
            self.unbuffer(context: context)

        case .startUnbuffering(let value):
            self.negotiatedPromise.succeed(value)
            self.unbuffer(context: context)

        case .removeHandler(let value):
            self.negotiatedPromise.succeed(value)
            context.pipeline.syncOperations.removeHandler(self, promise: nil)

        case .none:
            break
        }
    }

    private func unbuffer(context: ChannelHandlerContext) {
        while true {
            switch self.stateMachine.unbuffer() {
            case .fireChannelRead(let data):
                context.fireChannelRead(NIOAny(data))

            case .fireChannelReadCompleteAndRemoveHandler:
                context.fireChannelReadComplete()
                context.pipeline.syncOperations.removeHandler(self, promise: nil)
                return
            }
        }
    }
}

struct ProtocolNegotiationHandlerStateMachine<NegotiationResult> {
    enum State {
        /// The state before we received a TLSUserEvent. We are just forwarding any read at this point.
        case initial
        /// The state after we received a ``TLSUserEvent`` and are waiting for the future of the user to complete.
        case waitingForUser(buffer: Deque<HTTP2Frame.FramePayload>)
        /// The state after the users future finished and we are unbuffering all the reads.
        case unbuffering(buffer: Deque<HTTP2Frame.FramePayload>)
        /// The state once the negotiation is done and we are finished with unbuffering.
        case finished
    }

    private var state = State.initial

    @usableFromInline
    enum HandlerRemovedAction {
        case failPromise
    }

    @inlinable
    mutating func handlerRemoved() -> HandlerRemovedAction? {
        switch self.state {
        case .initial, .waitingForUser, .unbuffering:
            return .failPromise

        case .finished:
            return .none
        }
    }

    @usableFromInline
    enum ChannelReadAction {
        case fireChannelRead
        case invokeUserClosure(MediaType?)
    }

    @inlinable
    mutating func channelRead(payload: HTTP2Frame.FramePayload) -> ChannelReadAction? {
        switch self.state {
        case .initial:
            switch payload {
            case .headers(let headers):
                let contentType = headers.headers.first(name: "content-type")
                let mediaType = contentType.flatMap { MediaType(from: $0) }

                self.state = .waitingForUser(buffer: .init([ payload ]))
                return .invokeUserClosure(mediaType)
            case .windowUpdate:
                return .none
            default:
                return .fireChannelRead
            }

        case .waitingForUser(var buffer):
            buffer.append(payload)
            self.state = .waitingForUser(buffer: buffer)

            return .none

        case .unbuffering(var buffer):
            buffer.append(payload)
            self.state = .unbuffering(buffer: buffer)

            return .none

        case .finished:
            return .fireChannelRead
        }
    }

    @usableFromInline
    enum UserFutureCompletedAction {
        case fireErrorCaughtAndRemoveHandler(Error)
        case fireErrorCaughtAndStartUnbuffering(Error)
        case startUnbuffering(NegotiationResult)
        case removeHandler(NegotiationResult)
    }

    @inlinable
    mutating func userFutureCompleted(with result: Result<NegotiationResult, Error>) -> UserFutureCompletedAction? {
        switch self.state {
        case .initial:
            preconditionFailure("Invalid state \(self.state)")

        case .waitingForUser(let buffer):

            switch result {
            case .success(let value):
                if !buffer.isEmpty {
                    self.state = .unbuffering(buffer: buffer)
                    return .startUnbuffering(value)
                } else {
                    self.state = .finished
                    return .removeHandler(value)
                }

            case .failure(let error):
                if !buffer.isEmpty {
                    self.state = .unbuffering(buffer: buffer)
                    return .fireErrorCaughtAndStartUnbuffering(error)
                } else {
                    self.state = .finished
                    return .fireErrorCaughtAndRemoveHandler(error)
                }
            }

        case .unbuffering:
            preconditionFailure("Invalid state \(self.state)")

        case .finished:
            // It might be that the user closed the channel in his closure. We have to tolerate this.
            return .none
        }
    }

    @usableFromInline
    enum UnbufferAction {
        case fireChannelRead(HTTP2Frame.FramePayload)
        case fireChannelReadCompleteAndRemoveHandler
    }

    @inlinable
    mutating func unbuffer() -> UnbufferAction {
        switch self.state {
        case .initial, .waitingForUser, .finished:
            preconditionFailure("Invalid state \(self.state)")

        case .unbuffering(var buffer):
            if let element = buffer.popFirst() {
                self.state = .unbuffering(buffer: buffer)

                return .fireChannelRead(element)
            } else {
                self.state = .finished

                return .fireChannelReadCompleteAndRemoveHandler
            }
        }
    }

    @inlinable
    mutating func channelInactive() {
        switch self.state {
        case .initial, .unbuffering, .waitingForUser:
            self.state = .finished

        case .finished:
            break
        }
    }
}
