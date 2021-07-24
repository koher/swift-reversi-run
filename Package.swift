// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-reversi-run",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "SwiftyReversi", url: "https://github.com/koher/swifty-reversi.git", from: "0.2.0-beta"),
        .package(url: "https://github.com/kareman/SwiftShell.git", from: "5.1.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.4.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "swift-reversi-run",
            dependencies: ["SwiftyReversi", "SwiftShell", .product(name: "ArgumentParser", package: "swift-argument-parser")],
            exclude: ["run", "run-docker"]),
        .testTarget(
            name: "swift-reversi-runTests",
            dependencies: ["swift-reversi-run"]),
    ]
)
