// swift-tools-version:5.0

import Foundation
import PackageDescription

let package = Package(
    name: "TryParsec",
    products: [
        .library(
            name: "TryParsec",
            targets: ["TryParsec"]),
    ],
    dependencies: [
        .package(url: "https://github.com/thoughtbot/Runes.git", .exact("4.2.1")),
    ],
    targets: [
        .target(
            name: "TryParsec",
            dependencies: ["Runes"])
    ]
)

// `$ TRYPARSEC_SPM_TEST=1 swift test`
if ProcessInfo.processInfo.environment.keys.contains("TRYPARSEC_SPM_TEST") {
    package.targets.append(
        .testTarget(
             name: "TryParsecTests",
             dependencies: ["TryParsec", "Curry", "Quick", "Nimble"])
    )

    package.dependencies.append(
        contentsOf: [
            .package(url: "https://github.com/thoughtbot/Curry.git", from: "4.0.0"),
            .package(url: "https://github.com/Quick/Quick.git", from: "2.1.0"),
            .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"),
        ]
    )
}
