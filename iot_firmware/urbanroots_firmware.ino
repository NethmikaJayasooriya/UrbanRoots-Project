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
uint32_t  readCount = 0;

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
//  SERIAL MONITOR INTERFACE
// ================================================================
void printSerialHeader() {
  Serial.println();
  Serial.println(F("╔══════════════════════════════════════════════╗"));
  Serial.println(F("║         SOIL & ENVIRONMENT MONITOR          ║"));
  Serial.println(F("║         ESP32 + 7in1 Sensor + BH1750        ║"));
  Serial.println(F("╚══════════════════════════════════════════════╝"));
  Serial.println();
}

void printSerialDivider() {
  Serial.println(F("┌──────────────────────────────────────────────┐"));
}

void printSerialFooter() {
  Serial.println(F("└──────────────────────────────────────────────┘"));
}

void printSerialData(const SoilData &soil, const LightData &light) {
  readCount++;

  // Get uptime
  uint32_t sec  = millis() / 1000;
  uint32_t min  = sec / 60;
  uint32_t hr   = min / 60;
  sec %= 60; min %= 60;

  printSerialDivider();
  Serial.printf("│  Reading #%-4lu        Uptime: %02lu:%02lu:%02lu      │\n",
                readCount, hr, min, sec);
  Serial.println(F("├──────────────────────────────────────────────┤"));
  Serial.println(F("│  SOIL PARAMETERS                             │"));
  Serial.println(F("├──────────────────────────────────────────────┤"));

  if (soil.valid) {
    // Humidity bar
    int humBar = (int)(soil.humidity / 100.0f * 20);
    String humBarStr = "[";
    for (int i = 0; i < 20; i++) humBarStr += (i < humBar) ? "#" : "-";
    humBarStr += "]";
    Serial.printf("│  Humidity     : %5.1f %%RH  %s │\n",
                  soil.humidity, humBarStr.c_str());

    // Temperature bar (0-50 range)
    int tempBar = (int)(soil.temperature / 50.0f * 20);
    tempBar = constrain(tempBar, 0, 20);
    String tempBarStr = "[";
    for (int i = 0; i < 20; i++) tempBarStr += (i < tempBar) ? "#" : "-";
    tempBarStr += "]";
    Serial.printf("│  Temperature  : %5.1f C     %s │\n",
                  soil.temperature, tempBarStr.c_str());

    // pH indicator
    String phStatus = "";
    if      (soil.ph < 5.5) phStatus = "ACIDIC  ";
    else if (soil.ph < 7.0) phStatus = "OPTIMAL ";
    else if (soil.ph < 8.0) phStatus = "ALKALINE";
    else                     phStatus = "HIGH    ";
    Serial.printf("│  pH           : %5.1f       Status: %s      │\n",
                  soil.ph, phStatus.c_str());

    // Conductivity
    Serial.printf("│  Conductivity : %5d uS/cm                  │\n",
                  (int)soil.conductivity);

    Serial.println(F("├──────────────────────────────────────────────┤"));
    Serial.println(F("│  NPK VALUES  (mg/kg)                         │"));
    Serial.println(F("├──────────────────────────────────────────────┤"));

    // NPK bars (0-200 range)
    int nBar = (int)(soil.nitrogen   / 200.0f * 20); nBar = constrain(nBar, 0, 20);
    int pBar = (int)(soil.phosphorus / 200.0f * 20); pBar = constrain(pBar, 0, 20);
    int kBar = (int)(soil.potassium  / 200.0f * 20); kBar = constrain(kBar, 0, 20);

    String nBarStr = "[";
    for (int i = 0; i < 20; i++) nBarStr += (i < nBar) ? "#" : "-";
    nBarStr += "]";
    String pBarStr = "[";
    for (int i = 0; i < 20; i++) pBarStr += (i < pBar) ? "#" : "-";
    pBarStr += "]";
    String kBarStr = "[";
    for (int i = 0; i < 20; i++) kBarStr += (i < kBar) ? "#" : "-";
    kBarStr += "]";

    Serial.printf("│  Nitrogen  (N): %5d    %s │\n",
                  soil.nitrogen,   nBarStr.c_str());
    Serial.printf("│  Phosphorus(P): %5d    %s │\n",
                  soil.phosphorus, pBarStr.c_str());
    Serial.printf("│  Potassium (K): %5d    %s │\n",
                  soil.potassium,  kBarStr.c_str());

  } else {
    Serial.println(F("│  Soil Sensor  : ERROR - check RS485 wiring  │"));
  }

  Serial.println(F("├──────────────────────────────────────────────┤"));
  Serial.println(F("│  LIGHT                                       │"));
  Serial.println(F("├──────────────────────────────────────────────┤"));

  if (light.valid) {
    // Light bar (0-100000 lux range)
    int luxBar = (int)(light.lux / 100000.0f * 20);
    luxBar = constrain(luxBar, 0, 20);
    String luxBarStr = "[";
    for (int i = 0; i < 20; i++) luxBarStr += (i < luxBar) ? "#" : "-";
    luxBarStr += "]";

    String luxStatus = "";
    if      (light.lux < 100)   luxStatus = "DARK    ";
    else if (light.lux < 1000)  luxStatus = "INDOOR  ";
    else if (light.lux < 10000) luxStatus = "CLOUDY  ";
    else                         luxStatus = "SUNNY   ";

    Serial.printf("│  Light        : %8.1f lux  %s      │\n",
                  light.lux, luxStatus.c_str());
  } else {
    Serial.println(F("│  Light Sensor : not connected                │"));
  }

  printSerialFooter();
  Serial.println();
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
  html += "h1{text-align:center;color:#1a1a2e;margin-bottom:6px;font-size:22px}";
  html += ".sub{text-align:center;color:#888;font-size:12px;margin-bottom:20px}";
  html += ".grid{display:grid;grid-template-columns:1fr 1fr;gap:12px;max-width:500px;margin:0 auto}";
  html += ".card{background:white;border-radius:14px;padding:16px;text-align:center;box-shadow:0 2px 8px rgba(0,0,0,0.08)}";
  html += ".label{font-size:11px;color:#888;margin-bottom:4px;text-transform:uppercase;letter-spacing:0.5px}";
  html += ".value{font-size:28px;font-weight:700;color:#1a1a2e}";
  html += ".unit{font-size:12px;color:#aaa;margin-top:2px}";
  html += ".badge{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;margin-top:4px}";
  html += ".hum .value{color:#0ea5e9}";
  html += ".temp .value{color:#f97316}";
  html += ".ph .value{color:#8b5cf6}";
  html += ".ec .value{color:#10b981}";
  html += ".nit .value{color:#3b82f6}";
  html += ".phos .value{color:#ef4444}";
  html += ".pot .value{color:#f59e0b}";
  html += ".lux .value{color:#eab308}";
  html += ".bar-wrap{background:#f0f4f8;border-radius:6px;height:6px;margin-top:8px;overflow:hidden}";
  html += ".bar{height:100%;border-radius:6px;transition:width 0.5s}";
  html += ".status{text-align:center;margin-top:16px;font-size:12px;color:#aaa}";
  html += ".dot{display:inline-block;width:8px;height:8px;background:#10b981;border-radius:50%;margin-right:6px;animation:pulse 1.5s infinite}";
  html += ".reads{text-align:center;font-size:11px;color:#bbb;margin-top:6px}";
  html += "@keyframes pulse{0%,100%{opacity:1}50%{opacity:0.4}}";
  html += "</style></head><body>";
  html += "<h1>Soil Monitor</h1>";
  html += "<div class='sub'>ESP32 + 7-in-1 RS485 + BH1750</div>";
  html += "<div class='grid'>";
  html += "<div class='card hum'><div class='label'>Humidity</div><div class='value' id='hum'>--</div><div class='unit'>%RH</div><div class='bar-wrap'><div class='bar' id='hum-bar' style='width:0%;background:#0ea5e9'></div></div></div>";
  html += "<div class='card temp'><div class='label'>Temperature</div><div class='value' id='temp'>--</div><div class='unit'>C</div><div class='bar-wrap'><div class='bar' id='temp-bar' style='width:0%;background:#f97316'></div></div></div>";
  html += "<div class='card ph'><div class='label'>pH</div><div class='value' id='ph'>--</div><div class='badge' id='ph-badge'>--</div></div>";
  html += "<div class='card ec'><div class='label'>Conductivity</div><div class='value' id='ec'>--</div><div class='unit'>uS/cm</div></div>";
  html += "<div class='card nit'><div class='label'>Nitrogen</div><div class='value' id='nit'>--</div><div class='unit'>mg/kg</div><div class='bar-wrap'><div class='bar' id='nit-bar' style='width:0%;background:#3b82f6'></div></div></div>";
  html += "<div class='card phos'><div class='label'>Phosphorus</div><div class='value' id='phos'>--</div><div class='unit'>mg/kg</div><div class='bar-wrap'><div class='bar' id='phos-bar' style='width:0%;background:#ef4444'></div></div></div>";
  html += "<div class='card pot'><div class='label'>Potassium</div><div class='value' id='pot'>--</div><div class='unit'>mg/kg</div><div class='bar-wrap'><div class='bar' id='pot-bar' style='width:0%;background:#f59e0b'></div></div></div>";
  html += "<div class='card lux'><div class='label'>Light</div><div class='value' id='lux'>--</div><div class='badge' id='lux-badge'>--</div></div>";
  html += "</div>";
  html += "<div class='status'><span class='dot'></span>Live - updates every 3 seconds</div>";
  html += "<div class='reads'>Total readings: <span id='reads'>0</span></div>";
  html += "<script>";
  html += "function phColor(v){if(v<5.5)return'#ef4444';if(v<7)return'#10b981';if(v<8)return'#f59e0b';return'#8b5cf6'}";
  html += "function phLabel(v){if(v<5.5)return'Acidic';if(v<7)return'Optimal';if(v<8)return'Alkaline';return'High'}";
  html += "function luxLabel(v){if(v<100)return'Dark';if(v<1000)return'Indoor';if(v<10000)return'Cloudy';return'Sunny'}";
  html += "function luxColor(v){if(v<100)return'#888';if(v<1000)return'#3b82f6';if(v<10000)return'#f59e0b';return'#eab308'}";
  html += "function update(){";
  html += "fetch('/data').then(r=>r.json()).then(d=>{";
  html += "document.getElementById('hum').textContent=d.hum;";
  html += "document.getElementById('hum-bar').style.width=Math.min(d.hum,100)+'%';";
  html += "document.getElementById('temp').textContent=d.temp;";
  html += "document.getElementById('temp-bar').style.width=Math.min(d.temp/50*100,100)+'%';";
  html += "document.getElementById('ph').textContent=d.ph;";
  html += "var pb=document.getElementById('ph-badge');pb.textContent=phLabel(d.ph);pb.style.background=phColor(d.ph)+'22';pb.style.color=phColor(d.ph);";
  html += "document.getElementById('ec').textContent=d.ec;";
  html += "document.getElementById('nit').textContent=d.n;";
  html += "document.getElementById('nit-bar').style.width=Math.min(d.n/200*100,100)+'%';";
  html += "document.getElementById('phos').textContent=d.p;";
  html += "document.getElementById('phos-bar').style.width=Math.min(d.p/200*100,100)+'%';";
  html += "document.getElementById('pot').textContent=d.k;";
  html += "document.getElementById('pot-bar').style.width=Math.min(d.k/200*100,100)+'%';";
  html += "document.getElementById('lux').textContent=d.lux;";
  html += "var lb=document.getElementById('lux-badge');lb.textContent=luxLabel(d.lux);lb.style.background=luxColor(d.lux)+'22';lb.style.color=luxColor(d.lux);";
  html += "document.getElementById('reads').textContent=d.count;";
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
  json += "\"hum\":"   + String(lastSoil.valid  ? lastSoil.humidity         : 0, 1) + ",";
  json += "\"temp\":"  + String(lastSoil.valid  ? lastSoil.temperature      : 0, 1) + ",";
  json += "\"ec\":"    + String(lastSoil.valid  ? (int)lastSoil.conductivity : 0)    + ",";
  json += "\"ph\":"    + String(lastSoil.valid  ? lastSoil.ph               : 0, 1) + ",";
  json += "\"n\":"     + String(lastSoil.valid  ? lastSoil.nitrogen         : 0)     + ",";
  json += "\"p\":"     + String(lastSoil.valid  ? lastSoil.phosphorus       : 0)     + ",";
  json += "\"k\":"     + String(lastSoil.valid  ? lastSoil.potassium        : 0)     + ",";
  json += "\"lux\":"   + String(lastLight.valid ? lastLight.lux             : 0, 1) + ",";
  json += "\"count\":" + String(readCount);
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

  printSerialHeader();

  // RS485
  pinMode(RS485_DE_RE_PIN, OUTPUT);
  digitalWrite(RS485_DE_RE_PIN, LOW);
  RS485Serial.begin(4800, SERIAL_8N1, RS485_RX_PIN, RS485_TX_PIN);
  Serial.println(F("  [RS485]  Ready at 4800 baud          OK"));

  // BH1750
  Wire.begin(I2C_SDA, I2C_SCL);
  delay(200);
  if (lightMeter.begin(BH1750::CONTINUOUS_HIGH_RES_MODE, 0x23, &Wire)) {
    bh1750Ready = true;
    Serial.println(F("  [BH1750] Found at 0x23               OK"));
  } else if (lightMeter.begin(BH1750::CONTINUOUS_HIGH_RES_MODE, 0x5C, &Wire)) {
    bh1750Ready = true;
    Serial.println(F("  [BH1750] Found at 0x5C               OK"));
  } else {
    Serial.println(F("  [BH1750] Not found - check wiring    --"));
  }

  // WiFi
  Serial.print(F("  [WiFi]   Connecting"));
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 40) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  Serial.println();
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println(F("  [WiFi]   Connected                   OK"));
    Serial.print(  F("  [WiFi]   IP Address : http://"));
    Serial.println(WiFi.localIP());
    Serial.print(  F("  [WiFi]   Signal     : "));
    Serial.print(WiFi.RSSI());
    Serial.println(F(" dBm"));
  } else {
    Serial.println(F("  [WiFi]   FAILED - check credentials  !!"));
  }

  server.on("/",     handleRoot);
  server.on("/data", handleData);
  server.begin();
  Serial.println(F("  [HTTP]   Web server started          OK"));
  Serial.println();
  Serial.println(F("  Open the IP address above in your phone browser"));
  Serial.println(F("  Data updates every 2 seconds"));
  Serial.println();
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
    readCount++;
    printSerialData(lastSoil, lastLight);
  }
}
