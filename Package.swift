import PackageDescription

let package = Package(
    name: "swcomp",
    dependencies: [
        .Package(url: "https://github.com/tsolomko/SWCompression", Version(3, 0, 1)),
        .Package(url: "https://github.com/jakeheis/SwiftCLI", Version(3, 0, 1))
    ]
)
