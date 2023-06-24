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

final class GRPCMethodAsyncTests: XCTestCase {

    func testUnaryCall() async throws {

        // GIVEN an HBApplication with gRPC support and a route that echos the input
        let app = try makeEchoApplication(port: 9010)
        app.gRPC.onUnary("echo.Echo", "Get", requestType: Echo_EchoRequest.self) { request, context async in
            Echo_EchoResponse.with {
                $0.text = "Swift echo get: " + request.text
            }
        }

        try app.start()
        defer { app.stop() }

        // AND GIVEN a grpc-swift client
        let client = makeEchoClient(app: app)

        // AND GIVEN a promise that the response will be received
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try group.syncShutdownGracefully())
        }

        // WHEN we call the get RPC
        // THEN it should succeed
        let result = try await client.get(.with { $0.text = "Test gRPC Request!" })
        XCTAssertEqual(result.text, "Swift echo get: Test gRPC Request!")

    }

    func testServerStreamingCall() async throws {

        // GIVEN an HBApplication with gRPC support and a route that expands the input
        let app = try makeEchoApplication(port: 9011)
        app.gRPC.onServerStream("echo.Echo", "Expand", requestType: Echo_EchoRequest.self) { request, responseStream, _ async throws in
            for (i, part) in request.text.components(separatedBy: " ").lazy.enumerated() {
                try await responseStream.send(Echo_EchoResponse.with { $0.text = "Swift echo expand (\(i)): \(part)" })
            }
        }

        try app.start()
        defer { app.stop() }

        // AND GIVEN a grpc-swift client
        let client = makeEchoClient(app: app)

        // AND GIVEN a promise that the response will be received
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try group.syncShutdownGracefully())
        }

        // WHEN we call the expand RPC and collect the results
        // THEN it should receive those streaming messages
        let messages = try await client.expand(.with { $0.text = "Please Expand." }).collect()

        XCTAssertEqual(messages.count, 2)
        XCTAssertEqual(messages.first?.text, "Swift echo expand (0): Please")
        XCTAssertEqual(messages.last?.text, "Swift echo expand (1): Expand.")

    }

    func testClientStreamingCall() async throws {

        // GIVEN an HBApplication with gRPC support and a route that collects the input
        let app = try makeEchoApplication(port: 9012)
        app.gRPC.onClientStream("echo.Echo", "Collect", requestType: Echo_EchoRequest.self) { requestStream, context async throws in
            let text = try await requestStream.reduce(into: "Swift echo collect:") { result, request in
              result += " \(request.text)"
            }

            return Echo_EchoResponse.with { $0.text = text }
        }

        try app.start()
        defer { app.stop() }

        // AND GIVEN a grpc-swift client
        let client = makeEchoClient(app: app)

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

        // GIVEN an HBApplication with gRPC support and a route that echos the input
        let app = try makeEchoApplication(port: 9013)
        app.gRPC.onBidirectionalStream("echo.Echo", "Update", requestType: Echo_EchoRequest.self) { requestStream, responseStream, _ async throws in
            var counter = 0
            for try await request in requestStream {
                let text = "Swift echo update (\(counter)): \(request.text)"
                try await responseStream.send(Echo_EchoResponse.with { $0.text = text })
                counter += 1
            }
        }

        try app.start()
        defer { app.stop() }

        // AND GIVEN a grpc-swift client
        let client = makeEchoClient(app: app)

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

// MARK: - Fixtures

private extension GRPCMethodAsyncTests {

    func makeEchoApplication(port: Int) throws -> HBApplication {
        let app = HBApplication(configuration: .init(address: .hostname(port: port)))

        try app.gRPC.addUpgrade(
            configuration: .init(),
            tlsConfiguration: .makeServerConfiguration(
                certificateChain: [
                    .certificate(SampleCertificate.server.certificate),
                ],
                privateKey: .privateKey(SamplePrivateKey.server)
            )
        )
        return app
    }

    func makeEchoClient(app: HBApplication) -> Echo_EchoAsyncClient {
        let channel = ClientConnection.usingPlatformAppropriateTLS(for: app.eventLoopGroup)
            .withTLS(trustRoots: .certificates([
                SampleCertificate.ca.certificate,
            ]))
            .withTLS(certificateVerification: .fullVerification)
            .connect(host: "localhost", port: app.configuration.address.port ?? 8080)
        return Echo_EchoAsyncClient(channel: channel)
    }

}
