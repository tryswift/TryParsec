import PackageDescription

let package = Package(
    name: "TryParsec",
    dependencies: [
        .Package(url: "https://github.com/antitypical/Result.git", majorVersion: 1)
    ]
)
