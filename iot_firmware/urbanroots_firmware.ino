// NEW PIN DEFINITIONS
#define RE_DE_PIN 32
#define RX_PIN 14
#define TX_PIN 27

void setup() {
  Serial.begin(115200);
  
  // Initialize pins
  pinMode(RE_DE_PIN, OUTPUT);
  digitalWrite(RE_DE_PIN, LOW); // Force LISTEN mode (LED should be OFF)

  // Use a standard 9600 baud to start
  Serial2.begin(9600, SERIAL_8N1, RX_PIN, TX_PIN);
  
  Serial.println("--- Hardware Pin Reset ---");
  Serial.println("The LED on the RS485 module should be OFF now.");
}

void loop() {
  byte query[] = {0x01, 0x03, 0x00, 0x00, 0x00, 0x07, 0x04, 0x08};

  // 1. Switch to Transmit (LED should blink ON)
  digitalWrite(RE_DE_PIN, HIGH);
  delay(10);
  Serial2.write(query, sizeof(query));
  Serial2.flush();
  
  // 2. Switch to Receive (LED should blink OFF)
  digitalWrite(RE_DE_PIN, LOW);
  
  Serial.println("Request Sent. Waiting...");

  unsigned long startTime = millis();
  while (millis() - startTime < 1000) {
    if (Serial2.available()) {
      Serial.print("SUCCESS! Data: ");
      while(Serial2.available()) {
        Serial.print(Serial2.read(), HEX);
        Serial.print(" ");
      }
      Serial.println();
    }
  }
  
  delay(2000); // Wait 2 seconds
}