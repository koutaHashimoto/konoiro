#include <Wire.h>
#include "Adafruit_TCS34725.h"
#include <M5Unified.h>

//BLE用
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <esp_mac.h>  

#define SERVICE_UUID "4FAFC201-1FB5-459E-8FCC-C5C9C331914B"
#define CHARACTERISTIC_UUID "BEB5483E-36E1-4688-B7F5-EA07361B26A8"

Adafruit_TCS34725 tcs = Adafruit_TCS34725(TCS34725_INTEGRATIONTIME_50MS, TCS34725_GAIN_4X);
uint16_t r, g, b, c;

BLEService *pService = NULL;
BLECharacteristic *pCharacteristic = NULL;

bool isBLEConnected = false;
bool isBLEConnectedBack = false;

void setup(void) {
  Serial.begin(115200);
  Wire.begin(26, 32);
  auto cfg = M5.config();
  M5.begin(cfg);


  Serial.println("Initialize setup...");
  setupBLE();
  Serial.println("OK");

  Serial.println("Initializing complete");

  if (tcs.begin()) {
    Serial.println("Found sensor");
  } else {
    Serial.println("No TCS34725 found ... check your connections");
    while (1)
      ;
  }
}

void loop(void) {
  M5.update();  // update button state

  if (isBLEConnected && !isBLEConnectedBack)
  {
    Serial.println("Stop advertising");
    BLEDevice::stopAdvertising();
  }

  if (!isBLEConnected && isBLEConnectedBack)
  {
    Serial.println("Start advertising");
    BLEDevice::startAdvertising();
  }
  isBLEConnectedBack = isBLEConnected;


  if (M5.BtnA.wasClicked()) {
    // ① 3回の平均を取るための変数
    uint32_t sumR = 0, sumG = 0, sumB = 0, sumC = 0;
    uint16_t r, g, b, c;

    // 3回読み取って足す
    for (int i = 0; i < 3; i++) {
      tcs.getRawData(&r, &g, &b, &c);
      sumR += r;
      sumG += g;
      sumB += b;
      sumC += c;
      delay(60);  
    }

    // 平均を出す
    uint16_t avgR = sumR / 3;
    uint16_t avgG = sumG / 3;
    uint16_t avgB = sumB / 3;
    uint16_t avgC = sumC / 3;

    // ② センサーの値を一般的なRGB（0〜255）の範囲に変換
    uint8_t rgb8_r = 0, rgb8_g = 0, rgb8_b = 0;
    if (avgC > 0) {
      rgb8_r = min(255.0, max(0.0, avgR * 0.8));
      rgb8_g = min(255.0, max(0.0, avgG * 0.8));
      rgb8_b = min(255.0, max(0.0, avgB * 0.5));
    }

    Serial.printf("R:%d G:%d B:%d\n", rgb8_r, rgb8_g, rgb8_b);

    if (isBLEConnected) {
      String val = "R:" + String(rgb8_r) + " G:" + String(rgb8_g) + " B:" + String(rgb8_b);
      pCharacteristic->setValue(val.c_str());
      pCharacteristic->notify(); // iPadに送る！
      Serial.println("BLE Sent: " + val);
    } else {
      Serial.println("BLE not connected.");
    }
  }
}