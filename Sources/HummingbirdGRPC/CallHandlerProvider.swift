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

import GRPC

final class HBCallHandlerProvider: CallHandlerProvider & Sendable {

    // MARK: - Properties

    let serviceName: Substring
    let method: Substring
    let handlerFactory: @Sendable (CallHandlerContext) -> GRPCServerHandlerProtocol


    // MARK: - Initialisation

    init(serviceName: String, method: String, handlerFactory: @escaping @Sendable (CallHandlerContext) -> GRPCServerHandlerProtocol) {
        self.serviceName = serviceName[...]
        self.method = method[...]
        self.handlerFactory = handlerFactory
    }

    
    // MARK: - Call Handler Provider

    func handle(method name: Substring, context: CallHandlerContext) -> GRPCServerHandlerProtocol? {
        guard name == method else {
            return nil
        }
        return handlerFactory(context)
    }

}
