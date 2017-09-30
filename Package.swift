import PackageDescription

let package = Package(
    name: "swcomp",
    dependencies: [
        .Package(url: "https://github.com/tsolomko/SWCompression", Version(3, 3, 0, prereleaseIdentifiers: ["test"])),
        .Package(url: "https://github.com/jakeheis/SwiftCLI", majorVersion: 3, minor: 0)
    ]
)
