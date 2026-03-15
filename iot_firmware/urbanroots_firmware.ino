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
  }
  else
  {
    Serial.println("Sensor read error");
  }

  delay(2000);
}