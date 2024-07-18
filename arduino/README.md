# Summary

- Advertises BLE UART service

- TX characteristic: send IMU data
    - Seeed XIAO Sense board has embedded IMU

- RX characteristic: receives an int (range: -256, 256)
    - Accordingly, controls the brushless DC motor in a single U-Wheel module
        - "-256": brake
        - other: sign indicates direction, value indicates speed

- Use send_imu_rec_motorControl for debugging & developing with Serial port
- Use no_serial_copy for wireless application

*** IMU Instructions ***
1. Download Seeed Arduino LSM6DS3 library
2. Locate the library folder in Arduino Files Directory (Documents/Arduino/Library on Mac)
3. Open 'LSM6DS3.cpp'. 
4. Change all ‘Wire’ variable to ‘Wire1’ in LSM6DS3.cpp


*** BLE Instructions *** 
1. Install Seeed XIAO nRF52840 Board Manager
    a. Go to Arduino IDE - Preferences - Additional board manager URLs
    b. Add this URL: https://files.seeedstudio.com/arduino/package_seeeduino_boards_index.json
    c. Install Seeed nRF52 Boards by Seeed Studio Version 1.1.0


*If the above method doesn't work, consult Seeed Studio official guide: https://wiki.seeedstudio.com/XIAO-BLE-Sense-Bluetooth-Usage/

2. Install Adafruit nRF52 Arduino Board Manager 
    a. Go to this URL: https://github.com/adafruit/Adafruit_nRF52_Arduino
    b. Follow its steps for installation

******************************************************************
We are not going to use the Adafruit nRF52 Arduino Board Manager because it does not specifically support Seeed Xiao nRF52840 series boards. However, this Board Manager packs some BLE libraries that unofficially support Nordic nRF52840DK PCA10056, and Seeed XIAO nRF52840 series uses Nordic nRF52840.

Thus, Seeed XIAO nRF52840 series can make use of the packed library. Specifically, we use: 

bluefruit.h (main)
Adafruit_LittleFS.h
InternalFileSystem.h

To see example code for bluefruit.h, open Arduino IDE, go to File - Examples - Examples for **board name** - Adafruit Bluetooth nRF52 Library. 


Seeed BSP issues ref: https://forum.seeedstudio.com/t/seeed-nrf52-boards-update-to-1-1-3-causes-compile-error/270809/3
******************************************************************

3. Connect to Seeed XIAO nRF52840 Sense & Upload the Code

    - Choose the appropriate serial port OR use over-the-air device-firm-update
    - For board, choose Seeed XIAO nRF52840 Sense (v1.1.0)
        - Do not use the other mbed board manager
        - Do not use other version of the Seeed XIAO nRF52840 board manager
        - This is the most recent version that is compatible with the bluefruit.h library

4. Seeed XIAO nRF52840 Sense will now start advertising BLE UART service. 
    Use BLE scanner apps/programs to discover, connect, and communicate with it.
