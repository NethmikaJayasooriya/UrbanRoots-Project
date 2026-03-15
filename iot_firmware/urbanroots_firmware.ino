#include <ModbusMaster.h>

#define RXD2 16
#define TXD2 17
#define MAX485_DE_RE 4

ModbusMaster node;

void preTransmission()
{
  digitalWrite(MAX485_DE_RE, 1);
}

void postTransmission()
{
  digitalWrite(MAX485_DE_RE, 0);
#include <HardwareSerial.hpp>

// Pin Definitions based on your wiring
#define RE_DE_PIN 4
#define RX_PIN 16
#define TX_PIN 17

// Modbus RTU command to read all 7 parameters (Address 0x01, Function 03, Start 00, Length 07)
const byte readCommand[] = {0x01, 0x03, 0x00, 0x00, 0x00, 0x07, 0x04, 0x08};

void setup() {
  Serial.begin(115200);           // PC Monitor
  Serial2.begin(4800, SERIAL_8N1, RX_PIN, TX_PIN); // Sensor (Most use 4800 or 9600 baud)
  
  pinMode(RE_DE_PIN, OUTPUT);
  digitalWrite(RE_DE_PIN, LOW);   // Start in Receive mode
  
  Serial.println("Starting 7-in-1 Soil Sensor Test...");
}

void setup()
{
  Serial.begin(115200);
  Serial2.begin(4800, SERIAL_8N1, RXD2, TXD2);

  pinMode(MAX485_DE_RE, OUTPUT);
  digitalWrite(MAX485_DE_RE, 0);

  node.begin(1, Serial2);  
  node.preTransmission(preTransmission);
  node.postTransmission(postTransmission);
}

void loop()
{
  uint8_t result;
  result = node.readHoldingRegisters(0x0000, 7);

  if (result == node.ku8MBSuccess)
  {
    Serial.print("Moisture: ");
    Serial.println(node.getResponseBuffer(0) / 10.0);

    Serial.print("Temperature: ");
    Serial.println(node.getResponseBuffer(1) / 10.0);

    Serial.print("EC: ");
    Serial.println(node.getResponseBuffer(2));

    Serial.print("pH: ");
    Serial.println(node.getResponseBuffer(3) / 10.0);

    Serial.print("Nitrogen: ");
    Serial.println(node.getResponseBuffer(4));

    Serial.print("Phosphorus: ");
    Serial.println(node.getResponseBuffer(5));

    Serial.print("Potassium: ");
    Serial.println(node.getResponseBuffer(6));

    Serial.println("----------------------");
void loop() {
  // 1. Send the Request
  digitalWrite(RE_DE_PIN, HIGH);  // Switch to Transmit
  delay(10);
  Serial2.write(readCommand, sizeof(readCommand));
  Serial2.flush();
  digitalWrite(RE_DE_PIN, LOW);   // Switch back to Receive
  
  // 2. Wait for Response
  delay(500); 
  
  if (Serial2.available()) {
    Serial.print("Response: ");
    while (Serial2.available()) {
      byte b = Serial2.read();
      if (b < 0x10) Serial.print("0");
      Serial.print(b, HEX);
      Serial.print(" ");
    }
    Serial.println();
  } else {
    Serial.println("No response. Check wiring or Baud rate.");
  }
  else
  {
    Serial.println("Sensor read error");
  }

  delay(2000);
  
  delay(3000); // Wait 3 seconds before next poll
}