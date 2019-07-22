//
//  EywaSDKNetworkReachability.swift
//  EywaSDK
//
//  Created by Srinivasa Reddy on 6/21/19.
//  Copyright © 2019 Eywamedia. All rights reserved.
//

import UIKit
//import Reachability

public protocol EywaSDKNetworkReachabilityDelegate {
    func didConnectedToWifi(routerName: String)
}

public class EywaSDKNetworkReachability: NSObject {
    
    var reachability: Reachability!
    public var delegate: EywaSDKNetworkReachabilityDelegate?
    
    public static let sharedInstance: EywaSDKNetworkReachability = { return EywaSDKNetworkReachability() }()
    
    override init() {
        super.init()
        
        reachability = Reachability()!
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .reachabilityChanged,
            object: reachability
        )
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    @objc func networkStatusChanged(_ notification: Notification) {
        
        //        print("Network Status Changed")
        
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
        
        let bun = Bundle(identifier: "com.eywamedia.EywaSDK")
        let url = bun?.url(forResource: "WiFiMacList", withExtension: "json")
        do {
            let data = try Data(contentsOf: url!, options: .alwaysMapped)
            do {
                let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)

                if let dictionary = object as? [String: AnyObject] {

                    if dictionary[networkMac] != nil {

                        if networkName != "" {
                        
                            print("Connected Wifi belongs to SS SSID List")
                            delegate?.didConnectedToWifi(routerName: networkName)
                        }
                    }
                    else{
                        print("Connected Wifi not match with SS SSIDs")
                    }
                }
            } catch {
            }
        }
        catch {
        }
        
        
        
        
        
    }
    
    //    func method(arg: Bool, completion: (Bool) -> ()) {
    //        print("First line of code executed")
    //        // do stuff here to determine what you want to "send back".
    //        // we are just sending the Boolean value that was sent in "back"
    //        completion(arg)
    //    }
    
    static func stopNotifier() -> Void {
        do {
            try (EywaSDKNetworkReachability.sharedInstance.reachability).startNotifier()
        } catch {
            print("Error stopping notifier")
        }
    }
    
    static func isReachable(completed: @escaping (EywaSDKNetworkReachability) -> Void) {
        if (EywaSDKNetworkReachability.sharedInstance.reachability).connection != .none {
            completed(EywaSDKNetworkReachability.sharedInstance)
        }
    }
    
    static func isUnreachable(completed: @escaping (EywaSDKNetworkReachability) -> Void) {
        if (EywaSDKNetworkReachability.sharedInstance.reachability).connection == .none {
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
