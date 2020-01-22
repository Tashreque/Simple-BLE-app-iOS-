import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    // Bluetooth central manager.
    var centralManager: CBCentralManager!
    
    // Bluetooth peripheral manager.
    var somePeripheral: CBPeripheral!
    
    //IBOutlet references.

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
        switch central.state {
        case .unknown:
            print("Central state is unknown!")
        case .resetting:
            print("Central state is resetting!")
        case .unsupported:
            print("Central state is unsupported!")
        case .unauthorized:
            print("Central state is unauthorized!")
        case .poweredOff:
            let alert = UIAlertController(title: "Bluetooth not turned on!", message: "Go to settings and turn on bluetooth.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        case .poweredOn:
            print("Central state is poweredOn!")
            centralManager.scanForPeripherals(withServices: nil)
        @unknown default:
            print("Unknown state!")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Called when the central manager has discovered any peripheral.
        central.stopScan()
        print(peripheral)
        somePeripheral = peripheral
        central.connect(somePeripheral, options: nil)
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

