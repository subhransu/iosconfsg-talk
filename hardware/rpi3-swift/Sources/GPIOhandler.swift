import SwiftyGPIO
import Foundation
import SwiftLinuxSerial

enum GPIOState: Int {
	case On = 1
	case Off = 0
}
class GPIOHandler {	
	
	let DEBOUNCE_DELAY = 0.3

	// let gpios = SwiftyGPIO.GPIOs(for:.RaspberryPi2)

	let PIN_RELAY_SWITCH = GPIOName.P17
	let PIN_RED_LED  = GPIOName.P27
	let PIN_BUTTON = GPIOName.P22

	let relaySwitch: GPIO = {
		return SwiftyGPIO.GPIOs(for:.RaspberryPi2)[PIN_RELAY_SWITCH]
	}()

	let redLED: GPIO =  { 
		return SwiftyGPIO.GPIOs(for:.RaspberryPi2)[PIN_RED_LED]
	}()

	let button: GPIO = {
		return SwiftyGPIO.GPIOs(for:.RaspberryPi2)[PIN_BUTTON]	
	}()

	var buttonPressedHandler : () -> Void
	var tempHumdHandler : (Float, Float) -> Void

	var serialHandler : SwiftLinuxSerial
	var timeSinceLastPressed = NSDate().timeIntervalSince1970

	init(tempHumdSerialPort : String, receiveTempHumdData : @escaping (Float, Float) -> Void, buttonPressed :  @escaping ()-> Void){
		buttonPressedHandler = buttonPressed
		tempHumdHandler = receiveTempHumdData

		relaySwitch.direction = .OUT
		redLED.direction = .OUT
		button.direction = .IN

		serialHandler = SwiftLinuxSerial(serialPortName : tempHumdSerialPort)

		let status = serialHandler.openPort(receive : true, transmit : false)

		if(status.openSuccess){
			print("Serial port " + tempHumdSerialPort + " opened successfully")

			serialHandler.setPortSettings(receiveBaud : SwiftLinuxSerialBaud.BAUD_B9600, transmitBaud : SwiftLinuxSerialBaud.BAUD_B9600, charsToReadBeforeReturn : 1)

			//C: pthread_t backgroundPthread;
			var backgroundPthread = pthread_t()

			//Reference from http://stackoverflow.com/questions/33260808/swift-proper-use-of-cfnotificationcenteraddobserver-w-callback
			//Obtain Void pointer to self
			//To avoid:  "error: a C function pointer cannot be formed from a closure that captures context"
			let observer = UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())

			let pthreadFunc: @convention(c) (UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? = {
				externalObserver in
 				
 				let actualSelf = Unmanaged<GPIOHandler>.fromOpaque(externalObserver!).takeUnretainedValue()
				actualSelf.pollSerial()
            	
				return nil
			}

        	//Pass observer to the C function for it to call outside
        	//Function Definition in C: int pthread_create(pthread_t * thread, const pthread_attr_t * attr, void * (*start_routine)(void *), void * arg);
        	pthread_create(&backgroundPthread, nil, pthreadFunc, observer)
		} else {
			print("Opening serial port " + tempHumdSerialPort + " failed")
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
			let result : String = serialHandler.readLineFromPortBlocking()
			let resultTrimmed = result.trimmingCharacters(in: .whitespacesAndNewlines)			
			let resultArr : [String] = resultTrimmed.components(separatedBy: " ")

			if resultArr.count == 2 {
				let temperatureString : String = resultArr[0]
				let humidityString : String = resultArr[1];

				let temperature : Float = Float(temperatureString)!
				let humidity : Float = Float(humidityString)!

				//Send data to callback
				tempHumdHandler(temperature, humidity)

			}
		}
	}

	func changeRedState(newState : GPIOState){
		redLED.value = newState.rawValue
	}

	func changeRelayState(newState : GPIOState){
		relaySwitch.value = newState.rawValue
	}
}