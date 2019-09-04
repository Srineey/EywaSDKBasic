//
//  EywaSDKCodeManager.swift
//  EywaBasicSDKCode
//
//  Created by Srinivasa Reddy on 7/21/18.
//  Copyright © 2018 Eywamedia. All rights reserved.
//

import Foundation
import CoreLocation

public class EywaSDKCodeManager : NSObject, CLLocationManagerDelegate, locationUpdateDelegate {
    
//    var locationManager = CLLocationManager()
    
    public static let SharedManager = EywaSDKCodeManager()
    var locationCoordinatesArray : NSMutableArray = NSMutableArray()
    var accessTimeArray : NSMutableArray = NSMutableArray()
    var isAllowToUpdateInstallApi : Bool = false
    public var kLicenseKey : String = ""
    
    //MARK: init()
    
    override public init() {
        
        super.init()
        
        print("Init EywaSDK Success")
        
        OperationQueue.main.addOperation{
            
             NotificationCenter.default.addObserver(self, selector: #selector(self.locationServicesDisabledNotifier), name: NSNotification.Name(rawValue: "LocationServicesDisabled"), object: nil)
            
            let userLocation = LocationData.SharedManager
            userLocation.delegate = self
        }
    }
    
    //MARK: Check LicenseKey Api

    public func licenseKeyCheck(completion:@escaping(Bool) -> Void) {
        
        print("EywaSDK LicenseKeyCheck Called")
        
        if UserDefaults.standard.value(forKey: EywaConstants.kEywaInstallationId) == nil {
            
            if EywaSDKCodeManager.SharedManager.kLicenseKey != "" {
                
                let liesenceUrl = EywaConstants.kBaseURL+EywaSDKCodeManager.SharedManager.kLicenseKey
                
                let myUrl = NSURL(string: liesenceUrl);
                let request = NSMutableURLRequest(url:myUrl! as URL);
                
                // Excute HTTP Request
                let task = URLSession.shared.dataTask(with: request as URLRequest) {
                    data, response, error in
                    
                    // Check for error
                    if error != nil
                    {
                        print("error=\(String(describing: error) )")
                        completion(false)
                        return
                    }
                    
                    // Convert server json response to NSDictionary
                    do {
                        if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                            
                            // Print out dictionary
                            //                            print(convertedJsonIntoDict)
                            
                            let licenceKeyArr = convertedJsonIntoDict.allKeys as Array
                            
                            if licenceKeyArr.count != 0 {
                                
                                let licenceKeyStr : String = (licenceKeyArr[0] as? String)!
                                
                                let licenseDict : NSDictionary = convertedJsonIntoDict[licenceKeyStr] as! NSDictionary
                                
                                if licenseDict["errorcode"] != nil {
                                    
                                    let errorCode = (licenseDict["errorcode"] as? NSString)?.doubleValue
                                    
                                    if errorCode == 0 {
                                        
                                        if licenseDict["APIVersion"] != nil {
                                            
                                            if let apiVersion = licenseDict["APIVersion"] as? String {
                                                
                                                //                                    print("LicenseAPI Version \(apiVersion)")
                                                
                                                UserDefaults.standard.set(apiVersion, forKey: EywaConstants.kLincenseAPIVersion)
                                            }
                                        }
                                        
                                        if licenseDict["InstallAPI"] != nil {
                                            
                                            if let _ = licenseDict["InstallAPI"] as? String {
                                                
                                                let installApiString = licenseDict["InstallAPI"] as! String
                                                
                                                if installApiString == "" {
                                                    
                                                    self.getServerLocation(licenseDict: licenseDict)
                                                }
                                                else
                                                {
                                                    //                                        print(installApiString)
                                                    
                                                    UserDefaults.standard.set(installApiString, forKey: EywaConstants.kInstallApiURL)
                                                }
                                            }
                                            else
                                            {
                                                self.getServerLocation(licenseDict: licenseDict)
                                            }
                                        }
                                        else
                                        {
                                            self.getServerLocation(licenseDict: licenseDict)
                                        }
                                        
                                        if licenseDict["UpdateInstallAPI"] != nil {
                                            
                                            if let _ = licenseDict["UpdateInstallAPI"] as? String {
                                                
                                                let installApiString = licenseDict["UpdateInstallAPI"] as! String
                                                
                                                if installApiString == "" {
                                                    
                                                    self.getUpdateLocationAPI(licenseDict: licenseDict)
                                                }
                                                else
                                                {
                                                    //                                        print(installApiString)
                                                    
                                                    UserDefaults.standard.set(installApiString, forKey: EywaConstants.kUpdateInstallApiURL)
                                                }
                                            }
                                            else
                                            {
                                                self.getUpdateLocationAPI(licenseDict: licenseDict)
                                            }
                                        }
                                        else
                                        {
                                            self.getUpdateLocationAPI(licenseDict: licenseDict)
                                        }
                                        
                                        if licenseDict["DocType"] != nil {
                                            
                                            let docTypeString = licenseDict["DocType"] as! String
                                            
                                            UserDefaults.standard.set(docTypeString, forKey: EywaConstants.kLicenseDocType)
                                        }
                                        
//                                        self.getInstallationId()
                                        self.getInstallationId() {
                                            (isSuccess:Bool) in
                                            
                                            if isSuccess {
                                                completion(true)
                                            }
                                            else {
                                                completion(false)
                                            }
                                        }
                                    }
                                    else {
                                        print("EywaSDK - Invalid License Key")
                                        completion(false)
                                    }
                                }
                            }
                            
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                    
                }
                
                task.resume()
                
                //                return true
                
            }
            else {
                print("EywaSDK - LicenseKey is empty")
                completion(false)
            }
        }
        else {
            completion(true)
            self.getUserTrackingInfo()
        }
    }
    
    //MARK: Get Server Location
    
    private func getServerLocation(licenseDict : NSDictionary) {
        
        if licenseDict["ServerLocation"] != nil {
            
            if let serverLocationString = licenseDict["ServerLocation"] as? String {
                
//                print(serverLocationString)
                
                let stringInstallApiURL = serverLocationString+"installation"
                
                UserDefaults.standard.set(stringInstallApiURL, forKey: EywaConstants.kInstallApiURL)
                
//                self.getInstallationId()
            }
            else {
                
                print("EywaSDK - No ServiceLocation Found")
            }
        }
    }
    
    //MARK: Get Update Install URL
    
    private func getUpdateLocationAPI(licenseDict : NSDictionary) {
        
        if licenseDict["ServerLocation"] != nil {
            
            if let serverLocationString = licenseDict["ServerLocation"] as? String {
                
//                print(serverLocationString)
                
                UserDefaults.standard.set(serverLocationString, forKey: EywaConstants.kServerLocationUpdateApi)
                
            }
            else {
                
                print("EywaSDK - No ServiceLocation Found")
            }
        }
    }
    
    //MARK: Get Installation Id Api
    
    private func getInstallationId(completion:@escaping(Bool) -> Void) {
        
        let paramDictData : NSDictionary = self.jsonUserData()
        
        let installApiUrl : String = UserDefaults.standard.value(forKey: EywaConstants.kInstallApiURL) as? String ?? ""
        
//        print("InstallAPIBaseURL \(installApiUrl)")
        
        EywaSDKResponseManager.getInstallationId(urlString: installApiUrl, params: paramDictData) {
            
            (responseData : Data, error: Bool) in
            
            if !error {
                
//                let installationStr = String(data: responseData , encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
//                print("Installation String is \(installationStr ?? "")")
                
                do {
                    if let installationDict = try JSONSerialization.jsonObject(with: responseData, options: []) as? NSDictionary {
                        
                        if installationDict["id"] != nil {
                            
                            if let _ = installationDict["id"] as? String {
                                
                                let installID = installationDict["id"] as! String
                                
//                                print("Installation Id is \(installID)")
                                
                                UserDefaults.standard.setValue(installID, forKey: EywaConstants.kEywaInstallationId)
                                
                                completion(true)
                                
                                if !self.isAllowToUpdateInstallApi {
                                    
                                    self.isAllowToUpdateInstallApi = true
                                    
                                    self.getUserTrackingInfo()
                                }
                            }
                        }
                        else {
                            completion(false)
                        }
                    }
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                    completion(false)
                }
            }
            else {
                
                print("EywaSDK - Error in Getting Installation ID")
                
                completion(false)
            }
        }
    }
    
    //MARK: Send User Location and Access Time Api (UpdateInstallApi)
    
    private func sendUserTrackingInfo() {
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.object(forKey: EywaConstants.kLocationCoordinatesArray) != nil {
            
            if let _ = userDefaults.object(forKey: EywaConstants.kLocationCoordinatesArray) as? NSMutableArray {
                
                locationCoordinatesArray = userDefaults.object(forKey: EywaConstants.kLocationCoordinatesArray) as! NSMutableArray
            }
        }
        
        if userDefaults.object(forKey: EywaConstants.kAccessTimeArray) != nil {
            
            if let _ = userDefaults.object(forKey: EywaConstants.kAccessTimeArray) as? NSMutableArray {
                
                accessTimeArray = userDefaults.object(forKey: EywaConstants.kAccessTimeArray) as! NSMutableArray
            }
        }
        
        if accessTimeArray.count != 0 {
            
            if userDefaults.object(forKey: EywaConstants.kLicenseDocType) != nil && userDefaults.object(forKey: EywaConstants.kEywaInstallationId) != nil && userDefaults.object(forKey: EywaConstants.kServerLocationUpdateApi) != nil {
                
                let docTypeStr = userDefaults.object(forKey: EywaConstants.kLicenseDocType) as! String
                let installationIdStr = userDefaults.object(forKey: EywaConstants.kEywaInstallationId) as! String
                let serverConfigStr = userDefaults.object(forKey: EywaConstants.kServerLocationUpdateApi) as! String
                
                let updateInstallApi = serverConfigStr+"elasticsearch?index=installation&m=update&type="+docTypeStr+"&id="+installationIdStr
                
//                print("Update Install Api \(updateInstallApi)")
                
                let paramDictData : NSDictionary
                
                if locationCoordinatesArray.count == 0
                {
                    paramDictData = ["AccessTime":accessTimeArray]
                }
                else {
                    
                    paramDictData = ["Location":locationCoordinatesArray,"AccessTime":accessTimeArray]
                }
                
//                print("Update Install Api Parameters \(paramDictData)")
                
                EywaSDKResponseManager.getInstallationId(urlString: updateInstallApi, params: paramDictData as NSDictionary) {
                    
                    (responseData : Data, error: Bool) in
                    
                    if !error {
                        
                        print("EywaSDK - User Information Updated in Server")
                        
                        do {
                            if let updateInstallDict = try JSONSerialization.jsonObject(with: responseData, options: []) as? NSDictionary {
                                
//                                print("Update Install Response \(updateInstallDict)")
                                
                                if updateInstallDict["APIVersion"] != nil {
                                    
                                    if let updateInstallAPIVersion = updateInstallDict["APIVersion"] as? String {
                                        
                                        self.compareAPIVersions(updateInstallApiVersion: updateInstallAPIVersion)
                                    }
                                }
                            }
                        }
                        catch let error as NSError {
                            print(error.localizedDescription)
                        }
                    }
                    else {
                        
                        print("EywaSDK - Error in Getting Installation ID")
                    }
                }
            }
            else
            {
                 print("EywaSDK - Can't able to update install api. Due to DocType/InstallationId/ServerConfig is nil")
            }
        }
        else {
            
            print("EywaSDK - Can't able to update install api. Due to Location/AccessTime data missing ")
//            self.sendUserTrackingInfo()
        }
    }
    
    //MARK: Get User Location and Access Time
    
    private func getUserTrackingInfo() {
        
        if isAllowToUpdateInstallApi {
            
            isAllowToUpdateInstallApi = false
            
            //        _ = EywaSDKCodeManager()
            self.getDeviceCurrentTime()
            
            if UserDefaults.standard.object(forKey: EywaConstants.kLastUpdateInstallApi_Time) != nil {
                
                let lastUpdatedDate = UserDefaults.standard.object(forKey: EywaConstants.kLastUpdateInstallApi_Time) as! Date
                
                //            let lastUpdatedDate = Date().adding(hours: -26)
                
//                let diff = Date().hours(from: lastUpdatedDate)
                
//                print("Date Difference Hours \(diff)")
                
                if Date().hours(from: lastUpdatedDate) > 24 {
                
                    self.sendUserTrackingInfo()
                }
                else {

                    print("EywaSDK - User Monitoring Information Updated less than 24 Hours ago")
                }
            }
            else {
                
                self.sendUserTrackingInfo()
            }
        }
    }
    
    //MARK: Get Location Coordinates Delegate
    
    func sendLocationCoordinates(latitude: String, longitude: String) {
        
        print("EywaSDK - The User Location Coordinates are \(latitude) and \(longitude)")
        
        let userDefaults = UserDefaults.standard
        
        if latitude == "" {
            
            print("EywaSDK - Location Services Disabled")
        }
        else {
            
            if userDefaults.object(forKey: EywaConstants.kLocationCoordinatesArray) != nil {
                
                if let _ = userDefaults.object(forKey: EywaConstants.kLocationCoordinatesArray) as? NSArray {
                    
                    let tempArr : NSArray = userDefaults.object(forKey: EywaConstants.kLocationCoordinatesArray) as! NSArray
                    
                    locationCoordinatesArray = NSMutableArray.init(array: tempArr)
                    
                    if locationCoordinatesArray.count != 0 {
                        
                        let tempArray : NSArray = [latitude,longitude]
                        
                        let tempMutableArray = NSMutableArray.init(array: locationCoordinatesArray)
                        
                        tempMutableArray.add(tempArray.mutableCopy())
                        
                        locationCoordinatesArray = NSMutableArray.init(array: tempMutableArray)
                        
                        userDefaults.setValue(locationCoordinatesArray, forKey: EywaConstants.kLocationCoordinatesArray)
                    }
                    else {
                        
                        let tempArray : NSArray = [latitude,longitude]
                        
                        locationCoordinatesArray = NSMutableArray.init()
                        
                        locationCoordinatesArray.add(tempArray)
                        
                        userDefaults.setValue(locationCoordinatesArray, forKey: EywaConstants.kLocationCoordinatesArray)
                    }
                }
                else {
                    
                    let tempArray : NSArray = [latitude,longitude]
                    
                    locationCoordinatesArray = NSMutableArray.init()
                    
                    locationCoordinatesArray.add(tempArray)
                    
                    userDefaults.setValue(locationCoordinatesArray, forKey: EywaConstants.kLocationCoordinatesArray)
                    
                }
            }
            else {
                
                let tempArray : NSArray = [latitude,longitude]
                
                locationCoordinatesArray = NSMutableArray.init()
                
                locationCoordinatesArray.add(tempArray)
                
                userDefaults.setValue(locationCoordinatesArray, forKey: EywaConstants.kLocationCoordinatesArray)
            }
            
//            print("Location Coordinates Array \(userDefaults.object(forKey: EywaConstants.kLocationCoordinatesArray) ?? "")")
        }
        
        if userDefaults.object(forKey: EywaConstants.kLicenseDocType) != nil && userDefaults.object(forKey: EywaConstants.kEywaInstallationId) != nil && userDefaults.object(forKey: EywaConstants.kServerLocationUpdateApi) != nil {
            
            isAllowToUpdateInstallApi = true
            self.getUserTrackingInfo()
        }
        else {
            
            isAllowToUpdateInstallApi = false
        }
    }
    
    //MARK: LocationServicesDisabled Notifier
    
    @objc func locationServicesDisabledNotifier() {
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.object(forKey: EywaConstants.kLicenseDocType) != nil && userDefaults.object(forKey: EywaConstants.kEywaInstallationId) != nil && userDefaults.object(forKey: EywaConstants.kServerLocationUpdateApi) != nil {
            
            isAllowToUpdateInstallApi = true
            self.getUserTrackingInfo()
        }
        else {
            
            isAllowToUpdateInstallApi = false
        }
    }
    
    //MARK: Get Current Time in ms
    
    private func getDeviceCurrentTime() {
        
        /*// create dateFormatter with UTC time format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = (NSTimeZone(name: "UTC")! as TimeZone)
        let date = Date()
        
        // change to a readable time format and change to local time zone
        dateFormatter.dateFormat = "EEE, MMM d, yyyy - h:mm a"
        dateFormatter.timeZone = NSTimeZone.local
        let timeStamp = dateFormatter.string(from: date)*/
        
//        print("Current Date \(timeStamp)")
        
        let currentDate_In_milliSec = Date().millisecondsSince1970
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.object(forKey: EywaConstants.kAccessTimeArray) != nil {
            
            if let _ = userDefaults.object(forKey: EywaConstants.kAccessTimeArray) as? NSArray {
                
                let tempArr : NSArray = userDefaults.object(forKey: EywaConstants.kAccessTimeArray) as! NSArray
                
                accessTimeArray = NSMutableArray.init(array: tempArr)
                
                if accessTimeArray.count != 0 {
                    
                    let tempAccessTimeArray = NSMutableArray.init(array: accessTimeArray)
                    
                    tempAccessTimeArray.add(currentDate_In_milliSec)
                    
                    accessTimeArray = NSMutableArray.init(array: tempAccessTimeArray)
                    
                    userDefaults.setValue(accessTimeArray, forKey: EywaConstants.kAccessTimeArray)
                }
                else {
                    
                    accessTimeArray = NSMutableArray.init()
                    
                    accessTimeArray.add(currentDate_In_milliSec)
                    
                    userDefaults.setValue(accessTimeArray, forKey: EywaConstants.kAccessTimeArray)
                }
            }
            else {
                
                accessTimeArray = NSMutableArray.init()
                
                accessTimeArray.add(currentDate_In_milliSec)
                
                userDefaults.setValue(accessTimeArray, forKey: EywaConstants.kAccessTimeArray)
            }
        }
        else {
            
            accessTimeArray = NSMutableArray.init()
            
            accessTimeArray.add(currentDate_In_milliSec)
            
            userDefaults.setValue(accessTimeArray, forKey: EywaConstants.kAccessTimeArray)
        }
        
//        print("Current Date Array: \(userDefaults.object(forKey: EywaConstants.kAccessTimeArray) ?? "")")
    }
    
    //MARK: Compare LicenseAPIVersion and UpdateInstallAPIVersion
    
    private func compareAPIVersions(updateInstallApiVersion : String) {
        
        var licenseApiVersion : String = ""
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.object(forKey: EywaConstants.kLincenseAPIVersion) != nil {
            
            licenseApiVersion = userDefaults.object(forKey: EywaConstants.kLincenseAPIVersion) as! String
        }
        
//        licenseApiVersion = "2.0"
        
        if licenseApiVersion == updateInstallApiVersion {
            
//            print("Both API Versions are EQUAL")
            
            let emptyArray : NSMutableArray = NSMutableArray.init()
            
            userDefaults.set(emptyArray, forKey: EywaConstants.kLocationCoordinatesArray)
            userDefaults.set(emptyArray, forKey: EywaConstants.kAccessTimeArray)
            userDefaults.set(Date(), forKey: EywaConstants.kLastUpdateInstallApi_Time)
        }
        else {
            
            print("EywaSDK - Both API Versions are NOT EQUAL")
            userDefaults.removeObject(forKey: EywaConstants.kEywaInstallationId)
            self.licenseKeyCheck() {
                (isValidLicense:Bool) in
                
                if isValidLicense {
                    print("Valid License")
                }
            }
        }
    }
    
    //MARK: User Info Json Data
    
    private func jsonUserData() -> NSDictionary {
        
        let installationInfo : NSMutableDictionary = NSMutableDictionary.init()
        
        let deviceHelper = EywaSDKCodeDeviceHelper()
        
        let deviceId = deviceHelper.getUniqueIdentifier()
        let deviceOS = deviceHelper.getiOSVersion()
        let appVersion = deviceHelper.getAppOSversion()
        let deviceModel = deviceHelper.getDeviceModel()
        let macAddress = deviceHelper.getMacAddress()
        let deviceManufacturer = deviceHelper.getManufacturer()
        let ipAddress = deviceHelper.getIPAddress()
        let simOperator = deviceHelper.getSIMCarrierName()
        let IDFA = deviceHelper.getIDFA()
        let docType = UserDefaults.standard.value(forKey: "DocType") as? String ?? ""
        
        installationInfo.setValue(deviceId, forKey: "DeviceId")
        installationInfo.setValue(deviceModel, forKey: "Model")
        installationInfo.setValue(macAddress, forKey: "MACAddress")
        installationInfo.setValue(appVersion, forKey: "AppVersion")
        installationInfo.setValue(deviceOS, forKey: "DeviceOS")
        installationInfo.setValue(deviceId, forKey: "UserName")
        installationInfo.setValue(deviceManufacturer, forKey: "Manufacturer")
        installationInfo.setValue(ipAddress, forKey: "IPAddress")
        installationInfo.setValue(IDFA, forKey: "AdvertisementId")
        installationInfo.setValue(simOperator, forKey: "Operator")
        
        installationInfo.setValue(NSNumber.init(value: 0), forKey: "DataState")
        installationInfo.setValue(NSNumber.init(value: 1), forKey: "PhoneType")
        installationInfo.setValue("", forKey: "SubscriberId")
        installationInfo.setValue("", forKey: "SimState")
        installationInfo.setValue("", forKey: "SerialNumber")
        installationInfo.setValue(NSNumber.init(value: 0), forKey: "NetworkType")
        installationInfo.setValue("", forKey: "SimSerialNumber")
        installationInfo.setValue("", forKey: "LineNumber")
        installationInfo.setValue("", forKey: "RouterIPAddress")
        installationInfo.setValue(NSNumber.init(value: 0), forKey: "CallState")
        installationInfo.setValue(docType, forKey: "DocType")
        
        
        UserDefaults.standard.setValue(deviceId, forKey: "EywaUserId")
        
        
        
//        let jsonDict = NSDictionary.init(object: installationInfo, forKey: docType as NSCopying)
//        var jsonData: NSData = NSData.init()
        
//        print("Json Dict \(installationInfo)")
        
        return installationInfo
        
        /*if JSONSerialization.isValidJSONObject(jsonDict) {
            
//            let error : NSError!
            
            do {
                
                jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted) as NSData
                return jsonData
            }
            catch _ {
                print ("JSON Failure")
            }
        }
        
        return jsonData*/
    }
}

extension Date {
    
    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    
    func adding(hours: Int) -> Date {
        return Calendar.current.date(byAdding: .hour, value: hours, to: self)!
    }
    
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}
