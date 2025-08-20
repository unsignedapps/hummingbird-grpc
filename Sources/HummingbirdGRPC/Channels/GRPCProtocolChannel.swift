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

/// Child channel for processing GRPC over the grpc-exp protocol using grpc-swift
public struct GRPCProtocolChannel: ServerChildChannel {

    typealias GRPCConnection = NIOHTTP2Handler.AsyncStreamMultiplexer<Void>
    public struct Value: ServerChildChannelValue {
        let connection: GRPCConnection
        public let channel: Channel
    }

    // MARK: - Properties

    private let serverBuilder: GRPCServerBuilder
    private let grpcConfiguration: HTTPServerBuilder.GRPCConfiguration
    private let logger: Logger

    // MARK: - Channels

    private var grpcServer: HTTP2ToRawGRPCServerCodec {
        HTTP2ToRawGRPCServerCodec(
            servicesByName: serverBuilder.servicesByName(),
            encoding: grpcConfiguration.encoding,
            errorDelegate: grpcConfiguration.errorDelegate,
            normalizeHeaders: grpcConfiguration.normalizeHeaders,
            maximumReceiveMessageLength: grpcConfiguration.maximumReceiveMessageLength,
            logger: logger
        )
    }

    // MARK: - Initialisation

    ///  Initialize HTTP2Channel
    /// - Parameters:
    ///   - configuration: HTTP2 channel configuration
    ///   - responder: Function returning a HTTP response for a HTTP request
    public init(
        serverBuilder: GRPCServerBuilder,
        grpcConfiguration: HTTPServerBuilder.GRPCConfiguration = .init(),
        logger: Logger
    ) {
        self.serverBuilder = serverBuilder
        self.grpcConfiguration = grpcConfiguration
        self.logger = logger
    }

    // MARK: - ServerChildChannel Conformance

    /// Setup child channel for HTTP1 with HTTP2 upgrade
    /// - Parameters:
    ///   - channel: Child channel
    ///   - logger: Logger used during setup
    /// - Returns: Object to process input/output on child channel
    public func setup(channel: Channel, logger: Logger) -> EventLoopFuture<Value> {
        channel.eventLoop.makeCompletedFuture {
            let connection = try channel.pipeline.syncOperations.configureAsyncHTTP2Pipeline(
                mode: .server,
                streamDelegate: nil,
                configuration: .init()
            ) {
                $0.pipeline.addHandler(grpcServer)
            }
            return .init(connection: connection, channel: channel)
        }
    }

    /// handle messages being passed down the channel pipeline
    /// - Parameters:
    ///   - value: Object to process input/output on child channel
    ///   - logger: Logger to use while processing messages
    public func handle(value: Value, logger: Logger) async {
        // Requests are handled by grpc-swift not us
    }
}
