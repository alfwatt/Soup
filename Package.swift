// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "Soup",
    platforms: [.macOS(.v10_14), .iOS(.v14), .tvOS(.v14)],
    products: [
        .library( name: "Soup", type: .dynamic, targets: ["Soup"]),
        .library(name: "SoupSwift", targets: ["SoupSwift"])
    ],
    dependencies: [
        .package( url: "https://github.com/alfwatt/ILFoundation.git", from: "1.1.0")
    ],
    targets: [
        .target( name: "Soup", dependencies: ["ILFoundation"]),
        .target(name: "SoupSwift", dependencies: [], path: "Source/SoupSwift"),
        .testTarget(name: "SoupSwiftTests", dependencies: ["SoupSwift"], path: "Source/SoupSwiftTests"),
    ]
)
