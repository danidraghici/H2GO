#include <SoftwareSerial.h>
SoftwareSerial BTSerial(10, 11); // RX, TX

const int pulsePin = A0; // Pinul la care e conectat senzorul de puls
int Signal;              // Valoarea citită de la senzor
int Threshold = 580;     // Prag pentru detectarea bătăilor
bool beatDetected = false;

unsigned long lastBeatTime = 0; // Timpul ultimei bătăi
int BPM = 0;                    // Bătăi pe minut

void setup() {
  Serial.begin(115200);         // Pentru Serial Monitor
  BTSerial.begin(115200);       // Pentru Bluetooth
  Serial.println("Setup gata.");
  pinMode(3, INPUT); // Setup for leads off detection LO +
  pinMode(2, INPUT); // Setup for leads off detection LO -
}

void loop() {
  Signal = analogRead(pulsePin);

  // Afișare semnal brut
//  Serial.print("Signal: ");
//  Serial.print(Signal);
  
  // Detectare bătăi
  if (Signal > Threshold && !beatDetected) {
    unsigned long currentTime = millis();
    unsigned long timeBetweenBeats = currentTime - lastBeatTime;
    lastBeatTime = currentTime;

    // Calcul BPM doar dacă timpul între bătăi este rezonabil
    if (timeBetweenBeats > 300 && timeBetweenBeats < 2000) {
      BPM = 60000 / timeBetweenBeats;
    }

    beatDetected = true;

    // Afișăm BPM în Serial Monitor
//    Serial.print(" | BPM: ");
//    Serial.println(BPM);

    // Trimitem prin Bluetooth
    BTSerial.print("BPM: ");
    BTSerial.println(BPM);
  }

  // Resetăm flag-ul când semnalul scade sub prag
  if (Signal < Threshold) {
    beatDetected = false;
  }

  if((digitalRead(2) == 1)||(digitalRead(3) == 1)){
    Serial.println('!');
  }
  else{
  // send the value of analog input 0:
    Serial.println(analogRead(A0));
  }
  
  // Primire comenzi de la telefon
  if (BTSerial.available()) {
    String mesaj = BTSerial.readStringUntil('\n');
    Serial.print("Am primit de la telefon: ");
    Serial.println(mesaj);
  }


  delay(20); // Delay scurt pentru citire mai frecventă (~50 Hz)
}
