import PackageDescription

let package = Package(
    name: "rpi3-swift",
    dependencies: [
    	.Package(url: "https://github.com/uraimo/SwiftyGPIO.git", majorVersion: 0),
    ]
)
