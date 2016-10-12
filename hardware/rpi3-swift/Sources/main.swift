import Glibc
print("Program Started")

var currentState = true

func onButtonPressed(){
	currentState = !currentState

	if(currentState){
		gpioHandler.changeRedState(newState: .On)
    	gpioHandler.changeRelayState(newState: .Off)
		print("Button pressed, red up, relay down")

	} else {
		gpioHandler.changeRedState(newState: .Off)
    	gpioHandler.changeRelayState(newState: .On)
    	print("Button pressed, red down, relay up")
	}
}


func recvTempHumdData(temperature : Float, humidity : Float){
	let temperature : String = String(temperature)
	let humidity : String = String(humidity)

	print("Temperature: " + temperature + "°C, Humidity: " + humidity + "%")
}

let gpioHandler = GPIOHandler(tempHumdSerialPort : "/dev/ttyUSB0", receiveTempHumdData : recvTempHumdData, buttonPressed: onButtonPressed)
gpioHandler.changeRedState(newState: .On)
gpioHandler.changeRelayState(newState: .Off)

while(true){
	//This is to keep the main thread running if not the program will end prematurely
	usleep(1000000)
}


