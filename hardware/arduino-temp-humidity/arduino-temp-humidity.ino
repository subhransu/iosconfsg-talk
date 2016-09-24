#include <DHT.h>

#define PIN_DHT 11
#define DHTTYPE DHT22

#define PIN_ONBOARD_LED 13

DHT dht(PIN_DHT, DHTTYPE);

void setup(){
  Serial.begin(9600);
  Serial1.begin(9600);

  pinMode(PIN_ONBOARD_LED, OUTPUT);
  delay(500); //Wait for serial port to initialise

  dht.begin();

  //Turn on LED momentarily to show end of setup function
  digitalWrite(PIN_ONBOARD_LED, HIGH);
  delay(1000);
  digitalWrite(PIN_ONBOARD_LED, LOW);
}


void loop(){
  
  delay(2000); //DHT22 requires 2 seconds to measure a reading
  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();

  String result = generateResultString(temperature, humidity);

  digitalWrite(PIN_ONBOARD_LED, HIGH);
  sendToBothSerialPrintln(result);
  digitalWrite(PIN_ONBOARD_LED, LOW);
}

String generateResultString(float temperature, float humidity){
  char strHumd[10];
  char strTemp[10];
  char resultString[50];

  //Do this as Arduino cannot sprintf a float
  dtostrf(humidity, 0, 1, strHumd);
  dtostrf(temperature, 0, 1, strTemp);

  snprintf(resultString, 50, "%s %s", strTemp, strHumd);
  
  return resultString;
}


void sendToBothSerialPrintln(String line){
  Serial.println(line);
  Serial1.println(line);
}

