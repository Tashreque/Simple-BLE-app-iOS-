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

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
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
            print("Central state is poweredOff!")
        case .poweredOn:
            print("Central state is poweredOn!")
            centralManager.scanForPeripherals(withServices: nil)
        @unknown default:
            fatalError()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        somePeripheral = peripheral
        central.stopScan()
        central.connect(somePeripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral: \(peripheral)")
        peripheral.discoverServices(nil)
    }
}

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        
        services.forEach { (service) in
            print(service)
        }
    }
}

