/*
  7-in-1 RS485 Soil Sensor + ESP32 + MAX485
  Reads: Temperature, Humidity, EC, pH, Nitrogen, Phosphorus, Potassium
  UART2 on ESP32 (GPIO16=RX, GPIO17=TX), GPIO4 = DE/RE control
*/

#include <Arduino.h>
#include <HardwareSerial.h>

// ─── Pin definitions ───────────────────────────────────────────────
#define RS485_TX_PIN    17
#define RS485_RX_PIN    16
#define RS485_DE_RE_PIN  4   // Drive Enable / Receive Enable (tied together)

// ─── Serial port ───────────────────────────────────────────────────
HardwareSerial RS485Serial(2);  // UART2

// ─── Modbus RTU query frame for address 0x01 ───────────────────────
// Read holding registers 0x0000–0x0006 (7 registers)
static const uint8_t QUERY[] = {
  0x01,        // Device address
  0x03,        // Function code: Read Holding Registers
  0x00, 0x00,  // Start register: 0x0000
  0x00, 0x07,  // Number of registers: 7
  0x04, 0x08   // CRC16 (little-endian)
};

// ─── Sensor data structure ─────────────────────────────────────────
struct SoilData {
  float humidity;      // %RH
  float temperature;   // °C
  float conductivity;  // µS/cm
  float ph;            // pH
  uint16_t nitrogen;   // mg/kg
  uint16_t phosphorus; // mg/kg
  uint16_t potassium;  // mg/kg
  bool valid;
};

// ─── CRC16 Modbus ──────────────────────────────────────────────────
uint16_t crc16(const uint8_t *data, uint8_t len) {
  uint16_t crc = 0xFFFF;
  for (uint8_t i = 0; i < len; i++) {
    crc ^= (uint16_t)data[i];
    for (uint8_t j = 0; j < 8; j++) {
      if (crc & 0x0001) crc = (crc >> 1) ^ 0xA001;
      else              crc >>= 1;
    }
  }
  return crc;
}

// ─── Send Modbus query ─────────────────────────────────────────────
void sendQuery() {
  digitalWrite(RS485_DE_RE_PIN, HIGH);   // Enable transmit
  delayMicroseconds(100);
  RS485Serial.write(QUERY, sizeof(QUERY));
  RS485Serial.flush();                   // Wait until TX complete
  delayMicroseconds(100);
  digitalWrite(RS485_DE_RE_PIN, LOW);    // Enable receive
}

// ─── Read & parse response ─────────────────────────────────────────
SoilData readSensor() {
  SoilData data = {};
  data.valid = false;

  uint8_t buf[25] = {};
  uint8_t idx = 0;
  uint32_t start = millis();

  // Expected response: addr(1) + fn(1) + byte_count(1) + 14 data bytes + CRC(2) = 19 bytes
  while (millis() - start < 500) {
    while (RS485Serial.available() && idx < sizeof(buf)) {
      buf[idx++] = RS485Serial.read();
    }
    if (idx >= 19) break;
    delay(1);
  }

  if (idx < 19) {
    Serial.printf("[WARN] Only %d bytes received\n", idx);
    return data;
  }

  // Validate CRC
  uint16_t calcCRC  = crc16(buf, idx - 2);
  uint16_t recvCRC  = (uint16_t)(buf[idx - 1] << 8) | buf[idx - 2];
  if (calcCRC != recvCRC) {
    Serial.printf("[WARN] CRC mismatch: calc=0x%04X recv=0x%04X\n", calcCRC, recvCRC);
    return data;
  }

  // Validate header
  if (buf[0] != 0x01 || buf[1] != 0x03 || buf[2] != 0x0E) {
    Serial.println("[WARN] Unexpected response header");
    return data;
  }

  // Parse registers (each register = 2 bytes, big-endian)
  // Reg 0: Humidity    × 0.1 → %RH
  // Reg 1: Temperature × 0.1 → °C  (signed)
  // Reg 2: Conductivity → µS/cm
  // Reg 3: pH          × 0.1
  // Reg 4: Nitrogen    → mg/kg
  // Reg 5: Phosphorus  → mg/kg
  // Reg 6: Potassium   → mg/kg

  uint8_t* d = &buf[3];  // Start of data payload

  data.humidity     = ((d[0] << 8) | d[1])  * 0.1f;
  int16_t rawTemp   =  (d[2] << 8) | d[3];
  data.temperature  = rawTemp * 0.1f;
  data.conductivity =  (d[4] << 8) | d[5];
  data.ph           = ((d[6] << 8) | d[7])  * 0.1f;
  data.nitrogen     =  (d[8] << 8) | d[9];
  data.phosphorus   = (d[10] << 8) | d[11];
  data.potassium    = (d[12] << 8) | d[13];
  data.valid = true;

  return data;
}

// ─── Print results ─────────────────────────────────────────────────
void printData(const SoilData& d) {
  if (!d.valid) {
    Serial.println("No valid data.");
    return;
  }
  Serial.println("──────────────────────────────");
  Serial.printf("  Humidity     : %.1f %%RH\n",    d.humidity);
  Serial.printf("  Temperature  : %.1f °C\n",       d.temperature);
  Serial.printf("  Conductivity : %d µS/cm\n",      (int)d.conductivity);
  Serial.printf("  pH           : %.1f\n",           d.ph);
  Serial.printf("  Nitrogen (N) : %d mg/kg\n",      d.nitrogen);
  Serial.printf("  Phosphorus(P): %d mg/kg\n",      d.phosphorus);
  Serial.printf("  Potassium (K): %d mg/kg\n",      d.potassium);
  Serial.println("──────────────────────────────");
}

// ─── Setup ─────────────────────────────────────────────────────────
void setup() {
  Serial.begin(115200);
  delay(500);
  Serial.println("7-in-1 Soil Sensor — ESP32 + MAX485");

  pinMode(RS485_DE_RE_PIN, OUTPUT);
  digitalWrite(RS485_DE_RE_PIN, LOW);  // Default: receive mode

  RS485Serial.begin(4800, SERIAL_8N1, RS485_RX_PIN, RS485_TX_PIN);
  delay(100);
  Serial.println("Ready.");
}

// ─── Loop ──────────────────────────────────────────────────────────
void loop() {
  sendQuery();
  delay(100);  // Give sensor time to respond

  SoilData result = readSensor();
  printData(result);

  delay(2000);  // Poll every 2 seconds
}