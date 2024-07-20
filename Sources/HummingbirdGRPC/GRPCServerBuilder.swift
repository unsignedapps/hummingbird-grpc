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
import NIOSSL
import SwiftProtobuf

/// A builder type that supports the setup and configuration of grpc-swift support.
public final class GRPCServerBuilder {

    var serviceProviders = [any CallHandlerProvider]()


    // MARK: - Initialsiation

    public init() {
        // Intentionally left blank
    }

    // MARK: - Services Providers

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

}
