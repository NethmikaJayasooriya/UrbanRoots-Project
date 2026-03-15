/*
  7-in-1 RS485 Soil Sensor + BH1750 + ESP32 + WiFi Web Dashboard
*/

#include <Arduino.h>
#include <HardwareSerial.h>
#include <Wire.h>
#include <BH1750.h>
#include <WiFi.h>
#include <WebServer.h>

// ================================================================
//  CHANGE THESE TO YOUR WIFI NAME AND PASSWORD
// ================================================================
const char* WIFI_SSID     = "WiFiName";
const char* WIFI_PASSWORD = "WiFiPassword";

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

SoilData  lastSoil  = {};
LightData lastLight = {};

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
  while (RS485Serial.available()) RS485Serial.read();
  digitalWrite(RS485_DE_RE_PIN, HIGH);
  delayMicroseconds(200);
  RS485Serial.write(QUERY, sizeof(QUERY));
  RS485Serial.flush();
  delayMicroseconds(200);
  digitalWrite(RS485_DE_RE_PIN, LOW);
}

// ================================================================
//  READ SOIL SENSOR
// ================================================================
SoilData readSoil() {
  SoilData data = {};
  data.valid = false;
  uint8_t  buf[25] = {};
  uint8_t  idx = 0;
  uint32_t start = millis();
  while (millis() - start < 1000) {
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
//  READ BH1750
// ================================================================
LightData readLight() {
  LightData light = {};
  if (!bh1750Ready) { light.valid = false; return light; }
  float lux = lightMeter.readLightLevel();
  if (lux >= 0) { light.lux = lux; light.valid = true; }
  else           { light.valid = false; }
  return light;
}

// ================================================================
//  WEB DASHBOARD
// ================================================================
void handleRoot() {
  String html = "<!DOCTYPE html><html><head>";
  html += "<meta charset='UTF-8'>";
  html += "<meta name='viewport' content='width=device-width,initial-scale=1'>";
  html += "<title>Soil Monitor</title>";
  html += "<style>";
  html += "*{box-sizing:border-box;margin:0;padding:0}";
  html += "body{font-family:sans-serif;background:#f0f4f8;padding:16px}";
  html += "h1{text-align:center;color:#1a1a2e;margin-bottom:20px;font-size:22px}";
  html += ".grid{display:grid;grid-template-columns:1fr 1fr;gap:12px;max-width:500px;margin:0 auto}";
  html += ".card{background:white;border-radius:14px;padding:16px;text-align:center;box-shadow:0 2px 8px rgba(0,0,0,0.08)}";
  html += ".label{font-size:12px;color:#888;margin-bottom:4px;text-transform:uppercase}";
  html += ".value{font-size:28px;font-weight:700;color:#1a1a2e}";
  html += ".unit{font-size:13px;color:#aaa;margin-top:2px}";
  html += ".hum .value{color:#0ea5e9}";
  html += ".temp .value{color:#f97316}";
  html += ".ph .value{color:#8b5cf6}";
  html += ".ec .value{color:#10b981}";
  html += ".nit .value{color:#3b82f6}";
  html += ".phos .value{color:#ef4444}";
  html += ".pot .value{color:#f59e0b}";
  html += ".lux .value{color:#eab308}";
  html += ".status{text-align:center;margin-top:16px;font-size:12px;color:#aaa}";
  html += ".dot{display:inline-block;width:8px;height:8px;background:#10b981;border-radius:50%;margin-right:6px;animation:pulse 1.5s infinite}";
  html += "@keyframes pulse{0%,100%{opacity:1}50%{opacity:0.4}}";
  html += "</style></head><body>";
  html += "<h1>Soil Monitor</h1>";
  html += "<div class='grid'>";
  html += "<div class='card hum'><div class='label'>Humidity</div><div class='value' id='hum'>--</div><div class='unit'>%RH</div></div>";
  html += "<div class='card temp'><div class='label'>Temperature</div><div class='value' id='temp'>--</div><div class='unit'>C</div></div>";
  html += "<div class='card ph'><div class='label'>pH</div><div class='value' id='ph'>--</div><div class='unit'>pH</div></div>";
  html += "<div class='card ec'><div class='label'>Conductivity</div><div class='value' id='ec'>--</div><div class='unit'>uS/cm</div></div>";
  html += "<div class='card nit'><div class='label'>Nitrogen</div><div class='value' id='nit'>--</div><div class='unit'>mg/kg</div></div>";
  html += "<div class='card phos'><div class='label'>Phosphorus</div><div class='value' id='phos'>--</div><div class='unit'>mg/kg</div></div>";
  html += "<div class='card pot'><div class='label'>Potassium</div><div class='value' id='pot'>--</div><div class='unit'>mg/kg</div></div>";
  html += "<div class='card lux'><div class='label'>Light</div><div class='value' id='lux'>--</div><div class='unit'>lux</div></div>";
  html += "</div>";
  html += "<div class='status'><span class='dot'></span>Live - updates every 3 seconds</div>";
  html += "<script>";
  html += "function update(){";
  html += "fetch('/data').then(r=>r.json()).then(d=>{";
  html += "document.getElementById('hum').textContent=d.hum;";
  html += "document.getElementById('temp').textContent=d.temp;";
  html += "document.getElementById('ph').textContent=d.ph;";
  html += "document.getElementById('ec').textContent=d.ec;";
  html += "document.getElementById('nit').textContent=d.n;";
  html += "document.getElementById('phos').textContent=d.p;";
  html += "document.getElementById('pot').textContent=d.k;";
  html += "document.getElementById('lux').textContent=d.lux;";
  html += "});}";
  html += "update();setInterval(update,3000);";
  html += "</script></body></html>";
  server.send(200, "text/html", html);
}

// ================================================================
//  JSON DATA ENDPOINT
// ================================================================
void handleData() {
  String json = "{";
  json += "\"hum\":"  + String(lastSoil.valid  ? lastSoil.humidity         : 0, 1) + ",";
  json += "\"temp\":" + String(lastSoil.valid  ? lastSoil.temperature      : 0, 1) + ",";
  json += "\"ec\":"   + String(lastSoil.valid  ? (int)lastSoil.conductivity: 0)     + ",";
  json += "\"ph\":"   + String(lastSoil.valid  ? lastSoil.ph               : 0, 1) + ",";
  json += "\"n\":"    + String(lastSoil.valid  ? lastSoil.nitrogen         : 0)     + ",";
  json += "\"p\":"    + String(lastSoil.valid  ? lastSoil.phosphorus       : 0)     + ",";
  json += "\"k\":"    + String(lastSoil.valid  ? lastSoil.potassium        : 0)     + ",";
  json += "\"lux\":"  + String(lastLight.valid ? lastLight.lux             : 0, 1);
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

  Serial.println("==============================");
  Serial.println("  Soil + Light + WiFi System ");
  Serial.println("==============================");

  // RS485
  pinMode(RS485_DE_RE_PIN, OUTPUT);
  digitalWrite(RS485_DE_RE_PIN, LOW);
  RS485Serial.begin(4800, SERIAL_8N1, RS485_RX_PIN, RS485_TX_PIN);
  Serial.println("[RS485] Ready");

  // BH1750
  Wire.begin(I2C_SDA, I2C_SCL);
  delay(200);
  if (lightMeter.begin(BH1750::CONTINUOUS_HIGH_RES_MODE, 0x23, &Wire)) {
    bh1750Ready = true;
    Serial.println("[BH1750] Ready at 0x23");
  } else if (lightMeter.begin(BH1750::CONTINUOUS_HIGH_RES_MODE, 0x5C, &Wire)) {
    bh1750Ready = true;
    Serial.println("[BH1750] Ready at 0x5C");
  } else {
    Serial.println("[BH1750] Not found - check wiring");
  }

  // WiFi
  Serial.print("[WiFi] Connecting to ");
  Serial.println(WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 40) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  Serial.println();
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("[WiFi] Connected!");
    Serial.print("[WiFi] Open on phone: http://");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("[WiFi] FAILED - check SSID and password!");
  }

  // Web server
  server.on("/",     handleRoot);
  server.on("/data", handleData);
  server.begin();
  Serial.println("[HTTP] Server started");
}

// ================================================================
//  LOOP
// ================================================================
void loop() {
  server.handleClient();

  static uint32_t lastRead = 0;
  if (millis() - lastRead >= 2000) {
    lastRead = millis();
    sendQuery();
    delay(200);
    lastSoil  = readSoil();
    lastLight = readLight();
    Serial.printf("Hum:%.1f Temp:%.1f EC:%d pH:%.1f N:%d P:%d K:%d Lux:%.1f\n",
      lastSoil.valid  ? lastSoil.humidity          : 0,
      lastSoil.valid  ? lastSoil.temperature       : 0,
      lastSoil.valid  ? (int)lastSoil.conductivity : 0,
      lastSoil.valid  ? lastSoil.ph                : 0,
      lastSoil.valid  ? lastSoil.nitrogen          : 0,
      lastSoil.valid  ? lastSoil.phosphorus        : 0,
      lastSoil.valid  ? lastSoil.potassium         : 0,
      lastLight.valid ? lastLight.lux              : 0
    );
  }
}
