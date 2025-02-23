// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(

    // MARK: - Package configuration

    name: "hummingbird-grpc",

    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17)
    ],

    // MARK: - Products

    products: [
        .library(name: "HummingbirdGRPC", targets: [ "HummingbirdGRPC" ]),
    ],


    // MARK: - Source Dependencies

    dependencies: [
        .package(url: "https://github.com/unsignedapps/grpc-swift.git", from: "1.23.0"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.27.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.21.2"),
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.9.0"),
    ],


    // MARK: - Targets

    targets: [
        .target(
            name: "HummingbirdGRPC",
            dependencies: [
                .product(name: "GRPC", package: "grpc-swift"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "HummingbirdCore", package: "hummingbird"),
                .product(name: "HummingbirdHTTP2", package: "hummingbird"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
            ]
        ),
        .testTarget(
            name: "CompatibilityTests",
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .target(name: "HummingbirdGRPC"),
            ]
        ),
    ],

    swiftLanguageModes: [
        .v6,
    ]

)
