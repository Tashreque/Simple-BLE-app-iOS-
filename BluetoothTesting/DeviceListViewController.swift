import UIKit
import CoreBluetooth

class DeviceListViewController: UIViewController {
    
    // Variables to keep track of current connected device.
    var selectedDeviceRow = -1
    
    // Bluetooth central manager.
    var centralManager: CBCentralManager!
    
    // Peripheral dictionary.
    var peripheralSet = Set<UUID>()
    
    // The flag to determine whether scanning has started/stopped.
    var isScanning = false
    
    // Discovered peripherals to load table view.
    var discoveredPeripherals = [CBPeripheral]() {
        didSet {
            devicesTableView.reloadData()
        }
    }
    
    // Instance of the heart rate peripheral.
    var heartRatePeripheral: CBPeripheral?
    
    // The view model for this view controller.
    weak var viewModel: DeviceListViewModel!
    
    //IBOutlet references.
    @IBOutlet weak var devicesTableView: UITableView!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var sensorLocationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel = DeviceListViewModel.shared
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    @IBAction func bluetoothDidTap(_ sender: UIButton) {
//        discoveredPeripherals.removeAll()
//        peripheralSet.removeAll()
//        selectedDeviceRow = -1
        
        // Make UI changes.
        if !isScanning {
            if centralManager.state == .poweredOn {
                centralManager.scanForPeripherals(withServices: nil, options: nil)
                isScanning = true
                sender.backgroundColor = .systemBlue
                sender.setTitle("Stop", for: .normal)
            } else {
                showBluetoothAlert()
            }
        } else {
            centralManager.stopScan()
            isScanning = false
            sender.backgroundColor = .systemRed
            sender.setTitle("Start", for: .normal)
        }
    }
    
    private func showBluetoothAlert() {
        // Show relevant alert.
        var alertTitle = ""
        var alertDescription = ""
        
        alertTitle = viewModel.getStateAlertTitle(state: centralManager.state)
        alertDescription = viewModel.getStateAlertDescription(state: centralManager.state)
        
        let alert = UIAlertController(title: alertTitle, message: alertDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// This extension deals with any CBCentralManagerDelegate protocol callback functions.
extension DeviceListViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Called to check if bluetooth connectivity state got updated.
        showBluetoothAlert()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Called when the central manager has discovered any peripheral.
        //central.stopScan()
        if peripheralSet.contains(peripheral.identifier) {
            print("Already found!")
        } else {
            print("Discovered \(peripheral.name ?? "") with ID: \(peripheral.identifier.uuidString)")
            if peripheral.identifier == HeartRateDevice.deviceUuid {
                peripheralSet.insert(peripheral.identifier)
                discoveredPeripherals.append(peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Called if the central manager has connected to any peripheral.
        print("Connected to peripheral: \(peripheral)")
        peripheral.discoverServices([HeartRateDevice.serviceUuid])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Peripherals disconnected!")
    }
}

// This extension deals with any CVPeripheralDelegate protocol callback functions.
extension DeviceListViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // Called if the services of this peripheral have been discovered by the central manager.
        guard let services = peripheral.services else {
            return
        }
        
        // Handle services.
        services.forEach { (service) in
            print(service)
            // Discover characteristics within the required service(s).
            peripheral.discoverCharacteristics([HeartRateDevice.measurementUuid, HeartRateDevice.sensorLocationUuid], for: service)
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
        
        switch characteristic.uuid {
        case HeartRateDevice.sensorLocationUuid:
            let sensorLocation = viewModel.retrieveSensorLocation(from: characteristic)
            print(sensorLocation)
            sensorLocationLabel.text = "Sensor location: \(sensorLocation)"
        case HeartRateDevice.measurementUuid:
            let heartRate = viewModel.retrieveHeartRate(from: characteristic)
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
extension DeviceListViewController: UITableViewDelegate, UITableViewDataSource {
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
        
        // Take action when the disconnect button is tapped.
        cell.disconnectTappedAction = { [weak self] in
            guard let self = self else { return }
            self.centralManager.cancelPeripheralConnection(self.discoveredPeripherals[indexPath.row])
            self.heartRateLabel.text = "---"
            self.selectedDeviceRow = -1
            tableView.reloadRows(at: [indexPath], with: .automatic)
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

