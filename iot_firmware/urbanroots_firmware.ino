/*
  7-in-1 RS485 Soil Sensor + ESP32 + MAX485 + Bluetooth Classic (SPP)
  Fixed for Android 12/13/14/16 connection issues
  Tools > Partition Scheme > Huge APP (3MB No OTA / 1MB SPIFFS)
*/

#include <Arduino.h>
#include <HardwareSerial.h>
#include "BluetoothSerial.h"

#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
  #error Bluetooth not enabled! Set Tools > Partition Scheme > Huge APP
#endif

// ================================================================
//  PIN DEFINITIONS
// ================================================================
#define RS485_TX_PIN     17
#define RS485_RX_PIN     16
#define RS485_DE_RE_PIN   4

// ================================================================
//  OBJECTS
// ================================================================
HardwareSerial RS485Serial(2);
BluetoothSerial BT;

// ================================================================
//  MODBUS QUERY FRAME
// ================================================================
static const uint8_t QUERY[] = {
  0x01, 0x03, 0x00, 0x00, 0x00, 0x07, 0x04, 0x08
};

// ================================================================
//  SENSOR DATA STRUCTURE
// ================================================================
struct SoilData {
  float    humidity;
  float    temperature;
  float    conductivity;
  float    ph;
  uint16_t nitrogen;
  uint16_t phosphorus;
  uint16_t potassium;
  bool     valid;
};

// ================================================================
//  BLUETOOTH CALLBACK - handles Android 12+ auth requests
// ================================================================
void btCallback(esp_spp_cb_event_t event, esp_spp_cb_param_t *param) {
  if (event == ESP_SPP_SRV_OPEN_EVT) {
    Serial.println("[BT] Client connected via SPP");
  }
  if (event == ESP_SPP_CLOSE_EVT) {
    Serial.println("[BT] Client disconnected");
  }
  if (event == ESP_SPP_START_EVT) {
    Serial.println("[BT] SPP server started");
  }
}

// ================================================================
//  CRC16 MODBUS
// ================================================================
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

// ================================================================
//  SEND MODBUS QUERY
// ================================================================
void sendQuery() {
  digitalWrite(RS485_DE_RE_PIN, HIGH);
  delayMicroseconds(100);
  RS485Serial.write(QUERY, sizeof(QUERY));
  RS485Serial.flush();
  delayMicroseconds(100);
  digitalWrite(RS485_DE_RE_PIN, LOW);
}

// ================================================================
//  READ AND PARSE SENSOR
// ================================================================
SoilData readSensor() {
  SoilData data = {};
  data.valid = false;

  uint8_t  buf[25] = {};
  uint8_t  idx     = 0;
  uint32_t start   = millis();

  while (millis() - start < 500) {
    while (RS485Serial.available() && idx < sizeof(buf))
      buf[idx++] = RS485Serial.read();
    if (idx >= 19) break;
    delay(1);
  }

  if (idx < 19) {
    Serial.printf("[WARN] Only %d bytes received\n", idx);
    return data;
  }

  uint16_t calcCRC = crc16(buf, idx - 2);
  uint16_t recvCRC = ((uint16_t)buf[idx - 1] << 8) | buf[idx - 2];
  if (calcCRC != recvCRC) {
    Serial.printf("[WARN] CRC mismatch: calc=0x%04X recv=0x%04X\n", calcCRC, recvCRC);
    return data;
  }

  if (buf[0] != 0x01 || buf[1] != 0x03 || buf[2] != 0x0E) {
    Serial.println("[WARN] Unexpected response header");
    return data;
  }

  uint8_t *d        = &buf[3];
  data.humidity     = ((d[0]  << 8) | d[1])  * 0.1f;
  int16_t rawTemp   =  (d[2]  << 8) | d[3];
  data.temperature  = rawTemp * 0.1f;
  data.conductivity =  (d[4]  << 8) | d[5];
  data.ph           = ((d[6]  << 8) | d[7])  * 0.1f;
  data.nitrogen     =  (d[8]  << 8) | d[9];
  data.phosphorus   = (d[10]  << 8) | d[11];
  data.potassium    = (d[12]  << 8) | d[13];
  data.valid        = true;

  return data;
}

// ================================================================
//  DUAL OUTPUT
// ================================================================
void dualPrintln(const String &s) {
  Serial.println(s);
  if (BT.connected()) BT.println(s);
}

// ================================================================
//  HUMAN READABLE
// ================================================================
void printReadable(const SoilData &d) {
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

// ================================================================
//  CSV  (uncomment in loop to use)
// ================================================================
void sendCSV(const SoilData &d) {
  if (!d.valid || !BT.connected()) return;
  String csv = String(d.humidity,    1) + "," +
               String(d.temperature, 1) + "," +
               String((int)d.conductivity)   + "," +
               String(d.ph,          1) + "," +
               String(d.nitrogen)          + "," +
               String(d.phosphorus)        + "," +
               String(d.potassium);
  BT.println(csv);
  Serial.println("CSV: " + csv);
}

// ================================================================
//  JSON  (uncomment in loop to use)
// ================================================================
void sendJSON(const SoilData &d) {
  if (!d.valid || !BT.connected()) return;
  String json = "{";
  json += "\"hum\":"  + String(d.humidity,    1) + ",";
  json += "\"temp\":" + String(d.temperature, 1) + ",";
  json += "\"ec\":"   + String((int)d.conductivity)   + ",";
  json += "\"ph\":"   + String(d.ph,          1) + ",";
  json += "\"n\":"    + String(d.nitrogen)          + ",";
  json += "\"p\":"    + String(d.phosphorus)        + ",";
  json += "\"k\":"    + String(d.potassium);
  json += "}";
  BT.println(json);
  Serial.println("JSON: " + json);
}

// ================================================================
//  SETUP
// ================================================================
void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println("==============================");
  Serial.println("  Soil Sensor ESP32 + BT      ");
  Serial.println("==============================");

  pinMode(RS485_DE_RE_PIN, OUTPUT);
  digitalWrite(RS485_DE_RE_PIN, LOW);

  RS485Serial.begin(4800, SERIAL_8N1, RS485_RX_PIN, RS485_TX_PIN);
  Serial.println("[RS485] Ready at 4800 baud");

  // Register callback BEFORE BT.begin
  BT.register_callback(btCallback);

  // Start as slave (phone connects to ESP32)
  if (!BT.begin("SoilSensor", false)) {
    Serial.println("[BT] FAILED to start - check partition scheme!");
    while (1) delay(500);
  }

  // Allow insecure connections - critical for Android 12+
  esp_bt_gap_set_scan_mode(ESP_BT_CONNECTABLE, ESP_BT_GENERAL_DISCOVERABLE);

  Serial.println("[BT] Started - device name: SoilSensor");
  Serial.println("[BT] Waiting for phone to connect...");
}

// ================================================================
//  LOOP
// ================================================================
void loop() {
  static bool wasConnected = false;
  bool isConnected = BT.connected();

  if (isConnected && !wasConnected) {
    Serial.println("[BT] Phone connected!");
    BT.println("SoilSensor ready. Streaming data...");
  }
  if (!isConnected && wasConnected) {
    Serial.println("[BT] Phone disconnected.");
  }
  wasConnected = isConnected;

  sendQuery();
  delay(100);
  SoilData result = readSensor();

  // Option A: Human readable (default)
  printReadable(result);

  // Option B: CSV - uncomment to use
  // sendCSV(result);

  // Option C: JSON - uncomment to use
  // sendJSON(result);

  delay(2000);
}