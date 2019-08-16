//
//  EywaSDKBluetoothManager.swift
//  EywaSDK
//
//  Created by Srinivasa Reddy on 8/14/19.
//  Copyright © 2019 Eywamedia. All rights reserved.
//

import UIKit
import Foundation
import CoreBluetooth

public class EywaSDKBluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    public static let sharedInstance: EywaSDKBluetoothManager = {
        let instance = EywaSDKBluetoothManager()
        return instance
    }()
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    
    public override init() {
        
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: CBCentralManagerDelegate
    public func centralManagerDidUpdateState(_ central:CBCentralManager) {
        
        switch central.state {
        case CBManagerState.poweredOn:
            print("Bluetooth powered On")
            
        case CBManagerState.poweredOff:
            print("Bluetooth powered Off")
            
        case CBManagerState.unsupported:
            print("Bluetooth low energy hardware not supported.")
            
        case CBManagerState.unauthorized:
            print("Bluetooth unauthorized state.")
            
        case CBManagerState.unknown:
            print("Bluetooth unknown state.")
            
        default:
            print("Bluetooth unknown state.")
        }
        
    }
}
