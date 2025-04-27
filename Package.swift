// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataLiteCoder",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v12)
    ],
    products: [
        .library(name: "DataLiteCoder", targets: ["DataLiteCoder"])
    ],
    dependencies: [
        .package(url: "https://github.com/angd-dev/data-lite-core.git", .upToNextMinor(from: "0.1.0")),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "DataLiteCoder",
            dependencies: [
                .product(name: "DataLiteCore", package: "data-lite-core"),
                "DLCDecoder"
            ]
        ),
        .target(
            name: "DLCCommon",
            dependencies: [
                .product(name: "DataLiteCore", package: "data-lite-core")
            ]
        ),
        .target(
            name: "DLCDecoder",
            dependencies: [
                .product(name: "DataLiteCore", package: "data-lite-core"),
                "DLCCommon"
            ]
        ),
        .testTarget(name: "DataLiteCoderTests", dependencies: ["DataLiteCoder"]),
        .testTarget(name: "DLCCommonTests", dependencies: ["DLCCommon"]),
        .testTarget(name: "DLCDecoderTests", dependencies: ["DLCDecoder"])
    ]
)
