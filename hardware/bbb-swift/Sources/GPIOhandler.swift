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
	var tempHumdHandler : (Float, Float) -> Void


	var timeSinceLastPressed = NSDate().timeIntervalSince1970

	init(tempHumdSerialPort : String, receiveTempHumdData : @escaping (Float, Float) -> Void, buttonPressed :  @escaping ()-> Void){
		buttonPressedHandler = buttonPressed
		tempHumdHandler = receiveTempHumdData


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
			print("Serial port " + tempHumdSerialPort + " opened successfully")
			
			setSerialPortSettings(fd : serialFileDescriptor, charsToReadBeforeReturn : SIZE_BYTES_READ_BLOCKING)

			//Reference from http://stackoverflow.com/questions/33260808/swift-proper-use-of-cfnotificationcenteraddobserver-w-callback
			//Obtain Void pointer to self
			//To avoid:  "error: a C function pointer cannot be formed from a closure that captures context"
			let observer = UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())

			var backgroundPthread = pthread_t()

			let pthreadFunc: @convention(c) (UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? = {
				externalObserver in
 				
 				let actualSelf = Unmanaged<GPIOHandler>.fromOpaque(externalObserver!).takeUnretainedValue()
				actualSelf.pollSerial()
            	
            	return nil
        	}

        	//Pass observer to the C function for it to call outside
        	pthread_create(&backgroundPthread, nil, pthreadFunc, observer)
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

			let resultTrimmed = result.trimmingCharacters(in: .whitespacesAndNewlines)
			
			let resultArr : [String] = resultTrimmed.components(separatedBy: " ")

			if(resultArr.count == 2){
				let temperatureString : String = resultArr[0]
				let humidityString : String = resultArr[1];

				let temperature : Float = Float(temperatureString)!
				let humidity : Float = Float(humidityString)!

				//Send data to callback
				tempHumdHandler(temperature, humidity)

			}
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