import PackageDescription

let package = Package(
    name: "rpi3-swift",
    dependencies: [
    	.Package(url: "https://github.com/uraimo/SwiftyGPIO.git", majorVersion: 0),
    	.Package(url: "https://github.com/yeokm1/SwiftLinuxSerial.git", majorVersion: 0),
    ]
)
