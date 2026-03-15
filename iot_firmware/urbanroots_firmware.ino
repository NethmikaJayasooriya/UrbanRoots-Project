/*
  7-in-1 RS485 Soil Sensor + BH1750 Light Sensor + ESP32 + MAX485 + Bluetooth
  UART2: GPIO16=RX, GPIO17=TX | GPIO4=DE/RE
  I2C:   GPIO21=SDA, GPIO22=SCL
  BT name: SoilSensor
  Tools > Partition Scheme > Huge APP (3MB No OTA / 1MB SPIFFS)
*/

#include <Arduino.h>
#include <HardwareSerial.h>
#include <Wire.h>
#include <BH1750.h>
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
#define I2C_SDA          21
#define I2C_SCL          22

// ================================================================
//  OBJECTS
// ================================================================
HardwareSerial RS485Serial(2);
BluetoothSerial BT;
BH1750 lightMeter;

// ================================================================
//  MODBUS QUERY FRAME
// ================================================================
static const uint8_t QUERY[] = {
  0x01, 0x03, 0x00, 0x00, 0x00, 0x07, 0x04, 0x08
};

// ================================================================
//  SENSOR DATA STRUCTURES
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

struct LightData {
  float lux;
  bool  valid;
};

// ================================================================
//  BLUETOOTH CALLBACK
// ================================================================
void btCallback(esp_spp_cb_event_t event, esp_spp_cb_param_t *param) {
  if (event == ESP_SPP_SRV_OPEN_EVT)  Serial.println("[BT] Client connected");
  if (event == ESP_SPP_CLOSE_EVT)     Serial.println("[BT] Client disconnected");
  if (event == ESP_SPP_START_EVT)     Serial.println("[BT] SPP server started");
}

// ================================================================
//  CRC16 MODBUS
// ================================================================
uint16_t crc16(const uint8_t *data, uint8_t len) {
  uint16_t crc = 0xFFFF;
  for (uint8_t i = 0; i < len; i++) {
    crc ^= (uint16_t)data[i];
    for (uint8_t j = 0; j < 8; j++)
      crc = (crc & 1) ? (crc >> 1) ^ 0xA001 : crc >> 1;
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
//  READ SOIL SENSOR
// ================================================================
SoilData readSoil() {
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
    Serial.printf("[WARN] Soil: only %d bytes\n", idx);
    return data;
  }

  uint16_t calcCRC = crc16(buf, idx - 2);
  uint16_t recvCRC = ((uint16_t)buf[idx-1] << 8) | buf[idx-2];
  if (calcCRC != recvCRC) {
    Serial.println("[WARN] Soil: CRC mismatch");
    return data;
  }
  if (buf[0] != 0x01 || buf[1] != 0x03 || buf[2] != 0x0E) {
    Serial.println("[WARN] Soil: bad header");
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
//  READ BH1750 LIGHT SENSOR
// ================================================================
LightData readLight() {
  LightData light = {};
  float lux = lightMeter.readLightLevel();
  if (lux >= 0) {
    light.lux   = lux;
    light.valid = true;
  } else {
    Serial.println("[WARN] BH1750: read failed");
    light.valid = false;
  }
  return light;
}

// ================================================================
//  DUAL OUTPUT - USB SERIAL + BLUETOOTH
// ================================================================
void dualPrintln(const String &s) {
  Serial.println(s);
  if (BT.connected()) BT.println(s);
}

// ================================================================
//  HUMAN READABLE OUTPUT
// ================================================================
void printReadable(const SoilData &soil, const LightData &light) {
  dualPrintln("==============================");
  if (soil.valid) {
    dualPrintln("  Humidity     : " + String(soil.humidity,    1) + " %RH");
    dualPrintln("  Temperature  : " + String(soil.temperature, 1) + " C");
    dualPrintln("  Conductivity : " + String((int)soil.conductivity) + " uS/cm");
    dualPrintln("  pH           : " + String(soil.ph,          1));
    dualPrintln("  Nitrogen (N) : " + String(soil.nitrogen)    + " mg/kg");
    dualPrintln("  Phosphorus(P): " + String(soil.phosphorus)  + " mg/kg");
    dualPrintln("  Potassium (K): " + String(soil.potassium)   + " mg/kg");
  } else {
    dualPrintln("  Soil sensor  : ERROR");
  }
  if (light.valid) {
    dualPrintln("  Light        : " + String(light.lux, 1) + " lux");
  } else {
    dualPrintln("  Light sensor : ERROR");
  }
  dualPrintln("==============================");
}

// ================================================================
//  CSV OUTPUT  (uncomment in loop to use)
//  Format: HUM,TEMP,EC,PH,N,P,K,LUX
// ================================================================
void sendCSV(const SoilData &soil, const LightData &light) {
  if (!BT.connected()) return;
  String csv = String(soil.valid ? soil.humidity    : 0, 1) + "," +
               String(soil.valid ? soil.temperature : 0, 1) + "," +
               String(soil.valid ? (int)soil.conductivity : 0) + "," +
               String(soil.valid ? soil.ph          : 0, 1) + "," +
               String(soil.valid ? soil.nitrogen    : 0) + "," +
               String(soil.valid ? soil.phosphorus  : 0) + "," +
               String(soil.valid ? soil.potassium   : 0) + "," +
               String(light.valid ? light.lux       : 0, 1);
  BT.println(csv);
  Serial.println("CSV: " + csv);
}

// ================================================================
//  JSON OUTPUT  (uncomment in loop to use)
// ================================================================
void sendJSON(const SoilData &soil, const LightData &light) {
  if (!BT.connected()) return;
  String json = "{";
  json += "\"hum\":"  + String(soil.valid ? soil.humidity    : 0, 1) + ",";
  json += "\"temp\":" + String(soil.valid ? soil.temperature : 0, 1) + ",";
  json += "\"ec\":"   + String(soil.valid ? (int)soil.conductivity : 0) + ",";
  json += "\"ph\":"   + String(soil.valid ? soil.ph          : 0, 1) + ",";
  json += "\"n\":"    + String(soil.valid ? soil.nitrogen    : 0) + ",";
  json += "\"p\":"    + String(soil.valid ? soil.phosphorus  : 0) + ",";
  json += "\"k\":"    + String(soil.valid ? soil.potassium   : 0) + ",";
  json += "\"lux\":"  + String(light.valid ? light.lux       : 0, 1);
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
  Serial.println("  Soil + Light + BT System   ");
  Serial.println("==============================");

  // RS485
  pinMode(RS485_DE_RE_PIN, OUTPUT);
  digitalWrite(RS485_DE_RE_PIN, LOW);
  RS485Serial.begin(4800, SERIAL_8N1, RS485_RX_PIN, RS485_TX_PIN);
  Serial.println("[RS485] Ready at 4800 baud");

  // BH1750 via I2C
  Wire.begin(I2C_SDA, I2C_SCL);
  if (lightMeter.begin(BH1750::CONTINUOUS_HIGH_RES_MODE)) {
    Serial.println("[BH1750] Ready");
  } else {
    Serial.println("[BH1750] NOT found - check wiring!");
  }

  // Bluetooth
  BT.register_callback(btCallback);
  if (!BT.begin("SoilSensor", false)) {
    Serial.println("[BT] FAILED - check partition scheme!");
    while (1) delay(500);
  }
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
    BT.println("SoilSensor + Light ready. Streaming...");
  }
  if (!isConnected && wasConnected) {
    Serial.println("[BT] Phone disconnected.");
  }
  wasConnected = isConnected;

  // Read both sensors
  sendQuery();
  delay(100);
  SoilData soil   = readSoil();
  LightData light = readLight();

  // Option A: Human readable (default)
  printReadable(soil, light);

  // Option B: CSV - uncomment to use
  // sendCSV(soil, light);

  // Option C: JSON - uncomment to use
  // sendJSON(soil, light);

  delay(2000);
}