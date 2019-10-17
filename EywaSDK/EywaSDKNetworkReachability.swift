//
//  EywaSDKNetworkReachability.swift
//  EywaSDK
//
//  Created by Srinivasa Reddy on 6/21/19.
//  Copyright © 2019 Eywamedia. All rights reserved.
//

import UIKit
import Reachability

public protocol EywaSDKNetworkReachabilityDelegate {
    func didConnectedToWifi(routerName: String)
}

public class EywaSDKNetworkReachability: NSObject {
    
    var reachability: Reachability!
    public var delegate: EywaSDKNetworkReachabilityDelegate?
    
    public static let sharedInstance: EywaSDKNetworkReachability = { return EywaSDKNetworkReachability() }()
    
    override init() {
        super.init()
        
        do {
            reachability = try Reachability()
        } catch _{
            reachability = nil
        }
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .reachabilityChanged,
            object: reachability
        )
        
        do {
            try reachability.startNotifier()
        } catch {
            print("EywaSDK - Unable to start notifier")
        }
    }
    
    @objc func networkStatusChanged(_ notification: Notification) {
        
        if EywaSDKNetworkReachability.sharedInstance.reachability.connection == .wifi {
            
            print("Connected to Wifi")
            
            EywaSDKNetworkReachability.sharedInstance.getWifiNetworkInfo()
        }
        else {
            //             print("Not Connected to Wifi")
        }
    }
    
    func getWifiNetworkInfo() {
        
        let deviceHelper = EywaSDKCodeDeviceHelper()
        
        let networkName = deviceHelper.fetchSSIDInfo()
        let networkMac = deviceHelper.fetchBSSIDInfo()
        
        print("Network Name is \(networkName)")
        print("Network MAC is \(networkMac)")
        
        let wifiMacListMgr = EywaSDKWifiMacList.SharedManager
        
        let macListDictionary : [String:String] = wifiMacListMgr.wifiMacList()
        
        if let val = macListDictionary[networkMac] {
            
            print("Connected Wifi belongs to SS SSID List")
            delegate?.didConnectedToWifi(routerName: val)
        }
        else{
            print("Connected Wifi not belongs to SS SSID List")
        }
    }
    
    static func stopNotifier() -> Void {
        do {
            try (EywaSDKNetworkReachability.sharedInstance.reachability).startNotifier()
        } catch {
            print("EywaSDK - Error stopping notifier")
        }
    }
    
    static func isReachable(completed: @escaping (EywaSDKNetworkReachability) -> Void) {
        if (EywaSDKNetworkReachability.sharedInstance.reachability).connection != .unavailable {
            completed(EywaSDKNetworkReachability.sharedInstance)
        }
    }
    
    static func isUnreachable(completed: @escaping (EywaSDKNetworkReachability) -> Void) {
        if (EywaSDKNetworkReachability.sharedInstance.reachability).connection == .unavailable {
            completed(EywaSDKNetworkReachability.sharedInstance)
        }
    }
    
    static func isReachableViaWWAN(completed: @escaping (EywaSDKNetworkReachability) -> Void) {
        if (EywaSDKNetworkReachability.sharedInstance.reachability).connection == .cellular {
            completed(EywaSDKNetworkReachability.sharedInstance)
        }
    }
    
    static func isReachableViaWiFi(completed: @escaping (EywaSDKNetworkReachability) -> Void) {
        if (EywaSDKNetworkReachability.sharedInstance.reachability).connection == .wifi {
            completed(EywaSDKNetworkReachability.sharedInstance)
        }
    }
}
