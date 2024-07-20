//===----------------------------------------------------------------------===//
//
// Copyright (c) 2024 Unsigned Apps
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
import NIOHTTPTypesHTTP1
import NIOHTTPTypesHTTP2
import NIOSSL

public struct GRPCNegotiationChannel: HTTPChannelHandler {

    public struct Value: ServerChildChannelValue {
        let negotiatedProtocol: EventLoopFuture<NegotiatedProtocol<HTTP1Channel.Value, (NIOAsyncChannel<HTTP2Frame, HTTP2Frame>, NIOHTTP2Handler.AsyncStreamMultiplexer<HTTP1Channel.Value>), Void>>
        public let channel: Channel
    }

    // MARK: - Properties

    private let serverBuilder: GRPCServerBuilder
    private let grpcConfiguration: HTTPServerBuilder.GRPCConfiguration
    private let sslContext: NIOSSLContext
    private let additionalChannelHandlers: @Sendable () -> [any RemovableChannelHandler]
    public let responder: HTTPChannelHandler.Responder

    // MARK: - Initialisation

    init(
        serverBuilder: GRPCServerBuilder,
        grpcConfiguration: HTTPServerBuilder.GRPCConfiguration,
        sslContext: NIOSSLContext,
        additionalChannelHandlers: @escaping @Sendable () -> [any RemovableChannelHandler] = { [] },
        responder: @escaping HTTPChannelHandler.Responder
    ) {
        self.serverBuilder = serverBuilder
        self.grpcConfiguration = grpcConfiguration
        self.sslContext = sslContext
        self.additionalChannelHandlers = additionalChannelHandlers
        self.responder = responder
    }

    // MARK: - Initialisation

    public func setup(channel: any Channel, logger: Logger) -> EventLoopFuture<Value> {
        do {
            try channel.pipeline.syncOperations.addHandler(NIOSSLServerHandler(context: sslContext))
        } catch {
            return channel.eventLoop.makeFailedFuture(error)
        }

        return channel.configureGRPCAsyncSecureUpgrade(

            // How it should setup HTTP1 channels.
            // This is basically the same as Hummingbird's HTTP2UpgradeChannel HTTP1 code
            http1ConnectionInitializer: { http1Channel in
                http1Channel.pipeline
                    .addHandlers(
                        [ makeHTTP1ChannelHandler() ]
                            + makeAdditionalChannelHandlers(logger: logger)
                    )
                    .flatMapThrowing {
                        try HTTP1Channel.Value(wrappingChannelSynchronously: http1Channel)
                    }

            },

            // How we should setup HTTP2 channels.
            // Because gRPC can use the h2 or grpc-exp protocols we wrap both types of
            // channels from grpc-swift and Hummingbird and decide which to pass
            // to based on the Content-Type header
            http2ConnectionInitializer: { http2Channel in
                http2Channel.configureAsyncHTTP2Pipeline(mode: .server) { streamChannel in
                    let handler = GRPCUpgradeChannel(
                        grpcChannelHandler: makeGRPCChannelHandler(logger: logger),
                        http2ChannelHandler: makeHTTP2ChannelHandler()
                    )
                    return streamChannel.pipeline.addHandler(handler)
                        .flatMap {
                            streamChannel.pipeline.addHandlers(makeAdditionalChannelHandlers(logger: logger))
                        }
                        .flatMapThrowing {
                            try HTTP1Channel.Value(wrappingChannelSynchronously: streamChannel)
                        }
                }
                .flatMapThrowing { multiplexer in
                    (
                        try NIOAsyncChannel<HTTP2Frame, HTTP2Frame>(wrappingChannelSynchronously: http2Channel),
                        multiplexer
                    )
                }

            },

            // How we should setup gRPC channels.
            // This wraps straight through to grpc-swift.
            grpcConnectionInitializer: { grpcChannel in
                grpcChannel.configureHTTP2Pipeline(mode: .server) { streamChannel in
                    return streamChannel.pipeline
                        .addHandler(makeGRPCChannelHandler(logger: logger))
                        .flatMap {
                            streamChannel.pipeline.addHandlers(makeAdditionalChannelHandlers(logger: logger))
                        }
                }
                .map { _ in }
            }
        )
        .map {
            Value(negotiatedProtocol: $0, channel: channel)
        }
    }

    public func handle(value: Value, logger: Logger) async {
        do {
            let channel = try await value.negotiatedProtocol.get()
            switch channel {
            case .http1_1(let http1):
                await handleHTTP(asyncChannel: http1, logger: logger)

            case .http2((let http2, let multiplexer)):
                do {
                    try await withThrowingDiscardingTaskGroup { group in
                        for try await client in multiplexer.inbound.cancelOnGracefulShutdown() {
                            group.addTask {
                                await handleHTTP(asyncChannel: client, logger: logger)
                            }
                        }
                    }
                } catch {
                    logger.error("Error handling inbound connection for HTTP2 handler: \(error)")
                }
                // have to run this to ensure http2 channel outbound writer is closed
                try await http2.executeThenClose { _, _ in }

            case .grpc:
                // Should not be handled by us, should have been handled by grpc-swift
                logger.error("ATtempted to handle inbound gRPC connection.")
            }
        } catch {
            logger.error("Error getting HTTP2 upgrade negotiated value: \(error)")
        }
    }

    // MARK: - Channel Creation

    private func makeGRPCChannelHandler(logger: Logger) -> some ChannelInboundHandler {
        HTTP2ToRawGRPCServerCodec(
            servicesByName: serverBuilder.servicesByName(),
            encoding: grpcConfiguration.encoding,
            errorDelegate: grpcConfiguration.errorDelegate,
            normalizeHeaders: grpcConfiguration.normalizeHeaders,
            maximumReceiveMessageLength: grpcConfiguration.maximumReceiveMessageLength,
            logger: logger
        )
    }

    private func makeHTTP2ChannelHandler() -> some ChannelInboundHandler {
        HTTP2FramePayloadToHTTPServerCodec()
    }

    private func makeHTTP1ChannelHandler() -> some ChannelInboundHandler {
        HTTP1ToHTTPServerCodec(secure: false)
    }

    private func makeAdditionalChannelHandlers(logger: Logger) -> [any RemovableChannelHandler] {
        additionalChannelHandlers()
            + [ HTTPUserEventHandler(logger: logger) ]
    }

}
