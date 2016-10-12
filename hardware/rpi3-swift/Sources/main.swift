import Glibc
print("Program Started")

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

while(true){
	//This is to keep the main thread running if not the program will end prematurely
	usleep(1000000)
}


