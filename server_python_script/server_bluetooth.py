import bluetooth
import time

# Bluetooth server settings
server_socket = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
port = 1  # RFCOMM port number (must match the app's port)

# Start the server
server_socket.bind(("", port))
server_socket.listen(1)

print("Waiting for a Bluetooth connection...")
client_socket, client_info = server_socket.accept()
print(f"Accepted connection from {client_info}")

try:
    while True:
        # Replace this with your actual data
        dummy_data = "T1:25.5,T2:26.0,pH:7.2"  # Example dummy data

        # Send data to the connected device
        client_socket.send(dummy_data)

        # Wait for a while before sending the next data (adjust as needed)
        time.sleep(1)

except KeyboardInterrupt:
    print("Keyboard interrupt, closing the server.")
except Exception as e:
    print(f"An error occurred: {e}")

# Close the Bluetooth socket
client_socket.close()
server_socket.close()
