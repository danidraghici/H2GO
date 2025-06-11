#include <SoftwareSerial.h>
#include <Wire.h>
#include <Adafruit_Sensor.h>
#include "DHT.h"

// Define the DHT pin and type
#define DHTPIN 4         // Digital pin connected to the DHT sensor
#define DHTTYPE DHT22    // DHT 11

SoftwareSerial BTSerial(5, 6); // RX, TX
DHT dht(DHTPIN, DHTTYPE);

const int ekgPin = A0;
const int pulsePin = A1;

int pulseSignal = 0;            

const int minRaw = 400;  
const int maxRaw = 800;  

float normalizeHeartRate(int rawValue) {
  rawValue = constrain(rawValue, minRaw, maxRaw);
  float normalized = (float)(rawValue - minRaw) / (maxRaw - minRaw);
  float bpm = 60.0 + (normalized * 20.0);

  return bpm;
}

float calibrateTemperature(float rawTemp) {
  float correctedTemp = (rawTemp - 27.6) * 0.5 + 35.5; 
  return correctedTemp;
}

float calibrateHumidity(float rawHum) {
  float correctedHum = (rawHum - 59.8) * 0.6 + 47.5;  
  return correctedHum;
}

const int samplesPerBeat = 100; 
float time = 0.0;
const float dt = 0.01;          

int generateEKGSample(float t) {
  float p = 0.2;
  float q = 0.35;
  float r = 0.4;
  float s = 0.45;
  float tWave = 0.6;

  float pWave = 0.1 * exp(-pow((t - p) * 40, 2));     
  float qWave = -0.15 * exp(-pow((t - q) * 100, 2));  
  float rWave = 1.0 * exp(-pow((t - r) * 80, 2));     
  float sWave = -0.25 * exp(-pow((t - s) * 80, 2));   
  float tComp = 0.35 * exp(-pow((t - tWave) * 30, 2));

  float signal = pWave + qWave + rWave + sWave + tComp;

  signal += 0.05 * sin(2 * PI * t * 0.5); 
  signal += random(-2, 2) / 100.0;        

  int scaled = 400 + int(signal * 300);  
  return scaled;
}


void setup() {
  Serial.begin(115200);         // Pentru Serial Monitor
  BTSerial.begin(115200);       // Pentru Bluetooth
  Serial.println("Setup gata.");
  pinMode(10, INPUT); // Setup for leads off detection LO +
  pinMode(11, INPUT); // Setup for leads off detection LO -

  dht.begin();
}

void loop() {

  delay(10);

  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();

  // Check if any reads failed
  if (isnan(temperature) || isnan(humidity)) {
    Serial.println("Failed to read from DHT sensor!");
    BTSerial.println("Failed to read from DHT sensor!");
    return;
  } 
  else
  {

    float adjustedTemp = calibrateTemperature(temperature);
    float adjustedHum = calibrateHumidity(humidity);

    Serial.print(String("temperature:") + adjustedTemp + String(";"));
    BTSerial.print(String("temperature:") + adjustedTemp + String(";"));

    Serial.print(String("umiditate:") + adjustedHum + String(";"));
    BTSerial.print(String("umiditate:") + adjustedHum + String(";"));
  }


  pulseSignal = analogRead(pulsePin);
  int rawValue = analogRead(pulsePin);

  float bpm = normalizeHeartRate(rawValue);
  Serial.print(String("pulse:") + bpm + String(";"));
  BTSerial.print(String("pulse:") + bpm + String(";"));

  // Check for leads off condition
  // if (digitalRead(10) == 1 || digitalRead(11) == 1) {
    // Serial.print("Leads off! Processed ECG: "); 
  // } else {

    int EKG = generateEKGSample(time);
    EKG = EKG/5;
    Serial.print(String("EKG:") + EKG + "\n");
    BTSerial.print(String("EKG:") + EKG + "\n");

    time += dt;
    if (time >= 1.0) time = 0.0;

  // }

  // Handle Bluetooth commands
  if (BTSerial.available()) {
    String mesaj = BTSerial.readStringUntil('\n');
    Serial.print("Am primit de la telefon: ");
    Serial.println(mesaj);
  }

}

