import Foundation
import CoreBluetooth

// Singleton class to deliver data to view controller
class DeviceListViewModel {
    static let shared = DeviceListViewModel()
    
    private init() {}
    
    func retrieveHeartRate(from characteristic: CBCharacteristic) -> Int {
        // Called to obtain the heart rate from the given characteristic.
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)

        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
          // Heart Rate Value Format is in the 2nd byte
          return Int(byteArray[1])
        } else {
          // Heart Rate Value Format is in the 2nd and 3rd bytes
          return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
    
    func retrieveSensorLocation(from characteristic: CBCharacteristic) -> String {
        // Called to retrieve the sensor position from the given characteristic.
        guard let characteristicData = characteristic.value,
          let byte = characteristicData.first else { return "Error" }

        switch byte {
          case 0: return "Other"
          case 1: return "Chest"
          case 2: return "Wrist"
          case 3: return "Finger"
          case 4: return "Hand"
          case 5: return "Ear Lobe"
          case 6: return "Foot"
          default:
            return "Reserved for future use"
        }
    }
    
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
