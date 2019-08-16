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

protocol BeaconReceiverDelegate {
    
    func BroadcastedBeaconInfo(beaconName: String)
}


public class EywaSDKBeaconReceiver: NSObject, CLLocationManagerDelegate {
    
    static let sharedInstance: EywaSDKBeaconReceiver = {
        let instance = EywaSDKBeaconReceiver()
        return instance
    }()
    
    var locationManager : CLLocationManager!
    var beaconRegion : CLBeaconRegion!
    var delegate: BeaconReceiverDelegate?
    var isBeaconFound : Bool = false
    
    let expirationTimeSecs = 5.0
    public var closestBeacon: CLBeacon? = nil
    var trackedBeacons: Dictionary<String, CLBeacon>
    var trackedBeaconTimes: Dictionary<String, NSDate>

    public override init() {
        
        trackedBeacons = Dictionary<String, CLBeacon>()
        trackedBeaconTimes = Dictionary<String, NSDate>()
        
        super.init()
        
        self.locationManager = CLLocationManager()
        guard let locationManager = self.locationManager else {
            return
        }
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        initiateStartScan()
    }
    
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
        beaconRegion = CLBeaconRegion.init(proximityUUID: UUID.init(uuidString: "EF100AE3-8CF5-442C-A445-2E5B3DBEF100")!,
                                           identifier: "com.eywamedia.beaconreceiver")
        return beaconRegion
    }
    
    private func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("monitoringDidFail")
    }
    
    private func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("rangingBeaconsDidFailFor \(error)")
    }
    
    private func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
    }
    
    private func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        let now = NSDate()
        for beacon in beacons {
            let key = keyForBeacon(beacon: beacon)
            if beacon.accuracy < 0 {
                NSLog("Ignoring beacon with negative distance")
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
        calculateClosestBeacon()        
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
            
            validateBeaconWithMacList(UUID: (closestBeacon?.proximityUUID.uuidString)!, Major: (closestBeacon?.major.stringValue)!, Minor: (closestBeacon?.minor.stringValue)!)
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
    
    func startMonitoringBeacons() {
        
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    // FORCE STOP BEACON MONITERING
    
    func stopMonitoringBeacons() {
        
        print("STOP MONITERING BEACONS")
        
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion)
        locationManager.stopUpdatingLocation()
    }
    
    // INITALIZING SOUND CODE DETECTECTOR
    
    public func validateBeaconWithMacList(UUID: String, Major: String, Minor: String) {
        
        let beaconList = EywaSDKWifiMacList.SharedManager
        
        let beaconListArray = beaconList.beanconList()
        
        let predicate = NSPredicate(format: "UUID like %@ AND Major like %@ AND Minor like %@",UUID,Major,Minor);
        let filteredArray = beaconListArray.filter { predicate.evaluate(with: $0) };
        
        if filteredArray.count != 0 {
            
            for item in filteredArray {
                
                print("Beacon \(item)")
                
                let beaconInfo = item as? Dictionary<String, Any>
                
                if beaconInfo?.keys.count != 0 {
                    
                    if beaconInfo!["Name"] != nil {
                        
                        delegate?.BroadcastedBeaconInfo(beaconName: beaconInfo!["Name"] as! String)
                    }
                }
            }
        }
    }
}
