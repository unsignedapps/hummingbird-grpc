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

@preconcurrency import GRPC
import HummingbirdCore
import Logging
import NIOSSL

public extension HTTPServerBuilder {

    /// Build HTTP Channel with gRPC, HTTP2 and HTTP/1.1
    static func grpc(
        serverBuilder: GRPCServerBuilder,
        grpcConfiguration: GRPCConfiguration = .init(),
        tlsConfiguration: TLSConfiguration
    ) throws -> HTTPServerBuilder {
        var tlsConfiguration = tlsConfiguration
        tlsConfiguration.applicationProtocols.append("grpc-exp")
        tlsConfiguration.applicationProtocols.append("h2")
        tlsConfiguration.applicationProtocols.append("http/1.1")
        let sslContext = try NIOSSLContext(configuration: tlsConfiguration)

        return .init { responder in
            GRPCNegotiationChannel(
                services: { serverBuilder.serviceProviders },
                grpcConfiguration: grpcConfiguration,
                sslContext: sslContext,
                responder: responder
            )
        }
    }
}


// MARK: - Configuration

public extension HTTPServerBuilder {

    struct GRPCConfiguration: Sendable {

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
