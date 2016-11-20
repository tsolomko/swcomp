import PackageDescription

let package = Package(
    name: "swcomp",
    dependencies: [
        .Package(url: "https://github.com/tsolomko/SWCompression.git", majorVersion: 1),
    ]
)
