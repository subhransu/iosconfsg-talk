import SwiftyGPIO
import Foundation
import SwiftLinuxSerial

protocol GPIOPinManagerDelegate {
	func didPressButton()
}

class GPIOPinManager {
	let gpios = SwiftyGPIO.GPIOs(for:.RaspberryPi2)
	var buttonDelegate: GPIOPinManagerDelegate?

	let PIN_RELAY_SWITCH = GPIOName.P17
	let PIN_RED_LED  = GPIOName.P27
	let PIN_BUTTON = GPIOName.P22

	let relaySwitch: GPIO 
	let redLED: GPIO 
	let button: GPIO 

	init() {
		relaySwitch = gpios[PIN_RELAY_SWITCH]
		redLED = gpios[PIN_RED_LED]
		button = gpios[PIN_BUTTON]

		relaySwitch.direction = .OUT
		redLED.direction = .OUT
		button.direction = .IN

		button.onRaising{
    		gpio in		
    		self.buttonDelegate.didPressButton()
		}
	}

	func changeRedState(newState : GPIOState){
		redLED.value = newState.rawValue
	}

	func changeRelayState(newState : GPIOState){
		relaySwitch.value = newState.rawValue
	}
}