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

import GRPC
import HTTPTypes
import HummingbirdCore
import HummingbirdHTTP2
import Logging
import NIOCore
import NIOHTTP1
import NIOHTTP2
import NIOHTTPTypesHTTP1
import NIOSSL
import NIOTLS

/// Child channel for processing HTTP1 with the option of upgrading to HTTP2 and GRPC via ALPN.
///
/// This is heavily based off Hummingbird 2's HTTPUpgradeChannel.
///
/// This uses NIOSSL's ALPN negoitation handler to determine the application protocol in use
/// and fowards to the underlying channels as best we can.
///
/// - For HTTP1 it is forwarded to Hummingbird's `HTTP1Channel` to be handled.
/// - For GRPC-EXP it is forwarded to grpc-swift to be handled (via `GRPCProtocolChannel`)
/// - For HTTP2 it is delegated to our `GRPCHTTP2Channel` for further negotiation.
///
/// `GRPCHTTP2Channel` looks at the incoming Content-Type HTTP2 header. If it is "application/grpc"
/// it will forward the connection to grpc-swift, otherwise it is forwarded to Hummingbird's `HTTP2Channel`.
///
public struct GRPCNegotiationChannel: HTTPChannelHandler {

    public struct Value: ServerChildChannelValue {
        let negotiatedHTTPVersion: EventLoopFuture<
            NegotiatedProtocol<
                HTTP1Channel.Value,
                GRPCHTTP2Channel.Value,
                GRPCProtocolChannel.Value
            >
        >
        public let channel: Channel
    }

    private let sslContext: NIOSSLContext
    public var responder: Responder {
        http1.responder
    }

    // MARK: - Channels

    private let http1: HTTP1Channel
    private let http2: GRPCHTTP2Channel
    private let bleh: HTTP2Channel
    private let grpc: GRPCProtocolChannel

    // MARK: - Initialisation

    init(
        serverBuilder: GRPCServerBuilder,
        grpcConfiguration: HTTPServerBuilder.GRPCConfiguration,
        http2Configuration: HTTP2ChannelConfiguration,
        sslContext: NIOSSLContext,
        responder: @escaping HTTPChannelHandler.Responder,
        logger: Logger
    ) {
        self.sslContext = sslContext
        self.http1 = HTTP1Channel(responder: responder, configuration: http2Configuration.streamConfiguration)
        self.http2 = GRPCHTTP2Channel(
            serverBuilder: serverBuilder,
            grpcConfiguration: grpcConfiguration,
            http2Configuration: http2Configuration,
            responder: responder,
            logger: logger
        )
        self.grpc = GRPCProtocolChannel(serverBuilder: serverBuilder, grpcConfiguration: grpcConfiguration, logger: logger)
        self.bleh = HTTP2Channel(responder: responder, configuration: http2Configuration)
    }

    /// Setup child channel for HTTP1 with HTTP2 + GRPC upgrades
    ///
    /// - Parameters:
    ///   - channel: Child channel
    ///   - logger: Logger used during setup
    ///
    /// - Returns: Object to process input/output on child channel
    ///
    public func setup(channel: Channel, logger: Logger) -> EventLoopFuture<Value> {
        do {
            try channel.pipeline.syncOperations.addHandler(NIOSSLServerHandler(context: sslContext))
        } catch {
            return channel.eventLoop.makeFailedFuture(error)
        }

        return channel.configureGRPCAsyncSecureUpgrade { channel in
            http1.setup(channel: channel, logger: logger)

        } http2ConnectionInitializer: { channel in
            http2.setup(channel: channel, logger: logger)

        } grpcConnectionInitializer: { channel in
            grpc.setup(channel: channel, logger: logger)
        }
        .map {
            .init(negotiatedHTTPVersion: $0, channel: channel)
        }
    }

    /// handle messages being passed down the channel pipeline
    ///
    /// - Parameters:
    ///   - value: Object to process input/output on child channel
    ///   - logger: Logger to use while processing messages
    ///
    public func handle(value: Value, logger: Logger) async {
        do {
            let channel = try await value.negotiatedHTTPVersion.get()
            switch channel {
            case .http1_1(let http1):
                await self.http1.handle(value: http1, logger: logger)
            case .http2(let http2):
                await self.http2.handle(value: http2, logger: logger)
            case .grpc:
                // Should not be handled by us, should have been handled by grpc-swift
                logger.error("ATtempted to handle inbound gRPC connection.")
            }
        } catch {
            logger.debug("Error getting HTTP2 upgrade negotiated value: \(error)")
        }
    }

}
