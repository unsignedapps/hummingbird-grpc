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

/// GRPC channel initializer
struct GRPCChannelInitializer: HBChannelInitializer {

    // MARK: - Properties

    private let grpcConfiguration: HBHTTPServer.GRPCConfiguration
    private let logger: Logger
    private let services: () -> [CallHandlerProvider]

    
    // MARK: - Initialization

    init(
        configuration: HBHTTPServer.GRPCConfiguration,
        logger: Logger,
        services: @escaping () -> [CallHandlerProvider]
    ) {
        self.grpcConfiguration = configuration
        self.logger = logger
        self.services = services
    }


    // MARK: - HBChannelInitializer Conformance

    func initialize(
        channel: Channel,
        childHandlers: [RemovableChannelHandler],
        configuration: HBHTTPServer.Configuration
    ) -> EventLoopFuture<Void> {
        channel.configureHTTP2Pipeline(mode: .server) { streamChannel in
            let handler = HTTP2ToRawGRPCServerCodec(
                servicesByName: services().reduce(into: [Substring: CallHandlerProvider]()) { result, provider in
                    result[provider.serviceName] = provider
                },
                encoding: grpcConfiguration.encoding,
                errorDelegate: grpcConfiguration.errorDelegate,
                normalizeHeaders: grpcConfiguration.normalizeHeaders,
                maximumReceiveMessageLength: grpcConfiguration.maximumReceiveMessageLength,
                logger: logger
            )
            return streamChannel.pipeline.addHandler(handler)
                .map { _ in }
        }
            .map { _ in }
    }

}
