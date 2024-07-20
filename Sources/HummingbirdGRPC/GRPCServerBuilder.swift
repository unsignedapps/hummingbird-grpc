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
import HummingbirdHTTP2
import NIOConcurrencyHelpers
import NIOSSL
import SwiftProtobuf

/// A builder type that supports the setup and configuration of grpc-swift support.
public final class GRPCServerBuilder: Sendable {

    public typealias SendableCallHandlerProvider = CallHandlerProvider & Sendable

    let serviceProviders = NIOLockedValueBox([any SendableCallHandlerProvider]())


    // MARK: - Initialsiation

    public init() {
        // Intentionally left blank
    }

    // MARK: - Services Providers

    @discardableResult
    public func addServiceProvider(_ provider: any SendableCallHandlerProvider) -> GRPCServerBuilder {
        serviceProviders.withLockedValue {
            $0.append(provider)
        }
        return self
    }

    @discardableResult
    public func addServiceProviders(_ providers: [any SendableCallHandlerProvider]) -> GRPCServerBuilder {
        serviceProviders.withLockedValue {
            $0.append(contentsOf: providers)
        }
        return self
    }

    public func servicesByName() -> [Substring: CallHandlerProvider] {
        serviceProviders.withLockedValue {
            $0.reduce(into: [Substring: CallHandlerProvider]()) { result, provider in
                result[provider.serviceName] = provider
            }
        }
    }

}
