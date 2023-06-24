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
import NIOSSL

public extension HBHTTPServer {

    /// Add a gRPC secure upgrade handler to the server.
    ///
    /// gRPC support requires HTTP/2 and TLS so these handlers will be added as well.
    /// Do not call `addTLS()` or `addHTTP2Upgrade(tlsConfiguration:)` in conjunction
    /// with this as you will be adding multiple TLS and HTTP/2 handlers.
    ///
    /// This handler will route any channels that are negotiated as `grpc-exp` using ALPN to `grpc-swift`,
    /// while connections negotiated as `h2` and `http/1.1` will be handled by Hummingbird.
    ///
    /// - Parameters:
    ///   - services: A dictionary
    ///   - grpcConfiguration: A configuration type used to setup the grpc-swift channels/codecs.
    ///   - tlsConfiguration: A configuration type used to configure TLS for this server.
    ///
    @discardableResult
    func addGRPCUpgrade(
        services: @escaping () -> [CallHandlerProvider],
        grpcConfiguration: GRPCConfiguration,
        tlsConfiguration: TLSConfiguration,
        logger: Logger
    ) throws -> HBHTTPServer {
        var tlsConfiguration = tlsConfiguration
        tlsConfiguration.applicationProtocols.append("grpc-exp")
        tlsConfiguration.applicationProtocols.append("h2")
        tlsConfiguration.applicationProtocols.append("http/1.1")
        let sslContext = try NIOSSLContext(configuration: tlsConfiguration)

        self.httpChannelInitializer = GRPCALPNChannelInitalizer(
            configuration: grpcConfiguration,
            logger: logger,
            services: services
        )
        return self.addTLSChannelHandler(NIOSSLServerHandler(context: sslContext))
    }

}


// MARK: - Configuration

public extension HBHTTPServer {

    struct GRPCConfiguration {

        /// The compression configuration for requests and responses.
        ///
        /// If compression is enabled for the server it may be disabled for responses on any RPC by
        /// setting `compressionEnabled` to `false` on the context of the call.
        ///
        /// Compression may also be disabled at the message-level for streaming responses (i.e. server
        /// streaming and bidirectional streaming RPCs) by passing setting `compression` to `.disabled`
        /// in `sendResponse(_:compression)`.
        ///
        /// Defaults to `.disabled`.
        ///
        public var encoding: ServerMessageEncoding

        /// An error delegate which is called when errors are caught. Defaults to `nil`.
        public var errorDelegate: ServerErrorDelegate?

        /// Whether to allow grpc-swift to normalize the HTTP/2 headers. Defaults to `true`.
        public var normalizeHeaders: Bool

        /// The maximum size in bytes of a message which may be received from a client. Defaults to 4MB.
        public var maximumReceiveMessageLength: Int

        /// Creates a GRPCConfiguration type used to configure grpc-swift's handlers.
        ///
        /// - Parameters:
        ///   - encoding: The compression configuration for requests and responses. Defaults to `.disabled`.
        ///   - errorDelegate: An error delegate which is called when errors are caught. Defaults to `nil`.
        ///   - normalizeHeaders: Whether to allow grpc-swift to normalize the HTTP/2 headers. Defaults to `true`.
        ///   - maximumReceiveMessageLength: The maximum size in bytes of a message which may be received from a client. Defaults to 4MB.
        ///
        public init(
            encoding: ServerMessageEncoding = .disabled,
            errorDelegate: ServerErrorDelegate? = nil,
            normalizeHeaders: Bool = true,
            maximumReceiveMessageLength: Int = 4 * 1024 * 1024
        ) {
            self.encoding = encoding
            self.errorDelegate = errorDelegate
            self.normalizeHeaders = normalizeHeaders
            self.maximumReceiveMessageLength = maximumReceiveMessageLength
        }

    }

}
