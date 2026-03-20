/*
  PRO IoT - 7-in-1 RS485 Soil + BH1750 + ESP32 + WiFi Auto-Reconnect + Scanner Ping
*/
#include <Arduino.h>
#include <HardwareSerial.h>
#include <Wire.h>
#include <BH1750.h>
#include <WiFi.h>
#include <WebServer.h>
#include <ESPmDNS.h>

// ================================================================
//  CHANGE THESE TO YOUR WIFI NAME AND PASSWORD
// ================================================================
const char* WIFI_SSID     = "SLT_FIBRE";
const char* WIFI_PASSWORD = "20030808";
const char* DEVICE_NAME   = "urbanroots"; // Device will appear as urbanroots.local

// ================================================================
//  PIN DEFINITIONS
// ================================================================
#define RS485_TX_PIN     17
#define RS485_RX_PIN     16
#define RS485_DE_RE_PIN   4
#define I2C_SDA          21
#define I2C_SCL          22

// ================================================================
//  OBJECTS
// ================================================================
HardwareSerial RS485Serial(2);
WebServer      server(80);
BH1750         lightMeter;
bool           bh1750Ready = false;

// ================================================================
//  MODBUS & SENSOR STRUCTS
// ================================================================
static const uint8_t QUERY[] = { 0x01, 0x03, 0x00, 0x00, 0x00, 0x07, 0x04, 0x08 };

struct SoilData { float humidity, temperature, conductivity, ph; uint16_t nitrogen, phosphorus, potassium; bool valid; };
struct LightData { float lux; bool valid; };

SoilData  lastSoil  = {};
LightData lastLight = {};
uint32_t  readCount = 0;

uint16_t crc16(const uint8_t *data, uint8_t len) {
  uint16_t crc = 0xFFFF;
  for (uint8_t i = 0; i < len; i++) {
    crc ^= (uint16_t)data[i];
    for (uint8_t j = 0; j < 8; j++) crc = (crc & 1) ? (crc >> 1) ^ 0xA001 : crc >> 1;
  }
  return crc;
}

void sendQuery() {
  while (RS485Serial.available()) RS485Serial.read();
  digitalWrite(RS485_DE_RE_PIN, HIGH);
  delayMicroseconds(200);
  RS485Serial.write(QUERY, sizeof(QUERY));
  RS485Serial.flush();
  delayMicroseconds(200);
  digitalWrite(RS485_DE_RE_PIN, LOW);
}

SoilData readSoil() {
  SoilData data = {}; data.valid = false;
  uint8_t buf[25] = {}; uint8_t idx = 0;
  uint32_t start = millis();
  while (millis() - start < 1000) {
    while (RS485Serial.available() && idx < sizeof(buf)) buf[idx++] = RS485Serial.read();
    if (idx >= 19) break;
    delay(1);
  }
  if (idx < 19) return data;
  if (crc16(buf, idx - 2) != (((uint16_t)buf[idx-1] << 8) | buf[idx-2])) return data;
  if (buf[0] != 0x01 || buf[1] != 0x03 || buf[2] != 0x0E) return data;
  
  uint8_t *d = &buf[3];
  data.humidity     = ((d[0]  << 8) | d[1])  * 0.1f;
  data.temperature  = (int16_t)((d[2] << 8) | d[3]) * 0.1f;
  data.conductivity =  (d[4]  << 8) | d[5];
  data.ph           = ((d[6]  << 8) | d[7])  * 0.1f;
  data.nitrogen     =  (d[8]  << 8) | d[9];
  data.phosphorus   = (d[10]  << 8) | d[11];
  data.potassium    = (d[12]  << 8) | d[13];
  data.valid        = true;
  return data;
}

LightData readLight() {
  LightData light = {}; if (!bh1750Ready) { light.valid = false; return light; }
  float lux = lightMeter.readLightLevel();
  if (lux >= 0) { light.lux = lux; light.valid = true; } else light.valid = false;
  return light;
}

// ================================================================
//  API ENDPOINTS
// ================================================================

void handlePing() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "application/json", "{\"device\":\"urban_roots_soil\",\"status\":\"online\"}");
}

// ---> UPDATED handleData() FUNCTION <---
void handleData() {
  String json = "{";
  
  // Adjusted explicitly to exactly match the Flutter app expectations
  json += "\"moisture\":" + String(lastSoil.valid  ? lastSoil.humidity         : 0, 1) + ","; 
  json += "\"temp\":"     + String(lastSoil.valid  ? lastSoil.temperature      : 0, 1) + ",";
  json += "\"ec\":"       + String(lastSoil.valid  ? (int)lastSoil.conductivity: 0)    + ",";
  json += "\"ph\":"       + String(lastSoil.valid  ? lastSoil.ph               : 0, 1) + ",";
  json += "\"n\":"        + String(lastSoil.valid  ? lastSoil.nitrogen         : 0)    + ",";
  json += "\"p\":"        + String(lastSoil.valid  ? lastSoil.phosphorus       : 0)    + ",";
  json += "\"k\":"        + String(lastSoil.valid  ? lastSoil.potassium        : 0)    + ",";
  json += "\"light\":"    + String(lastLight.valid ? lastLight.lux             : 0, 1) + ",";
  
  json += "\"hum\":"      + String(lastSoil.valid  ? lastSoil.humidity         : 0, 1) + ",";
  json += "\"count\":"    + String(readCount);
  
  json += "}";
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "application/json", json);
}

// ================================================================
//  SETUP
// ================================================================
void setup() {
  Serial.begin(115200);
  delay(1000);

  // RS485 & I2C init
  pinMode(RS485_DE_RE_PIN, OUTPUT);
  digitalWrite(RS485_DE_RE_PIN, LOW);
  RS485Serial.begin(4800, SERIAL_8N1, RS485_RX_PIN, RS485_TX_PIN);
  
  Wire.begin(I2C_SDA, I2C_SCL);
  delay(200);
  if (lightMeter.begin(BH1750::CONTINUOUS_HIGH_RES_MODE, 0x23, &Wire) || 
      lightMeter.begin(BH1750::CONTINUOUS_HIGH_RES_MODE, 0x5C, &Wire)) {
    bh1750Ready = true;
  }

  // WiFi Connection
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) { delay(500); Serial.print("."); }
  Serial.println("\nConnected! IP: " + WiFi.localIP().toString());

  if (MDNS.begin(DEVICE_NAME)) {
    Serial.println("mDNS Responder Started: http://urbanroots.local");
  }

  // Define Server Routes
  server.on("/ping", handlePing);
  server.on("/data", handleData);
  server.begin();
}

// ================================================================
//  LOOP
// ================================================================
void loop() {
  server.handleClient();

  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi lost... Reconnecting");
    WiFi.disconnect();
    WiFi.reconnect();
    delay(5000); 
  }

  static uint32_t lastRead = 0;
  if (millis() - lastRead >= 2000) {
    lastRead = millis();
    sendQuery();
    delay(200);
    lastSoil  = readSoil();
    lastLight = readLight();
    readCount++;
    
    // ---> UPDATED Serial Monitor Print with EC & pH <---
    Serial.printf("H: %.1f | T: %.1f | NPK: %d,%d,%d | EC: %d | pH: %.1f | Lux: %.0f\n", 
                  lastSoil.humidity, lastSoil.temperature, 
                  lastSoil.nitrogen, lastSoil.phosphorus, lastSoil.potassium, 
                  (int)lastSoil.conductivity, lastSoil.ph,
                  lastLight.lux);
  }
}