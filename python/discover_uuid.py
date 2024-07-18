# previous version that worked without errors
import asyncio
from bleak import BleakScanner, BleakClient

### Example UUID format
# MODEL_NBR_UUID = "95A3E3F2-74DB-803C-7773-A7B84DECD4B3"


# Create a BLE scanner with Bleak and find out device address/UUID
async def BLE_connect():
    devices = await BleakScanner.discover()
    # for device in devices:
    #     print(device)
    # print("\n")
    for device in devices:
        if device.name == "XIAO nRF52840 Sense": # Scan for microcontroller name
            print("found XIAO nRF52840 Sense!")
            print("device UUID is: ")
            print(device.address)   # This is the device UUID
            async with BleakClient(device.address) as client: # Try connect
                print("is connected: ", client.is_connected)
                print(device)    

# '''
# ----- Address vs UUID -----
# ref: https://bleak.readthedocs.io/en/latest/api/client.html#

# macOS does not provide access to the Bluetooth address for privacy/ security reasons. 
# Instead it creates a UUID for each Bluetooth device which is used 
# in place of the address on this platform.

# Please connect to the BLE device using the method above.

# '''

# Run the scanner with asyncio 
def main():
    # BLE config
    asyncio.run(BLE_connect())

if __name__ == "__main__":
    main()