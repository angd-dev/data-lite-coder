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
        .package(
            url: "https://github.com/angd-dev/data-lite-core.git",
            revision: "5c6942bd0b9636b5ac3e550453c07aac843e8416"
        ),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "DataLiteCoder",
            dependencies: [
                .product(name: "DataLiteCore", package: "data-lite-core"),
                "DLCDecoder",
                "DLCEncoder"
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
        .target(
            name: "DLCEncoder",
            dependencies: [
                .product(name: "DataLiteCore", package: "data-lite-core"),
                "DLCCommon"
            ]
        ),
        .testTarget(name: "DataLiteCoderTests", dependencies: ["DataLiteCoder"]),
        .testTarget(name: "DLCCommonTests", dependencies: ["DLCCommon"]),
        .testTarget(name: "DLCDecoderTests", dependencies: ["DLCDecoder"]),
        .testTarget(name: "DLCEncoderTests", dependencies: ["DLCEncoder"])
    ]
)
