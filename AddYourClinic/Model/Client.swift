//
//  Client.swift
//  AddYourClinic
//
//  Created by Nihal Erdal on 4/1/23.
//

import Foundation

class Client{
    
    enum Endpoints{
        
        static let base = "https://sandbox.demo.sainahealth.com/swagger/index.html"
        
        case createHealthProvider
        
        var stringValue: String {
            switch self {
            case .createHealthProvider: return Endpoints.base + "/api/HealthProviders/CreateHealthProvider"
            }
        }
        
        var url: URL{
            return URL(string: stringValue)!
        }
    }
    
    
    
    class func createHealthProvider(city:String, country: String, name: String, state:String, streetAddress: String, zipCode:String, completion: @escaping (String?, Error?)-> Void){
        
        var request = URLRequest(url: Endpoints.createHealthProvider.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = Address(city: city, country: country, name: name, state: state, streetAddress: streetAddress, zipCode: zipCode)
        request.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard data != nil else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            print(String(data: data!, encoding: .utf8)!)
            do {
                let responseObject = try decoder.decode(Response.self, from: data!)
                
                DispatchQueue.main.async {
                    completion(responseObject.message, nil)
                }
                
            }catch{
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
}

