/*
  7-in-1 RS485 Soil Sensor + ESP32 + MAX485 + Bluetooth Classic (SPP)
  Streams sensor data over Bluetooth to any paired device / Serial terminal
  UART2: GPIO16=RX, GPIO17=TX | GPIO4=DE/RE | BT name: "SoilSensor"
*/

#include <Arduino.h>
#include <HardwareSerial.h>
#include "BluetoothSerial.h"   // Built-in ESP32 BT library

// ─── Check BT is enabled in SDK ────────────────────────────────────
#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
  #error Bluetooth is not enabled! Enable it in Arduino IDE → Tools → Partition Scheme
#endif

// ─── Pin definitions ───────────────────────────────────────────────
#define RS485_TX_PIN     17
#define RS485_RX_PIN     16
#define RS485_DE_RE_PIN   4

// ─── Objects ───────────────────────────────────────────────────────
HardwareSerial RS485Serial(2);
BluetoothSerial BT;

// ─── Modbus RTU query frame (addr 0x01, read 7 registers) ──────────
static const uint8_t QUERY[] = {
  0x01, 0x03, 0x00, 0x00, 0x00, 0x07, 0x04, 0x08
};

// ─── Sensor data structure ─────────────────────────────────────────
struct SoilData {
  float    humidity;      // %RH
  float    temperature;   // °C
  float    conductivity;  // µS/cm
  float    ph;
  uint16_t nitrogen;      // mg/kg
  uint16_t phosphorus;    // mg/kg
  uint16_t potassium;     // mg/kg
  bool     valid;
};

// ─── CRC16 Modbus ──────────────────────────────────────────────────
uint16_t crc16(const uint8_t *data, uint8_t len) {
  uint16_t crc = 0xFFFF;
  for (uint8_t i = 0; i < len; i++) {
    crc ^= (uint16_t)data[i];
    for (uint8_t j = 0; j < 8; j++) {
      crc = (crc & 1) ? (crc >> 1) ^ 0xA001 : crc >> 1;
    }
  }
  return crc;
}

// ─── Send Modbus query ─────────────────────────────────────────────
void sendQuery() {
  digitalWrite(RS485_DE_RE_PIN, HIGH);
  delayMicroseconds(100);
  RS485Serial.write(QUERY, sizeof(QUERY));
  RS485Serial.flush();
  delayMicroseconds(100);
  digitalWrite(RS485_DE_RE_PIN, LOW);
}

// ─── Read & parse sensor response ─────────────────────────────────
SoilData readSensor() {
  SoilData data = {};
  data.valid = false;

  uint8_t buf[25] = {};
  uint8_t idx = 0;
  uint32_t start = millis();

  while (millis() - start < 500) {
    while (RS485Serial.available() && idx < sizeof(buf))
      buf[idx++] = RS485Serial.read();
    if (idx >= 19) break;
    delay(1);
  }

  if (idx < 19) return data;

  uint16_t calcCRC = crc16(buf, idx - 2);
  uint16_t recvCRC = ((uint16_t)buf[idx-1] << 8) | buf[idx-2];
  if (calcCRC != recvCRC) return data;
  if (buf[0] != 0x01 || buf[1] != 0x03 || buf[2] != 0x0E) return data;

  uint8_t *d = &buf[3];
  data.humidity     = ((d[0]  << 8) | d[1])  * 0.1f;
  int16_t rawTemp   =  (d[2]  << 8) | d[3];
  data.temperature  = rawTemp * 0.1f;
  data.conductivity =  (d[4]  << 8) | d[5];
  data.ph           = ((d[6]  << 8) | d[7])  * 0.1f;
  data.nitrogen     =  (d[8]  << 8) | d[9];
  data.phosphorus   = (d[10]  << 8) | d[11];
  data.potassium    = (d[12]  << 8) | d[13];
  data.valid = true;
  return data;
}

// ─── Output to both USB Serial and Bluetooth ───────────────────────
// Helper: print to Serial + BT at the same time
void dualPrint(const String &s) {
  Serial.print(s);
  if (BT.connected()) BT.print(s);
}

void dualPrintln(const String &s) {
  Serial.println(s);
  if (BT.connected()) BT.println(s);
}

// ─── Send formatted human-readable data ────────────────────────────
void printData(const SoilData &d) {
  if (!d.valid) {
    dualPrintln("ERROR: No valid sensor response");
    return;
  }
  dualPrintln("==============================");
  dualPrintln("  Humidity     : " + String(d.humidity,    1) + " %RH");
  dualPrintln("  Temperature  : " + String(d.temperature, 1) + " C");
  dualPrintln("  Conductivity : " + String((int)d.conductivity) + " uS/cm");
  dualPrintln("  pH           : " + String(d.ph,          1));
  dualPrintln("  Nitrogen (N) : " + String(d.nitrogen)    + " mg/kg");
  dualPrintln("  Phosphorus(P): " + String(d.phosphorus)  + " mg/kg");
  dualPrintln("  Potassium (K): " + String(d.potassium)   + " mg/kg");
  dualPrintln("==============================");
}

// ─── Send compact CSV line (easier to parse in apps) ───────────────
void sendCSV(const SoilData &d) {
  if (!d.valid) return;
  // Format: HUM,TEMP,EC,PH,N,P,K
  String csv = String(d.humidity,    1) + "," +
               String(d.temperature, 1) + "," +
               String((int)d.conductivity)    + "," +
               String(d.ph,          1) + "," +
               String(d.nitrogen)           + "," +
               String(d.phosphorus)         + "," +
               String(d.potassium);
  if (BT.connected()) BT.println(csv);
}

// ─── Send JSON (for web/app integration) ───────────────────────────
void sendJSON(const SoilData &d) {
  if (!d.valid) return;
  String json = "{";
  json += "\"hum\":"  + String(d.humidity,    1) + ",";
  json += "\"temp\":" + String(d.temperature, 1) + ",";
  json += "\"ec\":"   + String((int)d.conductivity)    + ",";
  json += "\"ph\":"   + String(d.ph,          1) + ",";
  json += "\"n\":"    + String(d.nitrogen)           + ",";
  json += "\"p\":"    + String(d.phosphorus)         + ",";
  json += "\"k\":"    + String(d.potassium);
  json += "}";
  if (BT.connected()) BT.println(json);
}

// ─── Setup ─────────────────────────────────────────────────────────
void setup() {
  Serial.begin(115200);
  delay(500);

  pinMode(RS485_DE_RE_PIN, OUTPUT);
  digitalWrite(RS485_DE_RE_PIN, LOW);

  RS485Serial.begin(4800, SERIAL_8N1, RS485_RX_PIN, RS485_TX_PIN);

  // Start Bluetooth with device name
  BT.begin("SoilSensor");
  Serial.println("Bluetooth started — device name: SoilSensor");
  Serial.println("Pair and connect, then open a serial terminal.");
  Serial.println("Waiting for BT connection...");
}

// ─── Loop ──────────────────────────────────────────────────────────
void loop() {
  static bool wasConnected = false;
  bool isConnected = BT.connected();

  // Connection state change notifications
  if (isConnected && !wasConnected) {
    Serial.println("[BT] Client connected!");
    BT.println("SoilSensor connected. Streaming data...");
  }
  if (!isConnected && wasConnected) {
    Serial.println("[BT] Client disconnected.");
  }
  wasConnected = isConnected;

  // Read sensor
  sendQuery();
  delay(100);
  SoilData result = readSensor();

  // Always print to USB serial for debugging
  printData(result);

  // Send over Bluetooth — choose your preferred format:
  // Option A: Human-readable (good for BT terminal apps)
  printData(result);

  // Option B: CSV — uncomment to use instead
  // sendCSV(result);

  // Option C: JSON — uncomment to use instead
  // sendJSON(result);

  delay(2000);
}