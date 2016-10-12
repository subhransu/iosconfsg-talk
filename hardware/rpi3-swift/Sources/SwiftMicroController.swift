import SwiftyGPIO
import Foundation
import SwiftLinuxSerial

enum GPIOState: Int {
	case On = 1
	case Off = 0
}

class SwiftMicroController {	
	
	let DEBOUNCE_DELAY = 0.3
	var buttonPressedHandler : () -> Void
	var tempHumdHandler : (Float, Float) -> Void

	var serialHandler : SwiftLinuxSerial
	var timeSinceLastPressed = NSDate().timeIntervalSince1970
	
	lazy var buttonManager: GPIOPinManager?  = {
		return GPIOPinManager()
	}()

	var currentState = GPIOState.On

	init(tempHumdSerialPort : String, receiveTempHumdData : @escaping (Float, Float) -> Void, buttonPressed :  @escaping ()-> Void){
		buttonPressedHandler = buttonPressed
		tempHumdHandler = receiveTempHumdData
		
		serialHandler = SwiftLinuxSerial(serialPortName : tempHumdSerialPort)

		let status = serialHandler.openPort(receive : true, transmit : false)

		if let buttonManager = buttonManager {
			buttonManager.buttonDelegate = self
		}

		if(status.openSuccess){
			print("Serial port " + tempHumdSerialPort + " opened successfully")

			serialHandler.setPortSettings(receiveBaud : SwiftLinuxSerialBaud.BAUD_B9600, transmitBaud : SwiftLinuxSerialBaud.BAUD_B9600, charsToReadBeforeReturn : 1)

			// let dispatch_async = DispatchQueue(label: "SerialPortPollThread")
			
			// dispatch_async.main.async {
   //  			self.pollSerial()
			// }

			//C: pthread_t backgroundPthread;
			var backgroundPthread = pthread_t()

			//Reference from http://stackoverflow.com/questions/33260808/swift-proper-use-of-cfnotificationcenteraddobserver-w-callback
			//Obtain Void pointer to self
			//To avoid:  "error: a C function pointer cannot be formed from a closure that captures context"
			let observer = UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())

			let pthreadFunc: @convention(c) (UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? = {
				externalObserver in
 				
 				let actualSelf = Unmanaged<SwiftMicroController>.fromOpaque(externalObserver!).takeUnretainedValue()
				actualSelf.pollSerial()
            	
				return nil
			}

        	//Pass observer to the C function for it to call outside
        	//Function Definition in C: int pthread_create(pthread_t * thread, const pthread_attr_t * attr, void * (*start_routine)(void *), void * arg);
        	pthread_create(&backgroundPthread, nil, pthreadFunc, observer)
		} else {
			print("Opening serial port " + tempHumdSerialPort + " failed")
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

	func setupInitialState() {
		changeState(currentState: currentState)
	}

	func changeState(currentState: GPIOState) {
		switch (currentState) {
			case .On:
				buttonManager?.changeRedState(newState: .On)
		    	buttonManager?.changeRelayState(newState: .Off)
				print("Button pressed, red up, relay down")
			case .Off:
				buttonManager?.changeRedState(newState: .Off)
		    	buttonManager?.changeRelayState(newState: .On)
		    	print("Button pressed, red down, relay up")
		}
	}

	public func toggleState() {
		currentState = currentState == .On ? .Off : .On
		changeState(currentState: currentState)
	}
}

extension SwiftMicroController: GPIOPinManagerDelegate {
	func didPressButton() {
		//Debouncing logic, only call closure when needed
		let currentTime = NSDate().timeIntervalSince1970
		let elapsedTime = currentTime - self.timeSinceLastPressed

		if(elapsedTime > self.DEBOUNCE_DELAY){
			self.timeSinceLastPressed = currentTime
    		self.buttonPressedHandler()
		}
	}
}