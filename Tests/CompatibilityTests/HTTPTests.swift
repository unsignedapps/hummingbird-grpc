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

import AsyncHTTPClient
import Hummingbird
import HummingbirdGRPC
import NIOSSL
import XCTest

// These tests are designed to ensure we did not destroy basic support
// for HTTP/2 or HTTP/1.1 by building gRPC over the top

final class HTTPTests: XCTestCase {

    func testHttp2Post() async throws {

        // GIVEN an HBApplication with gRPC support
        let app = try makeEchoApplication(port: 8080)

        // AND GIVEN a route on that that responds
        app.router.post("/echo") { request async throws -> String in
            let string = try await request.collatedBodyString()
            return "HTTP Response: \(string)"
        }
        try app.start()
        defer { app.stop() }

        // AND GIVEN a HTTP client
        let client = makeClient(.automatic)
        defer { XCTAssertNoThrow(try client.syncShutdown()) }

        // WHEN we make a request
        // THEN it should succeed
        let response = try await client.post(url: "https://localhost:8080/echo", body: .string("Test HTTP/2 Request!")).get()

        // AND the response should match
        XCTAssertEqual(response.bodyString, "HTTP Response: Test HTTP/2 Request!")

    }

    func testHttp11Post() async throws {

        // GIVEN an HBApplication with gRPC support
        let app = try makeEchoApplication(port: 8081)

        // AND GIVEN a route on that that responds
        app.router.post("/echo") { request async throws -> String in
            let string = try await request.collatedBodyString()
            return "HTTP Response: \(string)"
        }
        try app.start()
        defer { app.stop() }

        // AND GIVEN a HTTP client
        let client = makeClient(.http1Only)
        defer { XCTAssertNoThrow(try client.syncShutdown()) }

        // WHEN we make a request
        // THEN it should succeed
        let response = try await client.post(url: "https://localhost:8081/echo", body: .string("Test HTTP/1.1 Request!")).get()

        // AND the response should match
        XCTAssertEqual(response.bodyString, "HTTP Response: Test HTTP/1.1 Request!")

    }

}


// MARK: - Fixtures

private extension HTTPTests {

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

    func makeClient(_ version: HTTPClient.Configuration.HTTPVersion) -> HTTPClient {
        var tls = TLSConfiguration.makeClientConfiguration()
        tls.trustRoots = .certificates([ SampleCertificate.ca.certificate ])
        tls.certificateVerification = .none

        var configuration = HTTPClient.Configuration(tlsConfiguration: tls)
        configuration.httpVersion = version

        return HTTPClient(eventLoopGroupProvider: .createNew, configuration: configuration)
    }

}

private extension HBRequest {

    func collatedBodyString() async throws -> String {
        let maybeBody = try await collateBody().get().body.buffer
        let body = try XCTUnwrap(maybeBody)
        return try XCTUnwrap(body.getString(at: 0, length: body.readableBytes))
    }

}

private extension HTTPClient.Response {

    var bodyString: String? {
        guard let buffer = body else {
            return nil
        }
        return buffer.getString(at: 0, length: buffer.readableBytes)
    }

}
