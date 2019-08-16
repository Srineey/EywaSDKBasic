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
            print("EywaSDK - Bluetooth powered On")
            
        case CBManagerState.poweredOff:
            print("EywaSDK - Bluetooth powered Off")
            
        case CBManagerState.unsupported:
            print("EywaSDK - Bluetooth low energy hardware not supported.")
            
        case CBManagerState.unauthorized:
            print("EywaSDK - Bluetooth unauthorized state.")
            
        case CBManagerState.unknown:
            print("EywaSDK - Bluetooth unknown state.")
            
        default:
            print("EywaSDK - Bluetooth unknown state.")
        }
        
    }
}
