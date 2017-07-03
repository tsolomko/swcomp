import PackageDescription

let package = Package(
    name: "swcomp",
    dependencies: [
        .Package(url: "https://github.com/tsolomko/SWCompression", majorVersion: 3),
        .Package(url: "https://github.com/jakeheis/SwiftCLI", majorVersion: 3)
    ]
)
