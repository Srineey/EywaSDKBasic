//
//  LocationData.swift
//  EywaBasicSDKCode
//
//  Created by Srinivasa Reddy on 12/1/18.
//  Copyright © 2018 Eywamedia. All rights reserved.
//

import Foundation
import CoreLocation

protocol locationUpdateDelegate: class {
    
    func sendLocationCoordinates(latitude: String, longitude: String)
}

class LocationData : NSObject, CLLocationManagerDelegate {
    
    var locationManager : CLLocationManager!
    weak var delegate: locationUpdateDelegate?
    
    static let SharedManager = LocationData()
    
    override init() {
        
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
                }
            } else {
                print("Location services are not enabled")
            }
        }
    }
    
    func setLocationManager() {
        
        self.locationManager = CLLocationManager()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 50
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        self.locationManager.stopUpdatingLocation()
        self.locationManager = nil
        
        let coordinations = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,longitude: userLocation.coordinate.longitude)
        
//        print("Location coordinations \(coordinations)")
        
        let strLatitude = "\(coordinations.latitude)"
        let strLongitude = "\(coordinations.longitude)"
        
        self.delegate?.sendLocationCoordinates(latitude: strLatitude, longitude: strLongitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error in getting Location \(error)")
    }
}
