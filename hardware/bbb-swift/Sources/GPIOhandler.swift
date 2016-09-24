import SwiftyGPIO
import Foundation

class GPIOHandler {	
	
	let PIN_LED_RED = GPIOName.P9
	let PIN_RELAY_SWITCH = GPIOName.P10
	let PIN_BUTTON = GPIOName.P17
	let PIN_DHT22 = GPIOName.P4

	let DEBOUNCE_DELAY = 0.3

	let gpios = SwiftyGPIO.GPIOs(for:.BeagleBoneBlack)

	var redLED : GPIO
	var relaySwitch : GPIO
	var button : GPIO
	var dht22 : GPIO

	var buttonPressedHandler : () -> Void

	var timeSinceLastPressed = NSDate().timeIntervalSince1970

	let dhtHandler : DHT;


	init(buttonPressed :  @escaping ()-> Void){
		buttonPressedHandler = buttonPressed

		dht22 = gpios[PIN_DHT22]!
		dhtHandler = DHT(pin : dht22)

		redLED = gpios[PIN_LED_RED]!
		redLED.direction = .OUT

		relaySwitch = gpios[PIN_RELAY_SWITCH]!
		relaySwitch.direction = .OUT

		button = gpios[PIN_BUTTON]!
		button.direction = .IN

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

	func getTempAndHumidity() -> (temperature: Double, humidity: Double) {
		return dhtHandler.read(debug : true)
	}

    

}