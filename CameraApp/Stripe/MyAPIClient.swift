//
//  BackendAPIAdapter.swift
//  Basic Integration
//
//  Created by Ben Guo on 4/15/16.
//  Copyright © 2016 Stripe. All rights reserved.
//

import Foundation
import Stripe
import PassKit
import FirebaseAuth

class MyAPIClient: NSObject, STPCustomerEphemeralKeyProvider {
    enum APIError: Error {
        case unknown

        var localizedDescription: String {
            switch self {
            case .unknown:
                return "Unknown error"
            }
        }
    }

    static let sharedClient = MyAPIClient()
    var baseURLString: String?
    var baseURL: URL {
        if let urlString = self.baseURLString, let url = URL(string: urlString) {
            return url
        } else {
            fatalError()
        }
    }

    func createPaymentIntent(shippingMethod: PKShippingMethod?, country: String? = nil, paymentId: String, completion: @escaping ((Result<String, Error>) -> Void)) {
        let url = self.baseURL.appendingPathComponent("create_payment_intent")
        var params: [String: Any] = [
            "metadata": [
                // example-mobile-backend allows passing metadata through to Stripe
                "payment_request_id": "B3E611D1-5FA1-4410-9CEC-00958A5126CB"
            ]
        ]
        params["products"] = ["Roll"]
        if let shippingMethod = shippingMethod {
            params["shipping"] = shippingMethod.identifier
        }
        params["country"] = country
        params["payment_method_id"] = paymentId
        params["customer_id"] = Pref.shared.customerId

        let jsonData = try? JSONSerialization.data(withJSONObject: params)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data,
                let json = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String: Any]??),
                let secret = json?["secret"] as? String else {
                    completion(.failure(error ?? APIError.unknown))
                    return
            }
            completion(.success(secret))
        })
        task.resume()
    }
    
    func createApplePaymentIntent(shippingMethod: PKShippingMethod?, country: String? = nil, completion: @escaping ((Result<String, Error>) -> Void)) {
        let url = self.baseURL.appendingPathComponent("create_apple_payment_intent")
        var params: [String: Any] = [
            "metadata": [
                // example-mobile-backend allows passing metadata through to Stripe
                "payment_request_id": "B3E611D1-5FA1-4410-9CEC-00958A5126CB"
            ]
        ]
        params["products"] = ["Roll"]
        if let shippingMethod = shippingMethod {
            params["shipping"] = shippingMethod.identifier
        }
        params["country"] = country
        params["customer_id"] = Pref.shared.customerId
        
        let jsonData = try? JSONSerialization.data(withJSONObject: params)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data,
                let json = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String: Any]??),
                let secret = json?["secret"] as? String else {
                    completion(.failure(error ?? APIError.unknown))
                    return
            }
            completion(.success(secret))
        })
        task.resume()
    }

    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let url = self.baseURL.appendingPathComponent("ephemeral_keys")
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        
        urlComponents.queryItems = [URLQueryItem(name: "api_version", value: apiVersion),URLQueryItem(name: "customerId", value: Pref.shared.customerId)]
        
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data,
                let json = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String: Any]??) else {
                completion(nil, error)
                return
            }
            completion(json, nil)
        })
        task.resume()
    }

    func createNewCustomer(withAPIVersion apiVersion : String, success: ((String) -> Void)?, error: ((String) -> Void)?)
    {
       

        let path = "create_customer"
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var parameters = ["email" : Auth.auth().currentUser?.email]
        parameters["description"] =  "Philm Customer"

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let err {
            error!(err.localizedDescription)
            print("error while serialization parameters is \(err.localizedDescription)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, err) in

            if let actualError = err {
                error!(actualError.localizedDescription)
                print("error from createNewCustomer API is \(actualError)")
                return
            }

            if let httpResponse = urlResponse as? HTTPURLResponse {
                print("httpResponse is \(httpResponse.statusCode)")

                if (httpResponse.statusCode == 200)
                {
                    // eventually we'll want to get this into an actual complex JSON response / structure
                    if let actualData = data
                    {
                        if let customerIDString = String(data: actualData, encoding: .utf8) {
                            print("customer id string is \(customerIDString)")

                            do{
                                if let json = customerIDString.data(using: String.Encoding.utf8){
                                    if let jsonData = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String:AnyObject]{
                                        let customerId = jsonData["id"] as! String
                                        
                                        let originalcustomerid = Pref.shared.customerId
                                        if customerId != originalcustomerid
                                        {
                                            Pref.shared.setPref(.customerId, value: customerId)
                                        }
                                        success!(customerId)
                                        
                                    }
                                }
                            }catch {
                                
                            }
                            
 
                        }
                    }
                    
                }
            } else {
                error!("unexpected response")
                assertionFailure("unexpected response")
            }
        }
        task.resume()
    }
    
    func isExsitCustomer(customerId : String, result: ((Bool) -> Void)?) {
        let url = self.baseURL.appendingPathComponent("getCustomer")
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        
        urlComponents.queryItems = [URLQueryItem(name: "customerId", value: Pref.shared.customerId)]
        
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data,
                let json = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String: Any]??) else {
                result!(false)
                return
            }
            if json!.isEmpty {
                result!(false)
            }else{
                result!(true)
            }
        })
        task.resume()
    }
}
