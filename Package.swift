// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftGUI",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "SwiftGUI",
            targets: ["SwiftGUI"]),
    ],
    dependencies: [
        .package(name: "Runtime", url: "https://github.com/yonaskolb/Runtime", .branch("master")),
    ],
    targets: [
        .target(
            name: "SwiftGUI",
            dependencies: ["Runtime"]),
    ]
)
