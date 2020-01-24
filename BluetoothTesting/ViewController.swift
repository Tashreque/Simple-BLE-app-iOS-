import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    // Variables to keep track of current connected device.
    var selectedDeviceRow = -1
    
    // Bluetooth central manager.
    var centralManager: CBCentralManager!
    
    // Peripheral dictionary.
    var peripheralSet = Set<UUID>()
    
    // Discovered peripherals to load table view.
    var discoveredPeripherals = [CBPeripheral]() {
        didSet {
            devicesTableView.reloadData()
        }
    }
    
    // Instance of the heart rate peripheral.
    var heartRatePeripheral = HeartRateDevice()
    
    //IBOutlet references.
    @IBOutlet weak var devicesTableView: UITableView!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var sensorLocationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    @IBAction func bluetoothDidTap(_ sender: UIButton) {
        discoveredPeripherals.removeAll()
        peripheralSet.removeAll()
        selectedDeviceRow = -1
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
}

// This extension deals with any CBCentralManagerDelegate protocol callback functions.
extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Called to check if bluetooth connectivity state got updated.
        let handler = DeviceListViewModel.shared
        var alertTitle = ""
        var alertDescription = ""
        
        alertTitle = handler.getStateAlertTitle(state: centralManager.state)
        alertDescription = handler.getStateAlertDescription(state: centralManager.state)
        
        if centralManager.state == .poweredOn {
            print(alertTitle + " " + alertDescription)
            centralManager.scanForPeripherals(withServices: [heartRatePeripheral.serviceUuid], options: nil)
            return
        }
        
        // Show relevant alert.
        let alert = UIAlertController(title: alertTitle, message: alertDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Called when the central manager has discovered any peripheral.
        central.stopScan()
        if peripheralSet.contains(peripheral.identifier) {
            print("Already found!")
        } else {
            print(peripheral)
            peripheralSet.insert(peripheral.identifier)
            discoveredPeripherals.append(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Called if the central manager has connected to any peripheral.
        print("Connected to peripheral: \(peripheral)")
        peripheral.discoverServices([heartRatePeripheral.serviceUuid])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Peripherals disconnected!")
    }
}

// This extension deals with any CVPeripheralDelegate protocol callback functions.
extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // Called if the services of this peripheral have been discovered by the central manager.
        guard let services = peripheral.services else {
            return
        }
        
        // Handle services.
        services.forEach { (service) in
            print(service)
            // Discover characteristics within the required service(s).
            peripheral.discoverCharacteristics([heartRatePeripheral.measurementUuid, heartRatePeripheral.sensorLocationUuid], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Called if the characteristics of a certain service has been discovered.
        guard let characteristics = service.characteristics else {
            return
        }

        for characteristic in characteristics {
            if characteristic.properties.contains(.read) {
                print("Can be read!")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
                print("Can notify!")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Called if a characteristic of a service gets updated.
        let dataHandler = DeviceListViewModel.shared
        
        switch characteristic.uuid {
        case heartRatePeripheral.sensorLocationUuid:
            let sensorLocation = dataHandler.retrieveSensorLocation(from: characteristic)
            print(sensorLocation)
            sensorLocationLabel.text = "Sensor location: \(sensorLocation)"
        case heartRatePeripheral.measurementUuid:
            let heartRate = dataHandler.retrieveHeartRate(from: characteristic)
            
            print(heartRate)
            heartRateLabel.text = String(heartRate)
        default:
            print("Unhandled characteristic for uuid: \(characteristic.uuid)")
        }
    }
    
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        print("Name changed to \(String(describing: peripheral.name))")
    }
}

// This extension handles the associated table view callback functions.
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredPeripherals.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = devicesTableView.dequeueReusableCell(withIdentifier: "DeviceTableViewCell") as! DeviceTableViewCell
        cell.accessoryType = .checkmark
        
        cell.deviceName.text = discoveredPeripherals[indexPath.row].name
        cell.deviceUuid.text = discoveredPeripherals[indexPath.row].identifier.uuidString
        
        if indexPath.row == selectedDeviceRow {
            cell.accessoryType = .checkmark
            cell.peripheralDisconnectButton.isHidden = false
        } else {
            cell.accessoryType = .none
            cell.peripheralDisconnectButton.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedPeripheral = discoveredPeripherals[indexPath.row]
        selectedPeripheral.delegate = self
        selectedDeviceRow = indexPath.row
        
        print("Selected \(String(describing: selectedPeripheral.name))")
        centralManager.connect(selectedPeripheral, options: nil)
        
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
}

