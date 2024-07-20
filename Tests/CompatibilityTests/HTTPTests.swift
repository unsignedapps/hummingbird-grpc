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

final class HTTPTests: ServerTestCase {

    func testHttp2Post() async throws {

        // GIVEN an HBApplication with gRPC support
        try startServer(port: 8081) {

            // AND GIVEN a route on that that responds
            $0.post("/echo") { request, context async throws -> String in
                var request = request
                let string = try await request.collatedBodyString(context: context)
                return "HTTP Response: \(string)"
            }
        }

        // AND GIVEN a HTTP client
        let client = makeHTTPClient(.automatic)
        defer { XCTAssertNoThrow(try client.syncShutdown()) }

        // WHEN we make a request
        // THEN it should succeed
        let response = try await client.post(url: "https://127.0.0.1:8081/echo", body: .string("Test HTTP/2 Request!")).get()

        // AND the response should match
        XCTAssertEqual(response.bodyString, "HTTP Response: Test HTTP/2 Request!")

    }

    func testHttp11Post() async throws {

        // GIVEN an HBApplication with gRPC support
        try startServer(port: 8082) {

            // AND GIVEN a route on that that responds
            $0.post("/echo") { request, context async throws -> String in
                var request = request
                let string = try await request.collatedBodyString(context: context)
                return "HTTP Response: \(string)"
            }
        }

        // AND GIVEN a HTTP client
        let client = makeHTTPClient(.http1Only)
        defer { XCTAssertNoThrow(try client.syncShutdown()) }

        // WHEN we make a request
        // THEN it should succeed
        let response = try await client.post(url: "https://127.0.0.1:8082/echo", body: .string("Test HTTP/1.1 Request!")).get()

        // AND the response should match
        XCTAssertEqual(response.bodyString, "HTTP Response: Test HTTP/1.1 Request!")

    }

}


// MARK: - Fixtures

private extension Request {

    mutating func collatedBodyString(context: BasicRequestContext) async throws -> String {
        let body = try await collectBody(upTo: context.maxUploadSize)
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
