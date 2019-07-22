//
//  EywaSDKResponseManager.swift
//  EywaBasicSDKCode
//
//  Created by Srinivasa Reddy on 10/12/18.
//  Copyright © 2018 Eywamedia. All rights reserved.
//

import Foundation

class EywaSDKResponseManager {
    
    static func getInstallationId(urlString : String, params: NSDictionary, completionHandler: @escaping (Data, Bool) -> Swift.Void) {
        
        guard let serviceUrl = URL(string: urlString) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Accept")
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("\(postData.length)", forHTTPHeaderField: "Content-Length")
//        request.httpBody = postData as Data
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            /*if let response = response {
                print(response)

                completionHandler(response, true)
            }
            print("Error is \(String(describing: error))")*/
            
            if let data = data {
                do {
                    let _ = try JSONSerialization.jsonObject(with: data, options: [])
//                    print(json)
                    completionHandler(data, false)
                }catch {
                    print(error)
                    completionHandler(data, true)
                }
            }
            }.resume()
    }
}

