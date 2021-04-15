import Foundation
import CoreBluetooth

// This class contains certain properties of the heart rate device like name, UUID, services, characteristics.
struct HeartRateDevice {
    static let deviceUuid = UUID(uuidString: "AC64C9D7-42FE-7DDC-503B-7C7C6F7115C2")
    static let serviceUuid = CBUUID(string: "180D")
    static let measurementUuid = CBUUID(string: "2A37")
    static let sensorLocationUuid = CBUUID(string: "2A38")
}
