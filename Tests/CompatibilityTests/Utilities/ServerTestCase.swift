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
    ) async throws -> Application<RouterResponder<BasicRequestContext>> {
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

    private func makeGRPCClient(
        app: Application<RouterResponder<BasicRequestContext>>,
        port: Int,
        protocol proto: GRPCProtocol
    ) throws -> ClientConnection {
        guard SampleCertificate.ca.isExpired == false else {
            throw ServerError.certificateExpired
        }

        var tls = TLSConfiguration.makeClientConfiguration()
        tls.certificateVerification = .fullVerification
        tls.trustRoots = .certificates([ SampleCertificate.ca.certificate ])
        tls.applicationProtocols = proto.alpn
        var configuration = ClientConnection.Configuration.default(target: .host("localhost", port: port), eventLoopGroup: app.eventLoopGroup)
        configuration.tlsConfiguration = .makeClientConfigurationBackedByNIOSSL(configuration: tls)
        return ClientConnection(configuration: configuration)
    }

    func makeAsyncGRPCClient(
        app: Application<RouterResponder<BasicRequestContext>>,
        port: Int,
        protocol proto: GRPCProtocol
    ) async throws -> Echo_EchoAsyncClient {
        try Echo_EchoAsyncClient(channel: makeGRPCClient(app: app, port: port, protocol: proto))
    }

    func makeNIOGRPCClient(
        app: Application<RouterResponder<BasicRequestContext>>,
        port: Int,
        protocol proto: GRPCProtocol
    ) async throws -> Echo_EchoNIOClient {
        try Echo_EchoNIOClient(channel: makeGRPCClient(app: app, port: port, protocol: proto))
    }

    func makeHTTPClient(_ version: HTTPClient.Configuration.HTTPVersion) async throws -> HTTPClient {
        guard SampleCertificate.ca.isExpired == false else {
            throw ServerError.certificateExpired
        }

        var tls = TLSConfiguration.makeClientConfiguration()
        tls.trustRoots = .certificates([ SampleCertificate.ca.certificate ])
        tls.certificateVerification = .none

        var configuration = HTTPClient.Configuration(tlsConfiguration: tls)
        configuration.httpVersion = version

        return HTTPClient(eventLoopGroupProvider: .singleton, configuration: configuration)
    }


}

enum GRPCProtocol {
    case http2
    case grpcExp

    var alpn: [String] {
        switch self {
        case .grpcExp:          [ "grpc-exp" ]
        case .http2:            [ "h2" ]
        }
    }
}

enum ServerError: Error {
    case certificateExpired
}
