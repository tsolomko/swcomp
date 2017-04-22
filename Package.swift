import PackageDescription

let package = Package(
    name: "swcomp",
    dependencies: [
        .Package(url: "https://github.com/tsolomko/SWCompression.git", Version(2, 3, 0)),
        .Package(url: "https://github.com/jakeheis/SwiftCLI", Version(3, 0, 0)),
    ]
)
