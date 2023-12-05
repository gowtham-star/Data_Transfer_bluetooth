# Data Transfer using Wi-Fi Flutter Application

![App Preview](app_preview.png)

## Introduction

Welcome to the Data Transfer Buetooth Flutter Application! This project focuses on real-time data transfer, specifically temperature data, from a Raspberry Pi to a Flutter mobile application. The application boasts three powerful features:

1. **Data Collection and Storage**: The app collects real-time data and stores it in a local SQLite database for future reference.

2. **Data Export**: Seamlessly download the collected data in CSV format, making it easy to analyze or share.

3. **Data Visualization**: The app provides interactive data visualization through line charts, helping you gain insights at a glance.

## Getting Started

Getting up and running with our application is a breeze. Here's how to use it:

1. **Raspberry Pi Setup**:
   - Download this repository on your Raspberry Pi.
   - Copy the `python_bluetooth` folder to your desktop.
   - Open the terminal on your Raspberry Pi and navigate to the `python_bluetooth` directory. (This script genrates data. You can replace this with your own script and it by default generates data.csv file)
   ```
     source venv/bin/activate
     python DataGenerator.py
   ```
   - Open the terminal on your Raspberry Pi and navigate to the `python_bluetooth` directory.
   - Run the following command to start the Flask server:
     ```
     source venv/bin/activate
     python server_bluetooth.py <data.csv or replace with your own csv file>
     ```
   - Bluetooth server runs using RFCOMM channel 0

2. **Flutter App Installation**:
   - Clone this repository to your local computer folder.
   - Use Android Studio to import the project as a Flutter application.
   - Build the APK by clicking on `Flutter -> Build APK` in Android Studio.
   - Copy the APK file from `build->app->outputs->flutter-apk->app-release.apk` to your desired location.
   - Run the app on your Android device or use the provided APK file.
   
3. **Connect and Explore**:
   - Got to your device with bluetooth switched on, pair your blueetooth with pi
   - After opening the app, select the bonded/paired pi
   - Start seeing real-time data on the home screen.
   - Dive deeper by exploring interactive charts via the "View Charts" button.
   - Download data in CSV format using the "Download CSV" button.
   - Click on sync data button to sync historical data

Enjoy seamless data transfer and exploration!

![Data Visualization](chart_preview.png)

## Adding New Attributes

Here's how to add new attributes:

1. **Modify `ExposeAPI.py` on the Raspberry Pi**:
   - Update the script by adding new key-value attributes within the JSON structure section.

2. **Update the Flutter App**:
   - In the `databasehelper.dart` file:
     - Add the new attribute to the `PiDataModel` class methods.
     - Update the `create table` statement in the `_createDB` method to include the new attribute.

   - In the `main.dart` file:
     - Add a new key-value pair in the `dataObj` variable to handle the new attribute.

   - In `chartspage.dart`, adapt the chart code to display the new attribute on the Y-axis.

![Data Exploration](data_explore.png)

Please note that both the Raspberry Pi and the mobile app should be connected via Bluetooth channel 0

Thank you for choosing  Data Transfer Bluetooth Flutter Application. We hope you find it valuable and easy to use. If you have any questions or feedback, don't hesitate to reach out.

Happy data exploration!
