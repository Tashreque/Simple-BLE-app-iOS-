import Foundation
import CoreBluetooth

// This class contains certain properties of the heart rate device like name, UUID, services, characteristics.
struct HeartRateDevice {
    let deviceUuid = UUID(uuidString: "7CEEA6A1-C254-4242-8C45-16FAD7736768")
    let serviceUuid = CBUUID(string: "180D")
    let measurementUuid = CBUUID(string: "2A37")
    let sensorLocationUuid = CBUUID(string: "2A38")
}
