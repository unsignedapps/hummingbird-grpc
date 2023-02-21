// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(

    // MARK: - Package configuration

    name: "hummingbird-grpc",


    // MARK: - Products

    products: [
        .library(name: "HummingbirdGRPC", targets: [ "HummingbirdGRPC" ]),
    ],


    // MARK: - Source Dependencies

    dependencies: [
        .package(url: "https://github.com/unsignedapps/grpc-swift.git", from: "1.14.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.15.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-core.git", from: "1.1.1"),
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "1.0.0"),
    ],


    // MARK: - Targets

    targets: [
        .target(
            name: "HummingbirdGRPC",
            dependencies: [
                .product(name: "GRPC", package: "grpc-swift"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "HummingbirdCore", package: "hummingbird-core"),
            ]
        ),
        .testTarget(
            name: "CompatibilityTests",
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .target(name: "HummingbirdGRPC"),
            ]
        ),
    ]

)
