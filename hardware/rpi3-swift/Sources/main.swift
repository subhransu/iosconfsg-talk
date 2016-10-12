import Glibc
print("Program Started")

func onButtonPressed(){
	gpioHandler.toggleState()
}


func recvTempHumdData(temperature : Float, humidity : Float){
	let temperature : String = String(temperature)
	let humidity : String = String(humidity)

	print("Temperature: " + temperature + "°C, Humidity: " + humidity + "%")
}

let gpioHandler = GPIOHandler(tempHumdSerialPort : "/dev/ttyUSB0", receiveTempHumdData : recvTempHumdData, buttonPressed: onButtonPressed)
gpioHandler.setupInitialState()

while(true){
	//This is to keep the main thread running if not the program will end prematurely
	usleep(1000000)
}


