//Reference from http://stackoverflow.com/questions/31465943/using-termios-in-swift
import Glibc

let SIZE_BYTES_READ_BLOCKING : cc_t = 1
let SIZE_READ_BUFFER = 32

func openSerialPort(portName : String) -> Int32{
	//O_RDONLY opens the serial port as read-only
	//O_NOCTTY means that no terminal will control the process opening the serial port.
	let fd : Int32 = open(portName, O_RDONLY | O_NOCTTY)
	return fd;
}

func setSerialPortSettings(fd : Int32, charsToReadBeforeReturn : cc_t){

	//Set up the control structure
	var srSettings : termios = termios()

	//Get options structure for the port
	tcgetattr(fd, &srSettings);

	// Set 9600 baud for input
	cfsetispeed(&srSettings, speed_t(B9600));
	//We do not set baud rate for output as this is readonly
	//cfsetospeed(srSettings, UInt32(B9600));

	//No Parity
	srSettings.c_cflag &= ~UInt32(PARENB);
	//1 Stop bit
	srSettings.c_cflag &= ~UInt32(CSTOPB);
	//No mask
	srSettings.c_cflag &= ~UInt32(CSIZE);
	//8 Data bits
	srSettings.c_cflag |= UInt32(CS8);

	//Turn off hardware flow control
	srSettings.c_cflag &= ~UInt32(CRTSCTS);
	// //Turn on the receiver of the serial port (CREAD)
	srSettings.c_cflag |= UInt32(CREAD) | UInt32(CLOCAL);
	//Turn off software based flow control (XON/XOFF)
	srSettings.c_iflag &= ~(UInt32(IXON) | UInt32(IXOFF) | UInt32(IXANY));

	//Turn off canonical mode
	srSettings.c_lflag &= ~(UInt32(ICANON) | UInt32(ECHO) | UInt32(ECHOE) | UInt32(ISIG));

	//Wait for certain number of characters to come in before returning
	//VMIN is position 6 in the tuple. C fixed arrays are imported as tuples in Swift
	//Use print(VMIN) to check the value for your platform
	srSettings.c_cc.6 = charsToReadBeforeReturn;

	//No minimum time to wait before read returns
	//VTIME is position 5 in the tuple. C fixed arrays are imported as tuples in Swift
	//Use print(VTIME) to check the value for your platform
	srSettings.c_cc.5 = 0;

	//Commit settings
	tcsetattr(fd, TCSANOW, &srSettings);
}

//UnsafeMutablePointer<UInt8> is char buf[]
func readBytesFromPort(fd : Int32, buf : UnsafeMutablePointer<UInt8>, size : Int) -> Int {
	let bytesRead : Int = read(fd, buf, size);
	return bytesRead;
}

func closeSerialPort(fd : Int32){
	close(fd);
}

func blockingReadLineFromSerialPort(fd : Int32) -> String{
	var lineBuffer : String = ""
	let tempBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity : 1)

	while(true){
		//Read byte by byte so we pass 1
		let bytesRead : Int = readBytesFromPort(fd : fd, buf : tempBuffer, size : 1)
		
		if(bytesRead > 0){
			let newestCharacter : UnicodeScalar = UnicodeScalar(tempBuffer[0])
			//UnicodeScalar(10) is \n
			if(newestCharacter == UnicodeScalar(10)){
				return lineBuffer
			} else {
				lineBuffer = lineBuffer + String(newestCharacter)
			}
		}
	}
}


//Call this function from your main.swift with Commandline.arguments

func testMainFunction(arguments : [String]){

	if(arguments.count < 2){
		print("Insufficent arguments, need Serial Port name");
		exit(1)
	}

	let serialPortName : String = arguments[1];

	let fd : Int32 = openSerialPort(portName : serialPortName)

	if(fd == -1){
		print("Error in opening port " + serialPortName);
	} else{
		print(serialPortName + " opened successfully");
	}

	setSerialPortSettings(fd : fd, charsToReadBeforeReturn : SIZE_BYTES_READ_BLOCKING)


	while(true){
		let result : String = blockingReadLineFromSerialPort(fd : fd)
		print(result)
	}
}



