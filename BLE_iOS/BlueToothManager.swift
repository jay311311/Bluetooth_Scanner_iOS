//
//  BlueToothManager.swift
//  BLE_iOS
//
//  Created by Jooeun Kim on 2024-06-05.
//

import Foundation
import CoreBluetooth

var blueToothManager: BlueToothManager!

class BlueToothManager: NSObject, CBCentralManagerDelegate {
    /// centralManager은 블루투스 주변기기를 검색하고 연결하는 역할을 수행합니다.
    var centralManager : CBCentralManager!
    
    /// pendingPeripheral은 현재 연결을 시도하고 있는 블루투스 주변기기를 의미합니다.
    var pendingPeripheral : CBPeripheral?

    
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
    
    let headSetServiceCBUUID = CBUUID(string: "D518")

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
          case .resetting:
            print("central.state is .resetting")
          case .unsupported:
            print("central.state is .unsupported")
          case .unauthorized:
            print("central.state is .unauthorized")
          case .poweredOff:
            print("central.state is .poweredOff")
          case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: nil)

        @unknown default:
            print("error")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        if let name = peripheral.name, name.contains("Jooeun") {
           pendingPeripheral = peripheral
            pendingPeripheral!.delegate = self
            
            Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _  in
                self?.centralManager.stopScan()
                           print("centralManager.stopScan()")
            }
            centralManager.connect(pendingPeripheral!)
        }
        
       
    }
    
    // 기기가 연결되면 호출되는 메서드입니다.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        
        peripheral.discoverServices(nil)
    }
    
}

extension BlueToothManager: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print("charctor: \(characteristic)")
            peripheral.readValue(for: characteristic)
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("value : \(characteristic)")
    }
}
