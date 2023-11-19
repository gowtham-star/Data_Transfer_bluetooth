# sudo apt-get install bluetooth bluez libbluetooth-dev
# sudo python3 -m pip install pybluez

from bluetooth import *
import socket
import subprocess
import time
import random
import json

def read_latest_data(file_name):
    try:
        with open(file_name, 'r') as file:
            # Read all lines from the file
            lines = file.readlines()

            # If there are lines in the file, extract the latest data point
            if lines:
                latest_data = lines[-1].strip().split(',')
                headers = lines[0].strip().split(',')

                # Create a JSON object with headers and values
                latest_json = {headers[i]: int(latest_data[i]) for i in range(len(headers))}

                return json.dumps(latest_json, indent=2)
            else:
                return json.dumps({"message": "No data available"}, indent=2)
    except Exception as e:
        return json.dumps({"error": str(e)}, indent=2)

def read_all_data(file_name):
    try:
        with open(file_name, 'r') as file:
            # Read all lines from the file
            lines = file.readlines()

            # Extract headers from the first line
            headers = lines[0].strip().split(',')

            # Initialize an empty list to store JSON objects
            data_list = []

            # Iterate through lines starting from the second line
            for line in lines[1:]:
                data_values = line.strip().split(',')
                # Create a JSON object with headers and values
                data_json = {headers[i]: int(data_values[i]) for i in range(len(headers))}
                data_list.append(data_json)

            return json.dumps(data_list, indent=2)
    except Exception as e:
        return json.dumps({"error": str(e)}, indent=2)


def Main(file_name):
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
             received_data = client_sock.recv(1024)  # Receiving data from the client
             if str(received_data) == "nosync":
               client_sock.send(read_latest_data(file_name))
             elif(str(received_data) == "sync"):
                client_sock.send(read_all_data(file_name))
             time.sleep(1)
       except IOError:
          pass

    client_sock.close()
    server_sock.close()

    print("disconnected")

if __name__ == '__main__':
    if len(sys.argv) != 2:
            print("Usage: python script_name.py <file_name>")
            sys.exit(1)
    file_name = sys.argv[1]
    Main(file_name)

