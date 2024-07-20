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

import AsyncHTTPClient
import GRPC
import Hummingbird
import HummingbirdGRPC
import ServiceLifecycle
import XCTest

class ServerTestCase: XCTestCase {

    var serviceGroup: ServiceGroup?
    var appTask: Task<Void, Never>?

    override func tearDown() async throws {
        try await super.tearDown()

        await serviceGroup?.triggerGracefulShutdown()
    }

    // MARK: - Helpers

    @discardableResult
    func startServer(
        port: Int,
        routerBuilder: (inout Router<BasicRequestContext>) -> Void = { _ in },
        serverBuilder: (inout GRPCServerBuilder) -> Void = { $0.addServiceProvider(EchoProvider()) },
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Application<RouterResponder<BasicRequestContext>> {
        guard SampleCertificate.server.isExpired == false else {
            throw ServerError.certificateExpired
        }

        var router = Router()
        routerBuilder(&router)

        var server = GRPCServerBuilder()
        serverBuilder(&server)

        let app = try Application(
            router: router,
            server: .grpc(
                serverBuilder: server,
                tlsConfiguration: .makeServerConfiguration(
                    certificateChain: [
                        .certificate(SampleCertificate.server.certificate),
                    ],
                    privateKey: .privateKey(SamplePrivateKey.server)
                )
            ),
            configuration: .init(address: .hostname(port: port))
        )

        let serviceGroup = ServiceGroup(
            configuration: .init(
                services: [app],
                gracefulShutdownSignals: [.sigterm, .sigint],
                logger: app.logger
            )
        )

        self.serviceGroup = serviceGroup
        appTask = Task.detached {
            await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    try await serviceGroup.run()
                }
            }
        }

        return app
    }

    func makeAsyncGRPCClient(app: Application<RouterResponder<BasicRequestContext>>, port: Int) -> Echo_EchoAsyncClient {
        let channel = ClientConnection.usingPlatformAppropriateTLS(for: app.eventLoopGroup)
            .withTLS(trustRoots: .certificates([
                SampleCertificate.ca.certificate,
            ]))
            .withTLS(certificateVerification: .fullVerification)
            .connect(host: "localhost", port: port)
        return Echo_EchoAsyncClient(channel: channel)
    }

    func makeNIOGRPCClient(app: Application<RouterResponder<BasicRequestContext>>, port: Int) -> Echo_EchoNIOClient {
        let channel = ClientConnection.usingPlatformAppropriateTLS(for: app.eventLoopGroup)
            .withTLS(trustRoots: .certificates([
                SampleCertificate.ca.certificate,
            ]))
            .withTLS(certificateVerification: .fullVerification)
            .connect(host: "localhost", port: port)
        return Echo_EchoNIOClient(channel: channel)
    }

    func makeHTTPClient(_ version: HTTPClient.Configuration.HTTPVersion) -> HTTPClient {
        var tls = TLSConfiguration.makeClientConfiguration()
        tls.trustRoots = .certificates([ SampleCertificate.ca.certificate ])
        tls.certificateVerification = .none

        var configuration = HTTPClient.Configuration(tlsConfiguration: tls)
        configuration.httpVersion = version

        return HTTPClient(eventLoopGroupProvider: .singleton, configuration: configuration)
    }


}

enum ServerError: Error {
    case certificateExpired
}
