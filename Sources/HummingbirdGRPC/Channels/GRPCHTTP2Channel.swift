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

@preconcurrency import GRPC
import HTTPTypes
import HummingbirdCore
import HummingbirdHTTP2
import Logging
import NIOCore
import NIOHTTP2
import NIOHTTPTypesHTTP2
import NIOSSL

/// Child channel for processing GRPC over HTTP2 using grpc-swift
///
/// We use a ``ContentTypeNegotiationHandler`` to determine the content-type,
/// and pass it through to the appropriate child channel.
///
/// - For `application/grpc` it will be passed to grpc-swift
/// - For everything else it will be passed to (a copy of) Hummingbird's `HTTP2StreamChannel`
///
public struct GRPCHTTP2Channel: ServerChildChannel {

    typealias Connection = NIOHTTP2Handler.AsyncStreamMultiplexer<EventLoopFuture<ContentTypeProtocol<HTTP2StreamChannel.Value, Void>>>
    public struct Value: ServerChildChannelValue {
        let connection: Connection
        public let channel: Channel
    }

    private let http2StreamChannel: HTTP2StreamChannel
    private let http2Configuration: HTTP2ChannelConfiguration
    private let grpcServer: HTTP2ToRawGRPCServerCodec

    ///  Initialize HTTP2Channel
    /// - Parameters:
    ///   - configuration: HTTP2 channel configuration
    ///   - responder: Function returning a HTTP response for a HTTP request
    public init(
        serverBuilder: GRPCServerBuilder,
        grpcConfiguration: HTTPServerBuilder.GRPCConfiguration = .init(),
        http2Configuration: HTTP2ChannelConfiguration,
        responder: @escaping HTTPChannelHandler.Responder,
        logger: Logger
    ) {
        self.http2Configuration = http2Configuration
        self.http2StreamChannel = HTTP2StreamChannel(responder: responder, configuration: http2Configuration.streamConfiguration)
        self.grpcServer = HTTP2ToRawGRPCServerCodec(
            servicesByName: serverBuilder.servicesByName(),
            encoding: grpcConfiguration.encoding,
            errorDelegate: grpcConfiguration.errorDelegate,
            normalizeHeaders: grpcConfiguration.normalizeHeaders,
            maximumReceiveMessageLength: grpcConfiguration.maximumReceiveMessageLength,
            logger: logger
        )
    }

    /// Setup child channel for HTTP1 with HTTP2 upgrade
    /// - Parameters:
    ///   - channel: Child channel
    ///   - logger: Logger used during setup
    /// - Returns: Object to process input/output on child channel
    public func setup(channel: Channel, logger: Logger) -> EventLoopFuture<Value> {
        let connectionManager = HTTP2ServerConnectionManager(
            eventLoop: channel.eventLoop,
            idleTimeout: http2Configuration.idleTimeout,
            maxAgeTimeout: http2Configuration.maxAgeTimeout,
            gracefulCloseTimeout: http2Configuration.gracefulCloseTimeout
        )
        return channel.configureAsyncHTTP2Pipeline(
            mode: .server,
            streamDelegate: connectionManager.streamDelegate,
            configuration: .init()
        ) { childChannel in
            let handler = ContentTypeNegotiationHandler<ContentTypeProtocol<HTTP2StreamChannel.Value, Void>> { mediaType in
                if mediaType?.isType(.applicationGRPC) == true {
                    return childChannel.pipeline.addHandler(grpcServer)
                        .map { .grpc(()) }
                } else {
                    return http2StreamChannel.setup(channel: childChannel, logger: logger)
                        .map { .http2($0) }
                }
            }
            return childChannel.pipeline.addHandler(handler)
                .flatMap { _ in
                    childChannel.pipeline.handler(type: ContentTypeNegotiationHandler<ContentTypeProtocol<HTTP2StreamChannel.Value, Void>>.self)
                        .map { $0.protocolNegotiationResult }
                }
        }
        .flatMap { connection in
            channel.pipeline.addHandler(connectionManager)
                .map { _ in
                    .init(connection: connection, channel: channel)
                }
        }
    }

    /// handle messages being passed down the channel pipeline
    /// - Parameters:
    ///   - value: Object to process input/output on child channel
    ///   - logger: Logger to use while processing messages
    public func handle(value: Value, logger: Logger) async {
        do {
            try await withThrowingDiscardingTaskGroup { group in
                for try await negotiated in value.connection.inbound {
                    switch try await negotiated.get() {
                    case let .http2(client):
                        group.addTask {
                            await self.http2StreamChannel.handle(value: client, logger: logger)
                        }
                    case .grpc:
                        // We do not handle gRPC here. It should be handled by the gRPC server above
                        break
                    }
                }
            }
        } catch {
            logger.debug("Error handling inbound connection for HTTP2 handler: \(error)")
        }
    }
}

/// The final protocol that was negotiated
enum ContentTypeProtocol<HTTP2Output, GRPCOutput>: Sendable
where HTTP2Output: Sendable, GRPCOutput: Sendable {
    /// Protocol negotiation resulted in the connection using HTTP/2.
    case http2(HTTP2Output)
    /// Protocol negotiation resulted in the connection using gRPC.
    case grpc(GRPCOutput)
}
