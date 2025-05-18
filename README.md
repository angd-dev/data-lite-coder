# DataLiteCoder

**DataLiteCoder** is a Swift library that provides encoding and decoding of models using `Codable` for working with SQLite, designed for integration with the [DataLiteCore](https://github.com/angd-dev/data-lite-core) library.

## Overview

**DataLiteCoder** acts as a bridge between your Swift models and SQLite by leveraging the `Codable` system. It enables automatic encoding and decoding of model types to and from SQLite rows, including support for custom date formats and user-defined decoding strategies.

It is designed to be used alongside **DataLiteCore**, which manages low-level interactions with SQLite databases. Together, they provide a clean and extensible toolkit for building type-safe, SQLite-backed applications in Swift.

## Requirements

- **Swift**: 6.0 or later
- **Platforms**: macOS 10.14+, iOS 12.0+, Linux

## Installation

To add **DataLiteCoder** to your project, use Swift Package Manager (SPM), which allows for easy dependency management in your project.

### Adding to an Xcode Project

1. Open your project in Xcode.
2. Navigate to the `File` menu and select `Add Package Dependencies`.
3. Enter the repository URL: `https://github.com/angd-dev/data-lite-coder.git`
4. Choose the version to install (e.g., `0.1.0`).
5. Add the library to your target module.

### Adding to Package.swift

If you are using Swift Package Manager with a `Package.swift` file, add the library as follows:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "YourProject",
    dependencies: [
        .package(url: "https://github.com/angd-dev/data-lite-coder.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "YourTarget",
            dependencies: [
                .product(name: "DataLiteCoder", package: "data-lite-coder")
            ]
        )
    ]
)
```

## Additional Resources

For more detailed information and usage examples of **DataLiteCore**, please visit the [documentation](https://docs.angd.dev/?package=data-lite-coder&version=0.1.0).

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
