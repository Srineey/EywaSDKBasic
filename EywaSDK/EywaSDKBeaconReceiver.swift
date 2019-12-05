//
//  EywaSDKBeaconReceiver.swift
//  EywaSDK
//
//  Created by Srinivasa Reddy on 8/14/19.
//  Copyright © 2019 Eywamedia. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

public protocol BeaconReceiverDelegate {
    
    func ClosestBroadcastedBeaconInfo(beaconInfo: Dictionary<String, Any>)
    func AllBroadcastedBeaconsInfo(beaconInfo: Dictionary<String, Any>)
}

public class EywaSDKBeaconReceiver: NSObject, CLLocationManagerDelegate {
    
    public static let sharedInstance: EywaSDKBeaconReceiver = {
        let instance = EywaSDKBeaconReceiver()
        return instance
    }()
    
    var locationManager : CLLocationManager!
    var beaconRegion : CLBeaconRegion!
    public var delegate: BeaconReceiverDelegate?
    public var isBeaconMonitoringStopped : Bool = false
    
    let expirationTimeSecs = 5.0
    public var closestBeacon: CLBeacon? = nil
    public var detectedBeacon: CLBeacon? = nil
    var trackedBeacons: Dictionary<String, CLBeacon>
    var trackedBeaconTimes: Dictionary<String, NSDate>

    public override init() {
        
        trackedBeacons = Dictionary<String, CLBeacon>()
        trackedBeaconTimes = Dictionary<String, NSDate>()
        
        super.init()
        
        if locationManager == nil {
            
            if CLLocationManager.locationServicesEnabled() {
                
                switch CLLocationManager.authorizationStatus()
                {
                case .notDetermined:
                    
                    print("User Location Not Detetmined yet")
                    self.setLocationManager()
                    
                case .restricted, .denied:
                    
                    print("No access for Location")
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LocationServicesDisabled"), object: nil)
                    
                case .authorizedAlways, .authorizedWhenInUse:
                    
                    print("Access Enabled for Location")
                    self.setLocationManager()
                @unknown default:
                    print("Default case")
                }
            } else {
                print("Location services are not enabled")
            }
        }
        
        initiateStartScan()
    }
    
    func setLocationManager() {
        
        self.locationManager = CLLocationManager()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.delegate = self
    }
    
    //START SCANNING
    
    public func initiateStartScan(){
        startScanningForBeaconRegion(beaconRegion: getBeaconRegion())
    }
    
    func startScanningForBeaconRegion(beaconRegion: CLBeaconRegion) {
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
        locationManager.requestState(for: beaconRegion)
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        beaconRegion.notifyEntryStateOnDisplay = true
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
    }
    
    func getBeaconRegion() -> CLBeaconRegion {
        beaconRegion = CLBeaconRegion.init(proximityUUID: UUID.init(uuidString: EywaConstants.kBeaconUUID)!,
                                           identifier: EywaConstants.kBeaconBundleIdentifier)
        return beaconRegion
    }
    
    //LOCATION MANAGER DELEGATES
    
    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        switch (state) {
        case CLRegionState.inside:
            print("EywaSDK - CLRegion Inside State")
            break;
        case CLRegionState.outside:
            print("EywaSDK - CLRegion Outside State")
            break;
        case CLRegionState.unknown:
            print("EywaSDK - CLRegion Unknown State")
            break;
        default:
            break;
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("EywaSDK - Beacon monitoringDidFail \(error)")
    }
    
    public func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("EywaSDK - Beacon rangingBeaconsDidFailFor \(error)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("EywaSDK - Beacon didFailWithError \(error)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        let now = NSDate()
        for beacon in beacons {
            
            validateBeaconWithMacList(beacon: beacon)
            
            let key = keyForBeacon(beacon: beacon)
            if beacon.accuracy < 0 {
                NSLog("EywaSDK - Ignoring beacon with negative distance")
            }
            else {
                trackedBeacons[key] = beacon
                if (trackedBeaconTimes[key] != nil) {
                    trackedBeaconTimes[key] = now
                }
                else {
                    trackedBeaconTimes[key] = now
                }
            }
        }
        purgeExpiredBeacons()
        
        if beacons.count > 0 {
            calculateClosestBeacon()
        }
    }
    
    public func calculateClosestBeacon() {
        var changed = false
        // Initialize cloestBeaconCandidate to the latest tracked instance of current closest beacon
        var closestBeaconCandidate: CLBeacon?
        if closestBeacon != nil {
            let closestBeaconKey = keyForBeacon(beacon: closestBeacon!)
            for key in trackedBeacons.keys {
                if key == closestBeaconKey {
                    closestBeaconCandidate = trackedBeacons[key]
                }
            }
        }
        
        for key in trackedBeacons.keys {
            var closer = false
            let beacon = trackedBeacons[key]
            if (beacon != closestBeaconCandidate) {
                if beacon!.accuracy > 0 {
                    if closestBeaconCandidate == nil {
                        closer = true
                    }
                    else if beacon!.accuracy < closestBeaconCandidate!.accuracy {
                        closer = true
                    }
                }
                if closer {
                    closestBeaconCandidate = beacon
                    changed = true
                }
            }
        }
        if (changed) {
            closestBeacon = closestBeaconCandidate
        }
        
        if closestBeacon != nil {
            
            //            print("ClosestBeacon is \(String(describing: closestBeacon?.minor.stringValue))")
            
            validateClosestBeaconWithMacList(beacon: closestBeacon!)
        }
    }
    
    public func keyForBeacon(beacon: CLBeacon) -> String {
        return "\(beacon.proximityUUID.uuidString) \(beacon.major) \(beacon.minor)"
    }
    
    public func purgeExpiredBeacons() {
        let now = NSDate()
        var changed = false
        var newTrackedBeacons = Dictionary<String, CLBeacon>()
        var newTrackedBeaconTimes = Dictionary<String, NSDate>()
        for key in trackedBeacons.keys {
            let beacon = trackedBeacons[key]
            let lastSeenTime = trackedBeaconTimes[key]!
            if now.timeIntervalSince(lastSeenTime as Date) > expirationTimeSecs {
//                NSLog("******* Expired seeing beacon: \(key) time interval is \(now.timeIntervalSince(lastSeenTime as Date))")
                changed = true
            }
            else {
                newTrackedBeacons[key] = beacon!
                newTrackedBeaconTimes[key] = lastSeenTime
            }
        }
        if changed {
            trackedBeacons = newTrackedBeacons
            trackedBeaconTimes = newTrackedBeaconTimes
        }
    }
    
    // FORCE RESTART BEACON MONITERING
    
    public func startMonitoringBeacons() {
        
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    // FORCE STOP BEACON MONITERING
    
    public func stopMonitoringBeacons() {
        
        print("EywaSDK - STOP MONITERING BEACONS")
        
        isBeaconMonitoringStopped = true
        
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion)
        locationManager.stopUpdatingLocation()
    }
    
    //CHECK WHETHER DETECTED BEACON IS AVAILABLE IN PRE-DEFINED LIST OR NOT
    
    func validateBeaconWithMacList(beacon : CLBeacon) {
        
        let beaconList = EywaSDKWifiMacList.SharedManager
        
        let beaconListArray = beaconList.beanconList()
        
        self.detectedBeacon = beacon
        
        let predicate = NSPredicate(format: "UUID like %@ AND Major like %@ AND Minor like %@",beacon.proximityUUID.uuidString,beacon.major.stringValue,beacon.minor.stringValue);
        let filteredArray = beaconListArray.filter { predicate.evaluate(with: $0) };
        
        if filteredArray.count != 0 {
            
            for item in filteredArray {
                
                //                print("Beacon \(item)")
                
                let beaconInfo = item as? Dictionary<String, Any>
                
                if beaconInfo?.keys.count != 0 {
                    
                    if beaconInfo!["Name"] != nil {
                        
                        delegate?.AllBroadcastedBeaconsInfo(beaconInfo: beaconInfo!)
                    }
                }
            }
        }
    }
    
    /*func validateBeaconWithMacList(UUID: String, Major: String, Minor: String) {
        
        let beaconList = EywaSDKWifiMacList.SharedManager
        
        let beaconListArray = beaconList.beanconList()
        
        let predicate = NSPredicate(format: "UUID like %@ AND Major like %@ AND Minor like %@",UUID,Major,Minor);
        let filteredArray = beaconListArray.filter { predicate.evaluate(with: $0) };
        
        if filteredArray.count != 0 {
            
            for item in filteredArray {
                
                //                print("Beacon \(item)")
                
                let beaconInfo = item as? Dictionary<String, Any>
                
                if beaconInfo?.keys.count != 0 {
                    
                    if beaconInfo!["Name"] != nil {
                        
                        delegate?.AllBroadcastedBeaconsInfo(beaconInfo: beaconInfo!)
                    }
                }
            }
        }
    }*/
    
    //CHECK WHETHER DETECTED CLOSEST BEACON IS AVAILABLE IN PRE-DEFINED LIST OR NOT

    func validateClosestBeaconWithMacList(beacon : CLBeacon) {
        
        let beaconList = EywaSDKWifiMacList.SharedManager
        
        let beaconListArray = beaconList.beanconList()
        
        let predicate = NSPredicate(format: "UUID like %@ AND Major like %@ AND Minor like %@",beacon.proximityUUID.uuidString,beacon.major.stringValue,beacon.minor.stringValue);
        let filteredArray = beaconListArray.filter { predicate.evaluate(with: $0) };
        
        if filteredArray.count != 0 {
            
            for item in filteredArray {
                
                //                print("Beacon \(item)")
                
                let beaconInfo = item as? Dictionary<String, Any>
                
                if beaconInfo?.keys.count != 0 {
                    
                    if beaconInfo!["Name"] != nil {
                        
                        delegate?.ClosestBroadcastedBeaconInfo(beaconInfo: beaconInfo!)
                    }
                }
            }
        }
    }
        
    /*func validateClosestBeaconWithMacList(UUID: String, Major: String, Minor: String) {
        
        let beaconList = EywaSDKWifiMacList.SharedManager
        
        let beaconListArray = beaconList.beanconList()
        
        let predicate = NSPredicate(format: "UUID like %@ AND Major like %@ AND Minor like %@",UUID,Major,Minor);
        let filteredArray = beaconListArray.filter { predicate.evaluate(with: $0) };
        
        if filteredArray.count != 0 {
            
            for item in filteredArray {
                
                //                print("Beacon \(item)")
                
                let beaconInfo = item as? Dictionary<String, Any>
                
                if beaconInfo?.keys.count != 0 {
                    
                    if beaconInfo!["Name"] != nil {
                        
                        delegate?.ClosestBroadcastedBeaconInfo(beaconName: beaconInfo!["Name"] as! String)
                    }
                }
            }
        }
    }*/
}
