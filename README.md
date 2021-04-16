This is a very fundamental Bluetooth Low Energy (BLE) heart rate monitoring app which illustrates the use of Apple's CoreBluetooth and outlines
the uses of CBCentralManager and CBPeripheral. To test this app, a very convenient tool name LightBlue can be used by simulating a heart rate monitor.
The UI for this is very barebones since this is for demostration purposes only.

NOTE - The device uuid needs to be replaced on the struct HeartRateDevice which is defined in the file HeartRateDevice.swift. Make sure the rest of
the properties in the struct has appropriate device specific values.

This application displays two characteristics, the heart rate and the position on the body where the sensor has been placed.
