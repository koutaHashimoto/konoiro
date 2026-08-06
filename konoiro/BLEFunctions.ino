
// --------------------------------------------------------------------------------------------
// BLEの接続・切断のコールバック
// --------------------------------------------------------------------------------------------
class ServerCallbacks : public BLEServerCallbacks
{
  void onConnect(BLEServer* pServer)
  {
      Serial.println("connect");
      isBLEConnected = true;
  }

  void onDisconnect(BLEServer* pServer)
  {
      Serial.println("disconnect");
      isBLEConnected = false;
  }
};

class BLECallbacks : public BLECharacteristicCallbacks
{
  void onWrite(BLECharacteristic *pCharacteristic)
  {
    std::string value = pCharacteristic->getValue().c_str();    //.c_str()を追加
    String valueStr = value.c_str();
  }

  void onRead(BLECharacteristic *pCharacteristic)
  {
    String val = "";

    pCharacteristic->setValue(val.c_str());
  }
};

// --------------------------------------------------------------------------------------------
// BLE初期化
// --------------------------------------------------------------------------------------------
void setupBLE()
{
  uint8_t mac[6];
  esp_efuse_mac_get_default(mac);
  String deviceName = "bletest_";
  for (int i = 0; i < 6; i++)
  {
    char c[3];
    sprintf(c, "%02X", mac[i]);
    deviceName += String(c);
  }
  BLEDevice::init(deviceName.c_str());
  BLEServer *pServer = BLEDevice::createServer();
  pService = pServer->createService(BLEUUID(SERVICE_UUID), 60, 0);
  pServer->setCallbacks(new ServerCallbacks());

  setupCharacteristics();

  pService->start();
  pServer-> getAdvertising()-> addServiceUUID(BLEUUID(SERVICE_UUID)); 

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // functions that help with iPhone connections issue
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
}

void setupCharacteristics()
{
  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_NOTIFY
  );
  pCharacteristic->setValue("");
  pCharacteristic->setCallbacks(new BLECallbacks());
}