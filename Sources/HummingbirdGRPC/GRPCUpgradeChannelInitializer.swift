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

/// GRPC upgrade channel initialiser
struct GRPCUpgradeChannelInitializer: HBChannelInitializer {

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
            let handler = GRPCUpgradeChannel(grpcConfiguration: grpcConfiguration, logger: logger, services: services)
            return streamChannel.pipeline.addHandler(handler)
                .flatMap { _ in
                    streamChannel.pipeline.addHandlers(childHandlers)
                }
                .map { _ in }
        }
            .map { _ in }
    }

}
