import asyncio
from bleak import BleakClient, BleakError
import threading
import time
import threading
from pythonosc import udp_client, osc_server
from pythonosc.dispatcher import Dispatcher
import struct

MOTOR_IDX = 3   # >>>>>>>> Change Motor IDX for new program

# OSC settings
OSC_PORT_OUT = 5004;    # >>>>>>> Same for all programs (send IMU messages to this port)
OSC_PORT_IN = 5008;     # >>>>>>> Different for each program (listen for commands on this port)

# BLE settings
MODEL_NBR_UUID = ""     # uuid of the board, for establishing BLE connection
# >>>>>>>> Change UUID for new program

# >>>>>>>> DON'T CHANGE

TX_UUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"  
RX_UUID = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"  

# client = None
osc_rec_message = None  # byte array (2 bytes 1 motor)
uart_rec_message = None

EXIT_FLAG = False

LAST_UART_MSG_TSP = None

### UART receive & decode raw imu, convert to float ###

def decodeIMU(arr):
    global uart_rec_message
    uart_rec_message = []
    for i in range(0, len(arr), 2):
        tmp = decodeInt8toInt16(arr[i:i+2])
        if (i < len(arr)/2):
            uart_rec_message.append(calcAccel(tmp)) 
        else:
            uart_rec_message.append(calcGyro(tmp))
    return 

def decodeInt8toInt16(tmp_arr): # big-endian, more significant byte on lower address
    return struct.unpack('>h', tmp_arr)[0]  

def calcGyro(input, range=125): 
    # input int16 range (-32768,32767)
    # range 125, 245, 500, 1000, 2000. default 125
    gyroRangeDivisor = range / 125
    if range == 245:
        gyroRangeDivisor = 2
    output = float(input) * 4.375 * (gyroRangeDivisor) / 1000
    return output

def calcAccel(input, range=2): 
    # input int16 range (-32768,32767)
    # range 2, 4, 8, 16. default 2.
    output = float(input) * 0.061 * (range >> 1) / 1000;
    return output;

def uart_rx_notification_handler(characteristic, data: bytearray):
    # global EXIT_FLAG
    # if not EXIT_FLAG:
    #     decodeIMU(data)
    return


# OSC server in a separate thread - receive / port in / rx
def osc_server_thread_handler(ip, port):
    osc_dispatcher = Dispatcher()
    osc_dispatcher.map("/speed", osc_rec_speed_handler)
    osc_dispatcher.map("/brake", osc_rec_brake_handler)
    server = osc_server.ThreadingOSCUDPServer((ip, port), osc_dispatcher)
    print("Serving on {}".format(server.server_address))
    server.serve_forever()
    return

### OSC send decoded IMU ###

# OSC client in a separate thread - send / port out / tx
def osc_send_thread_handler():
    global uart_rec_message, OSC_PORT_OUT, EXIT_FLAG, MOTOR_IDX
    client = udp_client.SimpleUDPClient("127.0.0.1", OSC_PORT_OUT)
    print("--------OSC send socket created")
    while not EXIT_FLAG: 
        if uart_rec_message:
            client.send_message("/imu"+str(MOTOR_IDX), uart_rec_message)
            print("-----------OSC sent imu:      ", uart_rec_message)
            uart_rec_message = None
        time.sleep(1)
    return


# Message handler for OSC server
def osc_rec_speed_handler(addr, *args):
    global osc_rec_message
    print("Received message from {0}: {1}".format(addr, args))
    val = int(args[0])  # receives a number between -255 and 255
    osc_rec_message = bytearray([1 if (val <0) else 0, abs(val)]) 
    return
    # set dir 0 or 1, speed 0-255
   
def osc_rec_brake_handler(addr, *args):
    global osc_rec_message
    print("Received message from {0}: {1}".format(addr, args))
    osc_rec_message = bytearray([1,0])  
    return
    # set dir to 1, speed to 0 to represent brake


async def uart_tx_handler(client, tx_characteristic):
    global osc_rec_message
    while client.is_connected:
        if osc_rec_message:
            await client.write_gatt_char(tx_characteristic, bytearray(osc_rec_message), response=True)
            print(osc_rec_message)
            print("UDP message sent to UART")
            osc_rec_message = None
    return

async def uart_rx_handler(client, rx_characteristic):
    await client.start_notify(rx_characteristic, uart_rx_notification_handler) 
    return


def BLE_disconnect_callback(c):
    print("BLE device disconnected. Program exits. ")
    print("Turn on BLE device and restart program to reconnect. ")

async def uart_BLE_connect(MODEL_NBR_UUID,TX_UUID, RX_UUID):
    global client, EXIT_FLAG
    try:
        print("Scanning for BLE devices...")
        async with BleakClient(MODEL_NBR_UUID, timeout=5, disconnected_callback=BLE_disconnect_callback) as client:
            print("BLE configured")
            uart_tx_task = asyncio.create_task(uart_tx_handler(client, TX_UUID))
            uart_rx_task = asyncio.create_task(uart_rx_handler(client, RX_UUID))
            await asyncio.gather(uart_tx_task, uart_rx_task)
            '''
            Activate notifications/indications on a characteristic.
            Callbacks must accept two inputs. 
            The first will be the characteristic and the second will be a bytearray containing the data received.
            '''
    except BleakError as e:
        print(e)
        EXIT_FLAG == True
        return 


def main():
    
    # UDP Config Socket Config
    print('OSC rec server thread created')
    server_thread = threading.Thread(target=osc_server_thread_handler, args=("127.0.0.1", OSC_PORT_IN))
    server_thread.daemon = True
    server_thread.start()

    print('OSC send client thread created')
    osc_send_thread = threading.Thread(target=osc_send_thread_handler,)
    osc_send_thread.daemon = True
    osc_send_thread.start()

    # BLE config
    asyncio.run(uart_BLE_connect(MODEL_NBR_UUID,TX_UUID, RX_UUID))


if __name__ == "__main__":
    main()