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

final class GRPCNIOGeneratedCodeTests: ServerTestCase {

    func testUnaryCall() throws {

        // GIVEN an HBApplication with gRPC support
        let app = try startServer(port: 9020)

        // AND GIVEN a grpc-swift client
        let client = makeNIOGRPCClient(app: app, port: 9020)

        // AND GIVEN a promise that the response will be received
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try group.syncShutdownGracefully())
        }
        var promise = TimeoutPromise<Echo_EchoResponse>(count: 1, eventLoop: group.next(), timeout: .seconds(5))

        // WHEN we call the get RPC
        client.get(.with { $0.text = "Test gRPC Request!" })
            .response
            .whenComplete { result in
                switch result {
                case let .success(response):        promise.succeed(response)
                case let .failure(error):           promise.fail(error)
                }
            }

        // THEN it should succeed
        let result = try promise.wait()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.text, "Swift echo get: Test gRPC Request!")

    }

    func testServerStreamingCall() throws {

        // GIVEN an HBApplication with gRPC support
        let app = try startServer(port: 9021)

        // AND GIVEN a grpc-swift client
        let client = makeNIOGRPCClient(app: app, port: 9021)

        // AND GIVEN a promise that the response will be received
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try group.syncShutdownGracefully())
        }
        var receivedMessages = TimeoutPromise<Echo_EchoResponse>(count: 2, eventLoop: group.next(), timeout: .seconds(5))
        var completed = TimeoutPromise<GRPCStatus>(count: 1, eventLoop: group.next(), timeout: .seconds(5))

        // WHEN we call the expand RPC and collect the results
        client.expand(.with { $0.text = "Please Expand." }) {
            receivedMessages.succeed($0)
        }
            .status
            .whenComplete { result in
                switch result {
                case let .success(status):          completed.succeed(status)
                case let .failure(error):           completed.fail(error)
                }
            }

        // THEN it should receive those streaming messages
        let messages = try receivedMessages.wait()
        XCTAssertEqual(messages.count, 2)
        XCTAssertEqual(messages.first?.text, "Swift echo expand (0): Please")
        XCTAssertEqual(messages.last?.text, "Swift echo expand (1): Expand.")

        // AND succeed
        let status = try completed.wait()
        XCTAssertEqual(status.count, 1)
        XCTAssertEqual(status.first?.code, .ok)

    }

    func testClientStreamingCall() throws {

        // GIVEN an HBApplication with gRPC support
        let app = try startServer(port: 9022)

        // AND GIVEN a grpc-swift client
        let client = makeNIOGRPCClient(app: app, port: 9022)

        // AND GIVEN a promise that the response will be received
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try group.syncShutdownGracefully())
        }
        var promise = TimeoutPromise<Echo_EchoResponse>(count: 1, eventLoop: group.next(), timeout: .seconds(5))

        // AND GIVEN a call to the collect RPC
        let call = client.collect()

        // AND GIVEN we listen for the status
        call
            .response
            .whenComplete { result in
                switch result {
                case let .success(response):        promise.succeed(response)
                case let .failure(error):           promise.fail(error)
                }
            }

        // WHEN we send three messages and close the connection
        call.sendMessage(.with { $0.text = "Test" }, promise: nil)
        call.sendMessage(.with { $0.text = "gRPC" }, promise: nil)
        call.sendMessage(.with { $0.text = "Request!" }, promise: nil)
        call.sendEnd(promise: nil)

        // THEN it should receive those messages
        let result = try promise.wait()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.text, "Swift echo collect: Test gRPC Request!")

    }

    func testBidirectionalStreamingCall() throws {

        // GIVEN an HBApplication with gRPC support
        let app = try startServer(port: 9023)

        // AND GIVEN a grpc-swift client
        let client = makeNIOGRPCClient(app: app, port: 9023)

        // AND GIVEN a promise that the response will be received
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try group.syncShutdownGracefully())
        }
        var receivedMessages = TimeoutPromise<Echo_EchoResponse>(count: 2, eventLoop: group.next(), timeout: .seconds(5))
        var completed = TimeoutPromise<GRPCStatus>(count: 1, eventLoop: group.next(), timeout: .seconds(5))

        // AND GIVEN a call to the update RPC
        let call = client.update {
            receivedMessages.succeed($0)
        }

        // AND GIVEN that we listen for the status of that call
        call
            .status
            .whenComplete { result in
                switch result {
                case let .success(status):          completed.succeed(status)
                case let .failure(error):           completed.fail(error)
                }
            }

        // WHEN we send a pair of messages and close the call
        call.sendMessage(.with { $0.text = "First" }, promise: nil)
        call.sendMessage(.with { $0.text = "Second" }, promise: nil)
        call.sendEnd(promise: nil)

        // THEN it should receive those streaming messages
        let messages = try receivedMessages.wait()
        XCTAssertEqual(messages.count, 2)
        XCTAssertEqual(messages.first?.text, "Swift echo update (0): First")
        XCTAssertEqual(messages.last?.text, "Swift echo update (1): Second")

        // AND succeed
        let status = try completed.wait()
        XCTAssertEqual(status.count, 1)
        XCTAssertEqual(status.first?.code, .ok)

    }

}

// MARK: - Fixtures

private extension GRPCNIOGeneratedCodeTests {

    struct TimeoutPromise<Value> {
        let task: Scheduled<Void>
        let promise: EventLoopPromise<[Value]>

        let count: Int
        var values = [Value]()

        init(count: Int, eventLoop: EventLoop, timeout: TimeAmount) {
            self.count = count
            let promise = eventLoop.makePromise(of: [Value].self)
            self.promise = promise
            self.task = eventLoop.scheduleTask(in: timeout) { promise.fail(ChannelError.connectTimeout(timeout)) }
        }

        mutating func succeed(_ value: Value) {
            values.append(value)
            if values.count >= count {
                promise.succeed(values)
            }
        }

        func fail(_ error: Error) {
            promise.fail(error)
        }

        func wait() throws -> [Value] {
            let result = try promise.futureResult.wait()
            task.cancel()
            return result
        }
    }

}
