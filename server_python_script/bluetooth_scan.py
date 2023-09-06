import bluetooth

# Discover nearby Bluetooth devices
nearby_devices = bluetooth.discover_devices(duration=8, lookup_names=True, device_id=-1, flush_cache=True, lookup_class=False)

# Print the list of discovered devices
for addr, name in nearby_devices:
    print(f"Device Name: {name}")
    print(f"Device Address: {addr}")
    print()
