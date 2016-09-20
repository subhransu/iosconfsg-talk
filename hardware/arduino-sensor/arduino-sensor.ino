#include <DHT.h>

#define DHTPIN 11     // what digital pin we're connected to
#define DHTTYPE DHT22   // DHT 22  (AM2302), AM2321

DHT dht(DHTPIN, DHTTYPE);

void setup(){

  Serial.begin(9600);
  Serial1.begin(9600);
  sendToBothSerialPrintln("Sensor start");

  dht.begin();
}


void loop(){

  delay(2000);

  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();

  String result = generateResultString(temperature, humidity);

  sendToBothSerialPrintln(result);
  
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

