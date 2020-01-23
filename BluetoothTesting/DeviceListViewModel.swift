import Foundation
import CoreBluetooth

// Singleton class to deliver data to view controller
class DeviceListViewModel {
    static let shared = DeviceListViewModel()
    
    private init() {}
    
    func getStateAlertDescription(state: CBManagerState) -> String {
        switch state {
        case .unknown:
            return ""
        case .resetting:
            return ""
        case .unsupported:
            return "Bluetooth is not supported on this device!"
        case .unauthorized:
            return ""
        case .poweredOff:
            return "Turn on Bluetooth in settings and try again."
        case .poweredOn:
            return ""
        @unknown default:
            print("Unknown state!")
        }
        return ""
    }
    
    func getStateAlertTitle(state: CBManagerState) -> String {
        switch state {
        case .unknown:
            return "Unknown!"
        case .resetting:
            return "Resetting!"
        case .unsupported:
            return "Unsupported!"
        case .unauthorized:
            return "Unauthorized!"
        case .poweredOff:
            return "Bluetooth not turned on!"
        case .poweredOn:
            return "Bluetooth is on!"
        @unknown default:
            print("Unknown state!")
        }
        
        return ""
    }
}
