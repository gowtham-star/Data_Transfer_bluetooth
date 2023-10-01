# sudo apt-get install bluetooth bluez libbluetooth-dev
# sudo python3 -m pip install pybluez

from bluetooth import *
import socket
import subprocess
import time
import random
import json

def generate_random_temperature_celsius():
    # Generate a random temperature between -20°C and 40°C
    return random.randint(-20, 40)

def generate_random_attribute():
    return random.randint(1, 100)
    
def get_data():
    data = {
        'timeStamp': int(time.time()*1000),
        'temperature': generate_random_temperature_celsius(),
        'random': generate_random_attribute()
    }
    print(data)
    return json.dumps(data)

server_sock=BluetoothSocket( RFCOMM )
server_sock.bind(("", PORT_ANY))
server_sock.listen(0)

port = server_sock.getsockname()[1]

while True:
   print("Waiting for connection on RFCOMM channel %d" % port)
   client_sock, client_info = server_sock.accept()
   print("Connected to " + str(client_info))
   try:
      while True:
         client_sock.send(get_data())
         time.sleep(1)
   except IOError:
      pass

client_sock.close()
server_sock.close()

print("disconnected")
