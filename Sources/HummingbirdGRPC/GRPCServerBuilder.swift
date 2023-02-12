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
import Hummingbird
import HummingbirdCore
import NIOSSL
import SwiftProtobuf

public extension HBApplication {

    /// A builder type that supports the setup and configuration of grpc-swift support.
    struct GRPCServerBuilder {

        private let application: HBApplication

        fileprivate init(application: HBApplication) {
            self.application = application
        }

        
        // MARK: - Services Providers

        private var serviceProviders: [CallHandlerProvider] {
            get { application.extensions.get(\.gRPC.serviceProviders) ?? [] }
            nonmutating set { application.extensions.set(\.gRPC.serviceProviders, value: newValue) }
        }

        @discardableResult
        public func addServiceProvider(_ provider: CallHandlerProvider) -> GRPCServerBuilder {
            serviceProviders.append(provider)
            return self
        }

        @discardableResult
        public func addServiceProviders(_ providers: [CallHandlerProvider]) -> GRPCServerBuilder {
            serviceProviders.append(contentsOf: providers)
            return self
        }


        // MARK: - Adding Upgrades

        /// Enables support for gRPC channels/codecs to the application.
        ///
        /// gRPC support requires HTTP/2 and TLS so these handlers will be added as well.
        /// Do not add TLS or HTTP/2 using Hummingbird's normal support once gRPC has been enabled
        /// as you will be adding multiple TLS and HTTP/2 handlers and this behaviour is undefined.
        ///
        /// This handler will route any channels that are negotiated as `grpc-exp` using ALPN to `grpc-swift`,
        /// while connections negotiated as `h2` and `http/1.1` will be handled by Hummingbird.
        ///
        /// - Parameters:
        ///   - grpcConfiguration:  A configuration type used to setup the grpc-swift channels/codecs.
        ///   - tlsConfiguration:   A configuration type used to configure TLS for this server.
        ///
        public func addUpgrade(
            configuration: HBHTTPServer.GRPCConfiguration,
            tlsConfiguration: TLSConfiguration
        ) throws {
            try application.server.addGRPCUpgrade(
                services: { [application] in
                    let providers: [CallHandlerProvider]? = application.extensions.get(\.gRPC.serviceProviders)
                    return providers ?? []
                },
                grpcConfiguration: configuration,
                tlsConfiguration: tlsConfiguration,
                logger: application.logger
            )
        }

    }

}

public extension HBApplication {

    /// Access to gRPC configuration options on the application.
    var gRPC: GRPCServerBuilder {
        .init(application: self)
    }

}
