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

extension AsyncSequence {

    func collect() async throws -> [Element] {
        try await reduce(into: [Element](), { $0.append($1) })
    }

}
