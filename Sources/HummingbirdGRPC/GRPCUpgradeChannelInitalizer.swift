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
import HummingbirdHTTP2
import Logging
import NIOCore
import NIOHTTP1
import NIOHTTP2
import NIOTLS

/// GRPC upgrade channel initializer
struct GRPCUpgradeChannelInitalizer: HBChannelInitializer {

    // MARK: - Properties

    let grpc: GRPCChannelInitializer
    let http1 = HTTP1ChannelInitializer()
    let http2 = HTTP2ChannelInitializer()


    // MARK: - Initialization

    init(
        configuration: HBHTTPServer.GRPCConfiguration,
        logger: Logger,
        services: @escaping () -> [CallHandlerProvider]
    ) {
        self.grpc = GRPCChannelInitializer(configuration: configuration, logger: logger, services: services)
    }


    // MARK: - HBChannelInitializer Conformance

    func initialize(
        channel: Channel,
        childHandlers: [RemovableChannelHandler],
        configuration: HBHTTPServer.Configuration
    ) -> EventLoopFuture<Void> {
        let handler = ApplicationProtocolNegotiationHandler { result in
            switch result {

            case .negotiated("grpc-exp"):
                return grpc.initialize(channel: channel, childHandlers: childHandlers, configuration: configuration)

            case .negotiated("h2"):
                return http2.initialize(channel: channel, childHandlers: childHandlers, configuration: configuration)

            case .negotiated("http/1.1"), .fallback:
                return http1.initialize(channel: channel, childHandlers: childHandlers, configuration: configuration)

            // We negotiated something that isn't supported, which is probably a user configuration error.
            // Let's just close the connection to prevent ending up in an unknown state.
            case .negotiated:
                return channel.close()
                    .flatMap {
                        channel.eventLoop.makeFailedFuture(NIOHTTP2Errors.invalidALPNToken())
                    }
            }
        }

        return channel.pipeline.addHandler(handler)
    }

}

