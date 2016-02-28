import PackageDescription

let package = Package(
    name: "TryParsecBenchmark",
    dependencies: [
        .Package(url: "..", majorVersion: 0)
    ]
)
