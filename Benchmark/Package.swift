import PackageDescription

let package = Package(
    name: "TryParsecBenchmark",
    dependencies: [
        .Package(url: "..", majorVersion: 0),
        .Package(url: "https://github.com/inamiy/Curry.git", "3.0.0-inamiy.1"),
    ]
)
