/*********************************************************************
 Code adapted from  nRF52 based Bluefruit LE modules under MIT license

 Pick one up today in the adafruit shop!

 Adafruit invests time and resources providing this open source code,
 please support Adafruit and open-source hardware by purchasing
 products from Adafruit!

 MIT license, check LICENSE for more information
 All text above, and the splash screen below must be included in
 any redistribution
*********************************************************************/
#include <bluefruit.h>
#include <Adafruit_LittleFS.h>
#include <InternalFileSystem.h>
#include "LSM6DS3.h"
#include "Wire.h"

/* IMU Ref:
https://wiki.seeedstudio.com/Grove-6-Axis_AccelerometerAndGyroscope/
*/

/*============ VARIABLES ============*/
// BLE Service
BLEDfu  bledfu;  // OTA DFU service   // over the air device firm update
BLEDis  bledis;  // device information
BLEUart bleuart; // uart over ble
BLEBas  blebas;  // battery

// BLE data
uint8_t send_buffer[12];
uint8_t rec_buffer[2];


// Motor control pin assignments
struct MotorPins {
  int speedPin; //speed
  int dirPin; 
  int brakePin;
};
MotorPins motor = {3,4,5}; // the latest pins are 1, 2, 3

// IMU
LSM6DS3 myIMU(I2C_MODE, 0x6A); 

/**************************/
/* Bluetooth UART helpers */
/**************************/
// callback invoked when central connects
void connect_callback(uint16_t conn_handle)
{
  // Get the reference to current connection
  BLEConnection* connection = Bluefruit.Connection(conn_handle);

  char central_name[32] = { 0 };
  connection->getPeerName(central_name, sizeof(central_name));

  Serial.print("Connected to ");
  Serial.println(central_name);
}

/**
 * Callback invoked when a connection is dropped
 * @param conn_handle connection where this event happens
 * @param reason is a BLE_HCI_STATUS_CODE which can be found in ble_hci.h
 */
void disconnect_callback(uint16_t conn_handle, uint8_t reason)
{
  (void) conn_handle;
  (void) reason;
  Serial.println();
  Serial.print("Disconnected, reason = 0x"); Serial.println(reason, HEX);
 /*
  0x08: "REMOTE USER TERMINATED CONNECTION"
  The remote device (the central or client) explicitly terminated the connection.
  0x13: "REMOTE DEVICE TERMINATED CONNECTION DUE TO POWER OFF"
  The remote device (the central or client) terminated the connection because it powered off.
  0x16: "UNACCEPTABLE CONNECTION INTERVAL"
  The connection interval between the devices was not within an acceptable range.
  0x1A: "REMOTE DEVICE TERMINATED CONNECTION DUE TO LOW RESOURCES"
  The remote device (the central or client) terminated the connection due to low resources.
  0x3E: "PAIRING/ENCRYPTION FAILED"
  The pairing or encryption process failed during the connection.
  0x61: "MIC FAILURE"
  The Message Integrity Check (MIC) failed during data transmission, indicating a potential security issue.
 */ 
}

void initBLE(void) {
  Bluefruit.configPrphBandwidth(BANDWIDTH_MAX);
  // All configs need to be before begin()
  Bluefruit.begin();
  Bluefruit.setTxPower(4);
  // Bluefruit.setName(device_alias); // useful testing with multiple central connections
  Bluefruit.Periph.setConnectCallback(connect_callback);
  Bluefruit.Periph.setDisconnectCallback(disconnect_callback);
  // To be consistent OTA DFU should be added first if it exists
  // bledfu.begin();

  // Configure and Start Device Information Service
  bledis.setManufacturer("Adafruit Industries");
  // bledis.setModel("Bluefruit Feather52");
  bledis.setModel("XIAO nRF52840 Sense");
  bledis.begin();
  // Configure and Start BLE Uart Service
  bleuart.begin();
  bleuart.setRxCallback(rxCallback);
  // Start BLE Battery Service
  // blebas.begin();
  // blebas.write(100);
  // Set up and start advertising

}

void startAdv(void)
{
  // Advertising packet
  Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE);
  Bluefruit.Advertising.addTxPower();
  // Include bleuart 128-bit uuid
  Bluefruit.Advertising.addService(bleuart);
  // Secondary Scan Response packet (optional)
  // Since there is no room for 'Name' in Advertising packet
  Bluefruit.ScanResponse.addName();
  
  /* Start Advertising
   * - Enable auto advertising if disconnected
   * - Interval:  fast mode = 20 ms, slow mode = 152.5 ms
   * - Timeout for fast mode is 30 seconds
   * - Start(timeout) with timeout = 0 will advertise forever (until connected)
   * 
   * For recommended advertising interval
   * https://developer.apple.com/library/content/qa/qa1931/_index.html   
   */
  Bluefruit.Advertising.restartOnDisconnect(true);
  Bluefruit.Advertising.setInterval(32, 244);    // in unit of 0.625 ms
  Bluefruit.Advertising.setFastTimeout(30);      // number of seconds in fast mode
  Bluefruit.Advertising.start(0);                // 0 = Don't stop advertising after n seconds  
}

/******************/
/* Main  Firmware */
/******************/

void setup() {
    // configure motor control pins
  pinMode(motor.speedPin, OUTPUT);
  pinMode(motor.brakePin, OUTPUT);
  pinMode(motor.dirPin, OUTPUT);

  pinMode(LED_RED, OUTPUT);
  digitalWrite(LED_GREEN, OUTPUT);

  digitalWrite(motor.speedPin, 0);
  digitalWrite(motor.brakePin, HIGH);
  digitalWrite(motor.dirPin, LOW);

  // clean the send_buffer memory
  memset(send_buffer, 0, sizeof(send_buffer));
  // Config the peripheral connection with maximum bandwidth 

  myIMU.settings.accelRange = 2;    //Max G force readable. Can be: 2, 4, 8, 16. Default 2.
  myIMU.settings.gyroRange = 125;   //Max deg/s. Can be: 125, 245, 500, 1000, 2000. Default 125.

  while(myIMU.begin()!= 0);

  initBLE();
  startAdv();
}

void rxCallback(uint16_t connHandle) {
  (void) connHandle;
  bleuart.read(rec_buffer, sizeof(rec_buffer));
  uint8_t dir = (uint8_t) rec_buffer[0];  // 0 if pos, 1 if neg
  uint8_t speed = (uint8_t) rec_buffer[1];
  processMotorCmds(dir,speed);
}

// encode IMU
void encodeIMU(uint8_t encodedData[], uint idx, int16_t raw) {  // big-endian
  // Modify the array elements
  encodedData[idx] = (raw >> 8) & 0xFF; // Store the higher byte
  encodedData[idx+1] = raw & 0xFF; // Lower byte
}

void loop() {
  // read and encode IMU
  int16_t tmp = myIMU.readRawAccelX();

  encodeIMU(send_buffer, 0, tmp);
  tmp = myIMU.readRawAccelY();

  encodeIMU(send_buffer, 2, tmp);
  tmp = myIMU.readRawAccelZ();

  encodeIMU(send_buffer, 4, tmp);
  tmp = myIMU.readRawGyroX();

  encodeIMU(send_buffer, 6, tmp);
  tmp = myIMU.readRawGyroY();

  encodeIMU(send_buffer, 8, tmp);
  tmp = myIMU.readRawGyroZ();

  encodeIMU(send_buffer, 10, tmp);

  // send imu data
  bleuart.write(send_buffer,sizeof(send_buffer));
  // clear send buffer
  memset(send_buffer, 0, sizeof(send_buffer));
  // frequency
  delay(1);
}
