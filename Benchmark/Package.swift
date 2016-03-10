import PackageDescription

let package = Package(
    name: "TryParsecBenchmark",
    targets: [
        Target(name: "Benchmark"),
    ],
    dependencies: [
        .Package(url: "..", majorVersion: 0),
        .Package(url: "https://github.com/thoughtbot/Curry.git", majorVersion: 2),
    ]
)
