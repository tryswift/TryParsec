// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "TryParsec",
    products: [
        .library(
            name: "TryParsec",
            targets: ["TryParsec"]),
    ],
    dependencies: [
        .package(url: "https://github.com/thoughtbot/Runes.git", from: "4.0.2"),
        .package(url: "https://github.com/antitypical/Result.git", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "TryParsec",
            dependencies: ["Runes", "Result"]),
        // .testTarget(
        //     name: "TryParsecTests",
        //     dependencies: ["TryParsec"]),
    ]
)
