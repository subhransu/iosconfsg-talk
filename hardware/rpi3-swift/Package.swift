import PackageDescription

let package = Package(
    name: "bbb-swift",
    dependencies: [
    	.Package(url: "https://github.com/uraimo/SwiftyGPIO.git", majorVersion: 0),
    ]
)
