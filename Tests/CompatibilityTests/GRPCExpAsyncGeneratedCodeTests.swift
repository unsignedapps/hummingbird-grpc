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
import HummingbirdGRPC
import NIOCore
import NIOPosix
import NIOSSL
import XCTest

// These tests function as compatibility tests with grpc-swift and its code generator
// by starting a HBApplication with gRPC support, and then using a standard grpc-swift
// client to connect and interact with it.

// These tests exercise grpc-exp protocol support.

final class GRPCExpAsyncGeneratedCodeTests: ServerTestCase {

    func testUnaryCall() async throws {

        // GIVEN an HBApplication with gRPC support
        let app = try await startServer(port: 9001)

        // AND GIVEN a grpc-swift client
        let client = try await makeAsyncGRPCClient(app: app, port: 9001, protocol: .grpcExp)

        // AND GIVEN a promise that the response will be received
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        // WHEN we call the get RPC
        // THEN it should succeed
        let result = try await client.get(.with { $0.text = "Test gRPC Request!" })
        XCTAssertEqual(result.text, "Swift echo get: Test gRPC Request!")

        try await group.shutdownGracefully()
    }

    func testServerStreamingCall() async throws {

        // GIVEN an HBApplication with gRPC support
        let app = try await startServer(port: 9002)

        // AND GIVEN a grpc-swift client
        let client = try await makeAsyncGRPCClient(app: app, port: 9002, protocol: .grpcExp)

        // AND GIVEN a promise that the response will be received
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try group.syncShutdownGracefully())
        }

        // WHEN we call the expand RPC and collect the results
        // THEN it should receive those streaming messages
        XCTAssertNoThrow {
            let messages = try await client.expand(.with { $0.text = "Please Expand." }).collect()

            XCTAssertEqual(messages.count, 2)
            XCTAssertEqual(messages.first?.text, "Swift echo expand (0): Please")
            XCTAssertEqual(messages.last?.text, "Swift echo expand (1): Expand.")
        }

    }

    func testClientStreamingCall() async throws {

        // GIVEN an HBApplication with gRPC support
        let app = try await startServer(port: 9003)

        // AND GIVEN a grpc-swift client
        let client = try await makeAsyncGRPCClient(app: app, port: 9003, protocol: .grpcExp)

        // AND GIVEN a promise that the response will be received
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try group.syncShutdownGracefully())
        }

        // WHEN we call the collect RPC
        // THEN it should receive those messages
        let result = try await client.collect([
            .with { $0.text = "Test" },
            .with { $0.text = "gRPC" },
            .with { $0.text = "Request!" },
        ])

        XCTAssertEqual(result.text, "Swift echo collect: Test gRPC Request!")

    }

    func testBidirectionalStreamingCall() async throws {

        // GIVEN an HBApplication with gRPC support
        let app = try await startServer(port: 9004)

        // AND GIVEN a grpc-swift client
        let client = try await makeAsyncGRPCClient(app: app, port: 9004, protocol: .grpcExp)

        // AND GIVEN a promise that the response will be received
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try group.syncShutdownGracefully())
        }

        // WHEN we call the update RPC
        // THEN it should receive those streaming messages
        let messages = try await client.update([
            .with { $0.text = "First" },
            .with { $0.text = "Second" },
        ])
            .collect()

        XCTAssertEqual(messages.count, 2)
        XCTAssertEqual(messages.first?.text, "Swift echo update (0): First")
        XCTAssertEqual(messages.last?.text, "Swift echo update (1): Second")

    }

}
