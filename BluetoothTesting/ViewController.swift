import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
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
    let heartRatePeripheral = HeartRateDevice()
    
    //IBOutlet references.
    @IBOutlet weak var devicesTableView: UITableView!
    var selectedDeviceRow = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    @IBAction func bluetoothDidTap(_ sender: UIButton) {
        centralManager = nil
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
        peripheral.discoverServices(nil)
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
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Called if the characteristics of a certain service has been discovered.
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Called if a characteristic of a service gets updated.
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
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedPeripheral = discoveredPeripherals[indexPath.row]
        selectedDeviceRow = indexPath.row
        
        print("Selected \(String(describing: selectedPeripheral.name))")
        
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
}

