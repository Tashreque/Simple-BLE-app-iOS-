import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    // Bluetooth central manager.
    var centralManager: CBCentralManager!
    
    // Bluetooth peripheral manager.
    var somePeripheral: CBPeripheral!
    
    // Peripheral dictionary.
    var peripheralDictionary = [UUID: Int]()
    
    // Discovered peripherals
    var discoveredPeripherals = [CBPeripheral]()
    
    //IBOutlet references.
    @IBOutlet weak var devicesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    @IBAction func bluetoothDidTap(_ sender: UIButton) {
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
        
        switch central.state {
        case .unknown:
            alertTitle = handler.getStateAlertTitle(state: .unknown)
            alertDescription = handler.getStateAlertDescription(state: .unknown)
        case .resetting:
            alertTitle = handler.getStateAlertTitle(state: .resetting)
            alertDescription = handler.getStateAlertDescription(state: .resetting)
        case .unsupported:
            alertTitle = handler.getStateAlertTitle(state: .unsupported)
            alertDescription = handler.getStateAlertDescription(state: .unsupported)
        case .unauthorized:
            alertTitle = handler.getStateAlertTitle(state: .unauthorized)
            alertDescription = handler.getStateAlertDescription(state: .unauthorized)
        case .poweredOff:
            alertTitle = handler.getStateAlertTitle(state: .poweredOff)
            alertDescription = handler.getStateAlertDescription(state: .poweredOff)
        case .poweredOn:
            alertTitle = handler.getStateAlertTitle(state: .poweredOn)
            alertDescription = handler.getStateAlertDescription(state: .poweredOn)
            centralManager.scanForPeripherals(withServices: nil)
        @unknown default:
            print("Unknown state!")
        }
        
        // Show relevant alert.
        let alert = UIAlertController(title: alertTitle, message: alertDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Called when the central manager has discovered any peripheral.
        //central.stopScan()
        if let _ = peripheralDictionary[peripheral.identifier] {
            print("Already found!")
        } else {
            print(peripheral)
            peripheralDictionary[peripheral.identifier] = 1
            discoveredPeripherals.append(peripheral)
        }
        //central.connect(somePeripheral, options: nil)
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
        
        cell.deviceName.text = discoveredPeripherals[indexPath.row].name
        cell.deviceUuid.text = discoveredPeripherals[indexPath.row].identifier.uuidString
        
        return cell
    }
    
}

