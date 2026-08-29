// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "Soup",
    platforms: [.macOS(.v10_14), .iOS(.v14), .tvOS(.v14)],
    products: [
        .library(name: "Soup", type: .dynamic, targets: ["Soup"])
    ],
    dependencies: [],
    targets: [
        .target(name: "Soup", dependencies: [], path: "Source/SoupSwift"),
        .testTarget(name: "SoupTests", dependencies: ["Soup"], path: "Source/SoupTests"),
        .testTarget(name: "SoupSwiftTests", dependencies: ["Soup"], path: "Source/SoupSwiftTests"),
    ]
)
