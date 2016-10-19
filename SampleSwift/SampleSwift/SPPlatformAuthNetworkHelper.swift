//
//  SPPlatformAuthNetworkHelper.swift
//  Pods
//
//  Created by Subhransu Behera on 28/9/16.
//
//

import Foundation

class SPPlatformAuthNetworkHelper {
    func GET(urlString: String, successHandler success: @escaping SPPlatformAuthNetworkSuccess, errorHandler failure: @escaping SPPlatformAuthNetworkError) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        guard let url = URL(string: urlString) else {
            failure(nil)
            return
        }
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if let httpResponse = response {
                guard let data = data else {
                    failure(nil)
                    return
                }
                
                var e: Error?
                
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                    success(jsonData)
                } catch {
                    failure(nil)
                }
            }
        }
        
        task.resume()
    }
    
    func POST(urlString: String, parameters: [String: String], successHandler success: @escaping SPPlatformAuthNetworkSuccess, errorHandler failure: @escaping SPPlatformAuthNetworkError) {
        
        guard let url = URL(string: urlString) else {
            failure(nil)
            return
        }
        
        var request = URLRequest(url: url)
        
        let session = URLSession.shared
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            failure(nil)
            return
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                
                if SPPlatformAuthNetworkHelper.isSuccessHTTPStatusCode(response: httpResponse) {
                    guard let data = data else {
                        failure(nil)
                        return
                    }
                    
                    var e: Error?
                    
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                        success(jsonData)
                    } catch {
                        failure(nil)
                    }
                } else {
                    failure(nil)
                }
            }
        }
        
        task.resume()
    }
    
    static func isSuccessHTTPStatusCode(response: HTTPURLResponse) -> Bool {
        switch(response.statusCode) {
        case 200:
            return true
        default:
            return false
        }
    }
}
