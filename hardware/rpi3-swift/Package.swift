import PackageDescription

let package = Package(
    name: "rpi3-swift",
    dependencies: [
    	.Package(url: "https://github.com/uraimo/SwiftyGPIO.git", "0.8.7"),
    	.Package(url: "https://github.com/yeokm1/SwiftLinuxSerial.git", "0.0.2"),
    ]
)
