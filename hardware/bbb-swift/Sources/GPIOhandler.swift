import SwiftyGPIO
import Foundation

class GPIOHandler {	
	
	let PIN_LED_RED = GPIOName.P9
	let PIN_RELAY_SWITCH = GPIOName.P10
	let PIN_BUTTON = GPIOName.P17

	let DEBOUNCE_DELAY = 0.3

	let gpios = SwiftyGPIO.GPIOs(for:.BeagleBoneBlack)

	var redLED : GPIO
	var relaySwitch : GPIO
	var button : GPIO

	var serialFileDescriptor : Int32

	var buttonPressedHandler : () -> Void

	var timeSinceLastPressed = NSDate().timeIntervalSince1970

	init(tempHumdSerialPort : String, buttonPressed :  @escaping ()-> Void){
		buttonPressedHandler = buttonPressed

		redLED = gpios[PIN_LED_RED]!
		redLED.direction = .OUT

		relaySwitch = gpios[PIN_RELAY_SWITCH]!
		relaySwitch.direction = .OUT

		button = gpios[PIN_BUTTON]!
		button.direction = .IN



		serialFileDescriptor = openSerialPort(portName : tempHumdSerialPort)
		if(serialFileDescriptor == SERIAL_OPEN_FAIL){
			print("Opening serial port " + tempHumdSerialPort + " failed")
		} else {
			setSerialPortSettings(fd : serialFileDescriptor, charsToReadBeforeReturn : SIZE_BYTES_READ_BLOCKING)

			//Reference from http://stackoverflow.com/questions/33260808/swift-proper-use-of-cfnotificationcenteraddobserver-w-callback
			//Obtain Void pointer to self
			//To avoid:  "error: a C function pointer cannot be formed from a closure that captures context"
			let observer = UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())

			var t1 = pthread_t()

			let pthreadFunc: @convention(c) (UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? = {
				externalObserver in
 				
 				let actualSelf = Unmanaged<GPIOHandler>.fromOpaque(externalObserver!).takeUnretainedValue()
				actualSelf.pollSerial()
            	
            	return nil
        	}

        	//Pass observer to the C function for it to call outside
        	pthread_create(&t1, nil, pthreadFunc, observer)
        }

		button.onRaising{
    		gpio in
		
    		//Debouncing logic, only call closure when needed
			let currentTime = NSDate().timeIntervalSince1970
			let elapsedTime = currentTime - self.timeSinceLastPressed

			if(elapsedTime > self.DEBOUNCE_DELAY){
				self.timeSinceLastPressed = currentTime
    			self.buttonPressedHandler()
			}
		}

	}


	func pollSerial(){
		while(true){
			let result : String = blockingReadLineFromSerialPort(fd : serialFileDescriptor)
			print(result)
		}
	}

	func changeRedState(newState : Bool){
		if(newState){
			redLED.value = 1
		} else {
			redLED.value = 0
		}
	}

	func changeRelayState(newState : Bool){
		if(newState){
			relaySwitch.value = 1
		} else {
			relaySwitch.value = 0
		}
	}

}