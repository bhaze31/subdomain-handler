// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SubdomainHandler",
    platforms: [
      .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SubdomainHandler",
            targets: ["SubdomainHandler"]
        ),
    ],
    dependencies: [
      // 💧 A server-side Swift web framework.
      .package(url: "https://github.com/vapor/vapor.git", from: "4.52.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SubdomainHandler",
            dependencies: [
              .product(name: "Vapor", package: "vapor")
            ]
        ),
        .testTarget(
            name: "SubdomainHandlerTests",
            dependencies: ["SubdomainHandler"]),
    ]
)
