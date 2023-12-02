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

def read_10_data_per_message(file_name):
    try:
        with open(file_name, 'r') as file:
            lines = file.readlines()
            headers = lines[0].strip().split(',')
            data_list = []

            # Processing batches of 10 lines
            for i in range(1, len(lines), 10):
                data_batch = lines[i:i+10]
                data_batch_json = []

                for line in data_batch:
                    data_values = line.strip().split(',')
                    data_json = {headers[j]: int(data_values[j]) for j in range(len(headers))}
                    data_batch_json.append(data_json)

                data_list.append(data_batch_json)

            # Handling remaining lines (less than 10)
            if len(lines) % 10 != 0:
                remaining_lines = lines[len(lines) - len(lines) % 10:]
                remaining_data_json = []

                for line in remaining_lines:
                    data_values = line.strip().split(',')
                    data_json = {headers[j]: int(data_values[j]) for j in range(len(headers))}
                    remaining_data_json.append(data_json)

                data_list.append(remaining_data_json)

            json_messages = [json.dumps(data, indent=2) for data in data_list]
            return json_messages
    except Exception as e:
        return [json.dumps({"error": str(e)}, indent=2)]



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
             received_data = str(received_data)[2:-1]
             if str(received_data) == "nosync":
               client_sock.send(read_latest_data(file_name))
             elif(str(received_data) == "sync"):
                for jsonPacket in read_all_data(file_name):
                    client_sock.send(jsonPacket)
                client_sock.send("sync_done")
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

