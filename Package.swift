import PackageDescription

let package = Package(
    name: "swcomp",
    dependencies: [
        .Package(url: "https://github.com/tsolomko/SWCompression.git", Version(2, 2, 0)),
    ]
)
