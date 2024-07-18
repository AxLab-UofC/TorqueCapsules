*** Summary *** 


Arduino (n) -- BLE UART -- Python (n) -- OSC(UDP) --  Processing (1)

Each board (BLE UART Peripheral) is connected to one python program. 
- Python send commands to Arduino
- Arduino send sensor data (IMU) to Python

N Python programs each has one client and sends sensor data to 1 OSC server hosted by 1 Processing program.
1 Processing program has multiple clients that send commands to N Python programs, each has its own OSC server.

- OSC client sends OSC message ("/keyword", data) to OSC server
- Each program can only bind to 1 server, but can have multiple clients

Each Python program has one OSC client & one OSC server. 
The Processing program has multiple OSC clients & one OSC server. 


***Each Python program***
- one BLE central
    - scan for BLE peripheral & establish UART connection
        - send & receive over UART services
        - each board has a unique UUID
            - use 'discover_uuid.py' to discover the uuid and scan
- one OSC client
    - sends OSC messages to Processing OSC server
        - **Each Python program has a different keyword**
            - i.e., "/imu1", "/imu2", etc. ...
        - sensor data received from Arduino through BLE UART 
- one OSC server
    - listens for Processing OSC messages (commands)
        - forward to Arduino through BLE UART