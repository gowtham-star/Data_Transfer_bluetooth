import os
import random
import time

def create_or_update_file(file_name):
    # Check if the file exists
    if os.path.exists(file_name):
        update_existing_file(file_name)
    else:
        create_new_file(file_name)
        update_existing_file(file_name)

def create_new_file(file_name):
    with open(file_name, 'w') as file:
        # Add headers
        file.write("timeStamp,temperature,random\n")

def generate_random_temperature_celsius():
    return random.randint(-20, 40)

def generate_random_attribute():
    return random.randint(1, 100)

def update_existing_file(file_name):
    while True:
        temperature = generate_random_temperature_celsius()
        random_value = generate_random_attribute()

        # Append the values to the file in CSV format
        with open(file_name, 'a') as file:
            file.write(f"{int(time.time()*1000)},{temperature},{random_value}\n")

        # Wait for 1 second before the next update
        time.sleep(1)

if __name__ == "__main__":
    file_name = "data.csv"
    create_or_update_file(file_name)
