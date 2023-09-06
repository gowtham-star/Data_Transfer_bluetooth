import bluetooth

server_socket = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
port = 1

server_socket.bind(("", port))
server_socket.listen(1)

print("Waiting for a connection...")
client_socket, address = server_socket.accept()
print("Accepted connection from", address)

while True:
    data = client_socket.recv(1024).decode('utf-8')
    if not data:
        break
    print("Received:", data)

    # Respond to the client
    response = "Message received: " + data
    client_socket.send(response.encode('utf-8'))

client_socket.close()
server_socket.close()
