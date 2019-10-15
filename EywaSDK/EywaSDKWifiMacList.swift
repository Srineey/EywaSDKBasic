//
//  EywaSDKWifiMacList.swift
//  EywaBasicSDKCode
//
//  Created by Srinivasa Reddy on 7/23/19.
//  Copyright © 2019 Eywamedia. All rights reserved.
//

import UIKit

public class EywaSDKWifiMacList: NSObject {
    
    public static let SharedManager = EywaSDKWifiMacList()
    
    override public init() {
        
        super.init()
    }
    
    func wifiMacList() -> [String:String] {
        
        var macList = [String:String]()
        
        macList = [
            "00:a6:ca:4c:92:90": "117_2F_Desigual",
            "00:a6:ca:4f:a9:1c": "117_1F_Kids_Section",
            "00:a6:ca:4c:92:40": "117_1F_Amante",
            "00:a6:ca:b5:8d:e8": "117_GF_Near_Escalator",
            "00:a6:ca:ce:72:94": "117_2F_ADIDAS",
            "00:a6:ca:b5:87:ec": "117_2F_TrialRoom",
            "84:3d:c6:64:f7:d4": "117_basement_BackOffice",
            "84:3d:c6:65:03:38": "117_Basement_CashCounter",
            "00:a6:ca:4c:93:dc": "117_1F_CashCounter",
            "00:a6:ca:b5:8e:a0": "117_2F_First_Citizen_Desk",
            "00:a2:ee:5f:ea:78": "117_GF_Lakme",
            "00:a2:ee:5f:ea:6c": "117_basement_ArrowSport",
            "00:a6:ca:4c:92:60": "117_GF_CashCounter",
            "00:a6:ca:ce:7f:70": "117_Cafeteria",
            "00:a6:ca:4c:92:70": "117_2F_CashCounter",
            "00:a6:ca:4f:bc:74": "117_GF_MAC",
            "00:a6:ca:4c:81:c0": "117_1F_Front_Of_Escalator",
            "84:3d:c6:65:01:cc": "117_Basement_ParkAvenue",
            "00:a2:ee:91:9c:78": "117_AP00a2.ee91.9c78",
            "00:a6:ca:ce:72:a4": "117_AP00a6.cace.72a4",
            "00:a6:ca:ce:5c:24": "143_GF_RBI",
            "00:a6:ca:ce:5c:00": "143_1F_CSD&FCD",
            "00:a2:ee:5f:cf:0c": "143_GF_BarSection",
            "00:a6:ca:ce:5c:04": "143_1F_CashCounte",
            "00:a6:ca:29:50:c0": "143_GF_LadiesSection",
            "00:a6:ca:b5:6e:28": "143_1F_IPSection",
            "84:3d:c6:64:e6:ac": "143_1F_Wrogn",
            "e0:0e:da:8b:b9:7c": "143_1F_Security",
            "00:a6:ca:4c:67:e4": "143_GF_BackOffice",
            "00:a2:ee:5f:cf:d0": "143_",
            
            "00:d7:8f:33:d4:52": "Bangalore-GF Entry",
            "00:d7:8f:33:d7:32": "Bangalore-GF Billing",
            "00:d7:8f:2b:f4:02": "Bangalore-GF Women",
            "00:d7:8f:08:b4:72": "Bangalore-FF Children",
            "00:d7:8f:23:65:62": "Bangalore-FF Billing",
            "00:d7:8f:07:55:82": "Bangalore-FF Entry",
            "00:d7:8f:23:65:52": "Bangalore-FF Vettorio Fratini",
            
            "B8:27:EB:52:AA:03": "Bangalore-GF Entry",
            "B8:27:EB:EB:05:A2": "Bangalore-GF Billing",
            "B8:27:EB:C2:53:70": "Bangalore-GF Women",
            "B8:27:EB:96:14:9A": "Bangalore-FF Children",
            "B8:27:EB:1A:E1:B3": "Bangalore-UGF Center",
            "B8:27:EB:1F:16:09": "Bangalore-FF Billing",
            "B8:27:EB:64:0F:B3": "Bangalore-FF Entry",
            "B8:27:EB:41:C7:6D": "Bangalore-FF Vettorio Fratini",
            
            "B8:27:EB:C3:FB:C7": "Mumbai-GF Main Entry",
            "B8:27:EB:34:5E:4A": "Mumbai-Ground MAC Entry",
            "B8:27:EB:D7:A7:37": "Mumbai-Ground Billing",
            "B8:27:EB:7A:E0:C1": "Mumbai-Ground CCD Entry",
            "B8:27:EB:21:B7:15": "Mumbai-FF Billing",
            "B8:27:EB:71:0B:53": "Mumbai-SF PVR Entry",
            "B8:27:EB:0F:20:11": "Mumbai-SF PVR Exit",
            "B8:27:EB:04:57:FF": "Mumbai-SF Benetton",
            
            "00:d7:8f:09:20:54": "Mumbai-Basement Billing",
            "00:d7:8f:23:f4:41": "Mumbai-Basement Luggage Bags",
            "00:d7:8f:23:c0:40": "Mumbai-FF Kashish",
            
            "00:d7:8f:09:20:50": "Mumbai-Basement Billing",
            "00:d7:8f:09:20:5f": "Mumbai-Basement Billing",
            "00:d7:8f:23:f4:4f": "Mumbai-Basement Luggage Bags",
            "00:d7:8f:23:f4:40": "Mumbai-Basement Luggage Bags",
            "00:d7:8f:08:f8:cf": "Mumbai-Basement Park Avenue",
            "00:d7:8f:08:f8:c0": "Mumbai-Basement Park Avenue",
            "00:d7:8f:45:3d:5f": "Mumbai-Ground MAC Entry",
            "00:d7:8f:45:3d:50": "Mumbai-Ground MAC Entry",
            "00:d7:8f:8c:66:4f": "Mumbai-Ground Billing",
            "00:d7:8f:8c:66:40": "Mumbai-Ground Billing",
            "00:d7:8f:5a:3e:7f": "Mumbai-Ground Swarovski",
            "00:d7:8f:5a:3e:70": "Mumbai-Ground Swarovski",
            "00:d7:8f:34:41:3f": "Mumbai-Ground CCD Entry",
            "00:d7:8f:34:41:30": "Mumbai-Ground CCD Entry",
            "00:d7:8f:23:c0:4f": "Mumbai-FF Kashish",
            "00:d7:8f:8c:6c:4f": "Mumbai-FF Billing",
            "00:d7:8f:8c:6c:40": "Mumbai-FF Billing",
            "00:a2:ee:ee:17:1f": "Mumbai-FF Pepprmint",
            "00:a2:ee:ee:17:10": "Mumbai-FF Pepprmint",
            "00:d7:8f:8c:65:c0": "Mumbai-FF Amante",
            "00:d7:8f:8c:65:cf": "Mumbai-FF Amante",
            "00:d7:8f:23:c0:20": "Mumbai-SF Levis Men",
            "00:d7:8f:23:c0:2f": "Mumbai-SF Levis Men",
            "00:d7:8f:5a:26:50": "Mumbai-SF Nautica/Being Human",
            "00:d7:8f:5a:26:5f": "Mumbai-SF Nautica/Being Human",
            "00:d7:8f:8c:66:80": "Mumbai-SF Billing",
            "00:d7:8f:8c:66:8f": "Mumbai-SF Billing",
            "00:d7:8f:23:c1:ff": "Mumbai-FF TCP",
            "00:d7:8f:23:c1:f0": "Mumbai-FF TCP",
            
            "00:d7:8f:8c:67:00": "Mumbai-SF Levis Women",
            "00:d7:8f:8c:67:0f": "Mumbai-SF Levis Women",
            
            
            "6C:72:20:F9:CF:4C": "EywaMedia",
            "C8:3A:35:31:AC:30": "EywaMedia",
            "6C:72:20:F9:CF:4D": "EywaMedia",
            
            "B8:27:EB:D0:A4:D7": "EywaMedia",
            "B8:27:EB:3E:46:C1": "EywaMedia",
            "f4:f5:24:af:c4:48": "Eswari - Home",
            "d8:d:17:91:42:ea":  "EywaMedia Chennai"
        ]
        
        return macList
    }
    
    func beanconList() -> Array<Any> {
        
        let beaconsArray = [
            [
                "UUID" : "EF100AE3-8CF5-442C-A445-2E5B3DBEF100",
                "Major": "712",
                "Minor": "183",
                "Name" : "SS-J-Test1 (Vodafone)"//SS-J - GF - Main Entrance
            ],
            [
                "UUID" : "EF100AE3-8CF5-442C-A445-2E5B3DBEF100",
                "Major": "712",
                "Minor": "176",
                "Name" : "SS-J-Test2 (Airtel)"//SS-J - SF - PVR Exit
            ],
            [
                "UUID" : "EF100AE3-8CF5-442C-A445-2E5B3DBEF100",
                "Major": "712",
                "Minor": "39",
                "Name" : "SS-J-Test3 (Airtel)"//SS-J - GF - Opp to Billing
            ],
            [
                "UUID" : "EF100AE3-8CF5-442C-A445-2E5B3DBEF100",
                "Major": "1",
                "Minor": "167",
                "Name" : "EYWA-CHN-TEST1"
            ],
            [
                "UUID" : "EF100AE3-8CF5-442C-A445-2E5B3DBEF100",
                "Major": "1",
                "Minor": "165",
                "Name" : "EYWA-CHN-TEST2"
            ]
        ]
        
        return beaconsArray
    }
}
