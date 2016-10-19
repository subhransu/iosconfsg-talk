import Glibc
print("Program Started")
import Kitura

func onButtonPressed(){
	swiftMicroControllerObj.toggleState()
}


func recvTempHumdData(temperature : Float, humidity : Float){
	let temperature : String = String(temperature)
	let humidity : String = String(humidity)

	print("Temperature: " + temperature + "°C, Humidity: " + humidity + "%")
}

let swiftMicroControllerObj = SwiftMicroController(tempHumdSerialPort : "/dev/ttyUSB0", receiveTempHumdData : recvTempHumdData, buttonPressed: onButtonPressed)
swiftMicroControllerObj.setupInitialState()

let router = Router()

router.get("/") {
    request, response, next in
    swiftMicroControllerObj.toggleState()
    response.send("Hello, World!")
    next()
}

Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.start()

while(true){
        //This is to keep the main thread running if not the program will end prematurely
        usleep(1000000)
}
