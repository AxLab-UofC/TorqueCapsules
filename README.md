# TorqueCapsules

Install Processing.

## Module Setup
TorqueCapsules are controlled wirelessly via bluetooth. To make them work, first upload the Arduino code to to the module via the USBC port. 

## Single Module Connection
Turn on the switch and the microcontroller should blink blue. This means the module is looking for bluetooth connection and is broadcasting its UUID. 
Run discover_uuid.py on your laptop, which will listen for UUIDs. The UUID will be returned.
Copy the uuid and paste it to uart_osc0, and run the python file
The terminal will tell you if the connection is successful, and the module blinking will also stop.

## Multi-Module Connection

If you have the first module connected already and want to connect to an additional one, turn on the second module so that its blue light is blinking. Then run discover_uuid. Then, go to uart_osc1 and update the UUID. **Open a different terminal to run uart_osc1.py**. It will not work if the uart_osc0 and 1 are run in the same terminal. Our GUI supports 4 module connection but can be expanded under modification. Just make sure each uart_oscx file is run in a separate terminal. 

## Start GUI
Now with all modules connected, open any Processing file and run it. Follow the instruction on the GUI to control the modules.
