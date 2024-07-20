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

final class GRPCMethodNIOTests: ServerTestCase {

    func testUnaryCall() throws {

        // GIVEN an HBApplication with gRPC support and a route that echos the input
        let app = try startServer(port: 9030, serverBuilder:  {
            $0.onUnary("echo.Echo", "Get", requestType: Echo_EchoRequest.self) { request, context in
                let response = Echo_EchoResponse.with {
                    $0.text = "Swift echo get: " + request.text
                }
                return context.eventLoop.makeSucceededFuture(response)
            }
        })

        // AND GIVEN a grpc-swift client
        let client = makeNIOGRPCClient(app: app, port: 9030)

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

        // GIVEN an HBApplication with gRPC support and a route that expands the input
        let app = try startServer(port: 9031, serverBuilder: {
            $0.onServerStream("echo.Echo", "Expand", requestType: Echo_EchoRequest.self) { request, context in
                let responses = request.text.components(separatedBy: " ").lazy.enumerated().map { i, part in
                    Echo_EchoResponse.with {
                        $0.text = "Swift echo expand (\(i)): \(part)"
                    }
                }
                
                context.sendResponses(responses, promise: nil)
                return context.eventLoop.makeSucceededFuture(.ok)
            }
        })

        // AND GIVEN a grpc-swift client
        let client = makeNIOGRPCClient(app: app, port: 9031)

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

        // GIVEN an HBApplication with gRPC support and a route that collects the input
        let app = try startServer(port: 9032, serverBuilder: {
            $0.onClientStream("echo.Echo", "Collect", requestType: Echo_EchoRequest.self) { context in
                var parts: [String] = []
                return context.eventLoop.makeSucceededFuture({ event in
                    switch event {
                    case let .message(message):
                        parts.append(message.text)
                        
                    case .end:
                        let response = Echo_EchoResponse.with {
                            $0.text = "Swift echo collect: " + parts.joined(separator: " ")
                        }
                        context.responsePromise.succeed(response)
                    }
                })
            }
        })

        // AND GIVEN a grpc-swift client
        let client = makeNIOGRPCClient(app: app, port: 9032)

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

        // GIVEN an HBApplication with gRPC support and a route that echos the input
        let app = try startServer(port: 9033, serverBuilder: {
            $0.onBidirectionalStream("echo.Echo", "Update", requestType: Echo_EchoRequest.self) { context in
                var count = 0
                return context.eventLoop.makeSucceededFuture({ event in
                    switch event {
                    case let .message(message):
                        let response = Echo_EchoResponse.with {
                            $0.text = "Swift echo update (\(count)): \(message.text)"
                        }
                        count += 1
                        context.sendResponse(response, promise: nil)
                        
                    case .end:
                        context.statusPromise.succeed(.ok)
                    }
                })
            }
        })

        // AND GIVEN a grpc-swift client
        let client = makeNIOGRPCClient(app: app, port: 9033)

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

private extension GRPCMethodNIOTests {

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
