import Glibc
print("Program Started")

var currentState = true

func onButtonPressed(){
	print("Button pressed")

	currentState = !currentState

	if(currentState){
		gpioHandler.changeRedState(newState:true)
    	gpioHandler.changeRelayState(newState:false)
	} else {
		gpioHandler.changeRedState(newState:false)
    	gpioHandler.changeRelayState(newState:true)
	}
}

let gpioHandler = GPIOHandler(buttonPressed: onButtonPressed)


while(true){

	usleep(100000)
	//var tempHumdity = gpioHandler.getTempAndHumidity()

	//print(tempHumdity)

    // print("Red up, relay down")
    // gpioHandler.changeRedState(newState:true)
    // gpioHandler.changeRelayState(newState:false)
    // usleep(1000000)
    // print("Red down, relay up")
    // gpioHandler.changeRedState(newState:false)
    // gpioHandler.changeRelayState(newState:true)
    // usleep(1000000)
}


