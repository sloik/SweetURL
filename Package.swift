// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SweetURL",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SweetURL",
            type: .dynamic,
            targets: ["SweetURL"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-http-types.git",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.15.1"
          ),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SweetURL",
            dependencies: [
                .product(
                    name: "HTTPTypes",
                    package: "swift-http-types"
                ),
                .product(
                    name: "HTTPTypesFoundation",
                    package: "swift-http-types"
                ),
            ]
        ),
        .testTarget(
            name: "SweetURLTests",
            dependencies: [
                "SweetURL",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]),
    ]
)
