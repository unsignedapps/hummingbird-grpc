//===----------------------------------------------------------------------===//
//
// Copyright (c) 2023 Unsigned Apps
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import GRPC
import HummingbirdCore
import Logging
import NIOCore
import NIOHTTP1
import NIOHTTP2

final class GRPCUpgradeChannel: ChannelDuplexHandler {

    typealias InboundIn = HTTP2Frame.FramePayload
    typealias InboundOut = Never

    typealias OutboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTP2Frame.FramePayload

    enum State {
        case notConfigured
        case configured(any ChannelInboundHandler)
    }

    // MARK: - Properties

    private let grpcChannelHandler: any ChannelInboundHandler
    private let http2ChannelHandler: any ChannelInboundHandler

    private var state = State.notConfigured

    // MARK: - Initialisation

    init(
        grpcChannelHandler: some ChannelInboundHandler,
        http2ChannelHandler: some ChannelInboundHandler
    ) {
        self.grpcChannelHandler = grpcChannelHandler
        self.http2ChannelHandler = http2ChannelHandler
    }


    // MARK: - Handler

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        switch state {
        case .configured(let handler):
            handler.channelRead(context: context, data: data)

        case .notConfigured:
            let payload = self.unwrapInboundIn(data)

            switch payload {
            case let .headers(headers):
                if let contentType = headers.headers["content-type"].first, contentType == "application/grpc" {
                    state = .configured(grpcChannelHandler)
                    grpcChannelHandler.handlerAdded(context: context)
                    grpcChannelHandler.channelRead(context: context, data: data)

                } else {
                    state = .configured(http2ChannelHandler)
                    http2ChannelHandler.handlerAdded(context: context)
                    http2ChannelHandler.channelRead(context: context, data: data)
                }

            default:
                fatalError()
            }
        }
    }

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        // If our configured channel handler also does outbound let it do its thing
        if case .configured(let inbound) = state, let outbound = inbound as? any ChannelOutboundHandler {
            outbound.write(context: context, data: data, promise: promise)

            // Otherwise we just passthrough per the default implementation
        } else {
            context.write(data, promise: promise)
        }
    }


    // MARK: - Passthrough Implementations (Inbound)

    func channelRegistered(context: ChannelHandlerContext) {
        guard case .configured(let handler) = state else {
            context.fireChannelRegistered()
            return
        }
        handler.channelRegistered(context: context)
    }

    func channelUnregistered(context: ChannelHandlerContext) {
        guard case .configured(let handler) = state else {
            context.fireChannelUnregistered()
            return
        }
        handler.channelUnregistered(context: context)
    }

    func channelActive(context: ChannelHandlerContext) {
        guard case .configured(let handler) = state else {
            context.fireChannelActive()
            return
        }
        handler.channelActive(context: context)
    }

    func channelInactive(context: ChannelHandlerContext) {
        guard case .configured(let handler) = state else {
            context.fireChannelInactive()
            return
        }
        handler.channelInactive(context: context)
    }

    func channelReadComplete(context: ChannelHandlerContext) {
        guard case .configured(let handler) = state else {
            context.fireChannelReadComplete()
            return
        }
        handler.channelReadComplete(context: context)
    }

    func channelWritabilityChanged(context: ChannelHandlerContext) {
        guard case .configured(let handler) = state else {
            context.fireChannelWritabilityChanged()
            return
        }
        handler.channelWritabilityChanged(context: context)
    }

    func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
        guard case .configured(let handler) = state else {
            context.fireUserInboundEventTriggered(event)
            return
        }
        handler.userInboundEventTriggered(context: context, event: event)
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        guard case .configured(let handler) = state else {
            context.fireErrorCaught(error)
            return
        }
        handler.errorCaught(context: context, error: error)
    }


    // MARK: - Passthrough Implementations (Outbound)

    func register(context: ChannelHandlerContext, promise: EventLoopPromise<Void>?) {
        guard case .configured(let inbound) = state, let outbound = inbound as? any ChannelOutboundHandler else {
            context.register(promise: promise)
            return
        }
        outbound.register(context: context, promise: promise)
    }

    func bind(context: ChannelHandlerContext, to: SocketAddress, promise: EventLoopPromise<Void>?) {
        guard case .configured(let inbound) = state, let outbound = inbound as? any ChannelOutboundHandler else {
            context.bind(to: to, promise: promise)
            return
        }
        outbound.bind(context: context, to: to, promise: promise)
    }

    func connect(context: ChannelHandlerContext, to: SocketAddress, promise: EventLoopPromise<Void>?) {
        guard case .configured(let inbound) = state, let outbound = inbound as? any ChannelOutboundHandler else {
            context.connect(to: to, promise: promise)
            return
        }
        outbound.connect(context: context, to: to, promise: promise)
    }

    func flush(context: ChannelHandlerContext) {
        guard case .configured(let inbound) = state, let outbound = inbound as? any ChannelOutboundHandler else {
            context.flush()
            return
        }
        outbound.flush(context: context)
    }

    func read(context: ChannelHandlerContext) {
        guard case .configured(let inbound) = state, let outbound = inbound as? any ChannelOutboundHandler else {
            context.read()
            return
        }
        outbound.read(context: context)
    }

    func close(context: ChannelHandlerContext, mode: CloseMode, promise: EventLoopPromise<Void>?) {
        guard case .configured(let inbound) = state, let outbound = inbound as? any ChannelOutboundHandler else {
            context.close(mode: mode, promise: promise)
            return
        }
        outbound.close(context: context, mode: mode, promise: promise)
    }

    func triggerUserOutboundEvent(context: ChannelHandlerContext, event: Any, promise: EventLoopPromise<Void>?) {
        guard case .configured(let inbound) = state, let outbound = inbound as? any ChannelOutboundHandler else {
            context.triggerUserOutboundEvent(event, promise: promise)
            return
        }
        outbound.triggerUserOutboundEvent(context: context, event: event, promise: promise)
    }

}
