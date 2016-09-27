import PackageDescription

let package = Package(
    name: "TryParsec",
    dependencies: [
        .Package(url: "https://github.com/inamiy/Runes.git", "4.0.0-inamiy.1"),
        .Package(url: "https://github.com/antitypical/Result.git", majorVersion: 3),
    ]
)
