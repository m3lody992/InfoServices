// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InfoServices",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "InfoServices",
            targets: ["InfoServices"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.4.3"),
         .package(url: "https://github.com/m3lody992/Networking", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "InfoServices",
            dependencies: ["CryptoSwift", .product(name: "Networking", package: "Networking")]),
    ]
)
