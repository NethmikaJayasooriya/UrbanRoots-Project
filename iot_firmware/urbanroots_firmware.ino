#include <HardwareSerial.hpp>

// Pin Definitions based on your wiring
#define RE_DE_PIN 4
#define RX_PIN 16
#define TX_PIN 17

// Modbus RTU command to read all 7 parameters (Address 0x01, Function 03, Start 00, Length 07)
// Modbus RTU command to read 7 parameters (Address 0x01, Function 03, Start 00, Length 07)
// CRC Checksum: 0x0408
const byte readCommand[] = {0x01, 0x03, 0x00, 0x00, 0x00, 0x07, 0x04, 0x08};

void setup() {
  Serial.begin(115200);           // PC Monitor
  Serial2.begin(4800, SERIAL_8N1, RX_PIN, TX_PIN); // Sensor (Most use 4800 or 9600 baud)
  Serial.begin(115200); // PC Monitor
  
  // Initialize Serial2 for the sensor
  // Most 7-in-1 sensors default to 4800 or 9600 baud
  Serial2.begin(4800, SERIAL_8N1, RX_PIN, TX_PIN); 

  pinMode(RE_DE_PIN, OUTPUT);
  digitalWrite(RE_DE_PIN, LOW);   // Start in Receive mode
  digitalWrite(RE_DE_PIN, LOW); // Start in Receive mode (Listening)

  Serial.println("Starting 7-in-1 Soil Sensor Test...");
  Serial.println("--- 7-in-1 Soil Sensor Connection Test ---");
}

void loop() {
  // 1. Send the Request
  digitalWrite(RE_DE_PIN, HIGH);  // Switch to Transmit
  // 1. Clear the buffer
  while(Serial2.available()) Serial2.read();

  // 2. Send the Request
  Serial.println("Sending Request...");
  digitalWrite(RE_DE_PIN, HIGH); // Switch to Transmit
  delay(10);
  Serial2.write(readCommand, sizeof(readCommand));
  Serial2.flush();
  digitalWrite(RE_DE_PIN, LOW);   // Switch back to Receive
  Serial2.flush();               // Wait for data to leave the TX buffer
  digitalWrite(RE_DE_PIN, LOW);  // Switch back to Receive

  // 2. Wait for Response
  // 3. Wait for Response
  delay(500); 

  if (Serial2.available()) {
    Serial.print("Response: ");
    Serial.print("Response (Hex): ");
    while (Serial2.available()) {
      byte b = Serial2.read();
      if (b < 0x10) Serial.print("0");
      if (b < 0x10) Serial.print("0"); // Leading zero for single digits
      Serial.print(b, HEX);
      Serial.print(" ");
    }
    Serial.println();
    Serial.println("\n--- Success! ---");
  } else {
    Serial.println("No response. Check wiring or Baud rate.");
    Serial.println("Error: No response from sensor. Check wiring/power.");
  }

  delay(3000); // Wait 3 seconds before next poll
  delay(3000); // Repeat every 3 seconds
}