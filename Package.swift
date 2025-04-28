// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "Soup",
    platforms: [.macOS(.v10_14), .iOS(.v14), .tvOS(.v14)],
    products: [
        .library( name: "Soup", type: .dynamic, targets: ["Soup"])
    ],
    dependencies: [
        .package( url: "https://github.com/iStumblerLabs/ILFoundation.git", from: "1.1.0")
    ],
    targets: [
        .target( name: "Soup", dependencies: ["ILFoundation"]),
    ]
)
