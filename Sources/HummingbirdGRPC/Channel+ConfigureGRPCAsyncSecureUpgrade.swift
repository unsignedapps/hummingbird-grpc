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

import NIOCore
import NIOHTTP2
import NIOTLS

extension Channel {

    func configureGRPCAsyncSecureUpgrade<HTTP1Output, HTTP2Output, GRPCOutput>(
        http1ConnectionInitializer: @escaping NIOChannelInitializerWithOutput<HTTP1Output>,
        http2ConnectionInitializer: @escaping NIOChannelInitializerWithOutput<HTTP2Output>,
        grpcConnectionInitializer: @escaping NIOChannelInitializerWithOutput<GRPCOutput>
    ) -> EventLoopFuture<EventLoopFuture<NegotiatedProtocol<HTTP1Output, HTTP2Output, GRPCOutput>>>
    where HTTP1Output: Sendable, HTTP2Output: Sendable, GRPCOutput: Sendable {
        let handler = NIOTypedApplicationProtocolNegotiationHandler<NegotiatedProtocol<HTTP1Output, HTTP2Output, GRPCOutput>>() { result in
            switch result {
            case .negotiated("grpc-exp"):
                // Successful negotiation of GRPC. Let the user configure the pipeline.
                return grpcConnectionInitializer(self).map { output in .grpc(output) }
            case .negotiated("h2"):
                // Successful upgrade to HTTP/2. Let the user configure the pipeline.
                return http2ConnectionInitializer(self).map { output in .http2(output) }
            case .negotiated("http/1.1"), .fallback:
                // Explicit or implicit HTTP/1.1 choice.
                return self.pipeline.configureHTTPServerPipeline()
                    .flatMap { _ in
                        http1ConnectionInitializer(self).map { output in .http1_1(output) }
                    }
            case .negotiated:
                // We negotiated something that isn't HTTP/1.1. This is a bad scene, and is a good indication
                // of a user configuration error. We're going to close the connection directly.
                return self.close().flatMap { self.eventLoop.makeFailedFuture(NIOHTTP2Errors.invalidALPNToken()) }
            }
        }

        return self.pipeline
            .addHandler(handler)
            .flatMap { _ in
                self.pipeline.handler(type: NIOTypedApplicationProtocolNegotiationHandler<NegotiatedProtocol<HTTP1Output, HTTP2Output, GRPCOutput>>.self)
                    .map { handler in
                        handler.protocolNegotiationResult
                    }
            }
    }

}

enum NegotiatedProtocol<HTTP1Output, HTTP2Output, GRPCOutput>: Sendable
where HTTP1Output: Sendable, HTTP2Output: Sendable, GRPCOutput: Sendable {
    /// Protocol negotiation resulted in the connection using HTTP/1.1.
    case http1_1(HTTP1Output)
    /// Protocol negotiation resulted in the connection using HTTP/2.
    case http2(HTTP2Output)
    /// Protocol negotiation resulted in the connection using gRPC.
    case grpc(GRPCOutput)
}
