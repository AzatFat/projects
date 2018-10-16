//
//  ReceiptController.swift
//  Djinaro
//
//  Created by Azat on 14.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import Foundation

class ReceiptController {
    let baseURL = URL(string: "http://91.203.195.74:5001/api/")!
    
    func GetReceipts(completion: @escaping ([Receipt]?) -> Void) {
        let GetReceipt = baseURL.appendingPathComponent("Receipt")
        let components = URLComponents(url: GetReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        let task = URLSession.shared.dataTask(with: ReceiptURL) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode([Receipt].self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode([Receipt].self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in getting Receipts")
                        print(error)
                        completion(nil)
                    }
                }
                
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    
    func GetGoods(completion: @escaping ([Goods]?) -> Void) {
        let GetReceipt = baseURL.appendingPathComponent("Goods/")
        let components = URLComponents(url: GetReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        let task = URLSession.shared.dataTask(with: ReceiptURL) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode([Goods].self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode([Goods].self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in getting Goods")
                        print(error)
                        completion(nil)
                    }
                }
                
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    func GetGood(goodId: String, completion: @escaping (Goods?) -> Void) {
        let GetGood = baseURL.appendingPathComponent("Goods/" + goodId)
        let components = URLComponents(url: GetGood, resolvingAgainstBaseURL: true)!
        let GoodURL = components.url!
        let task = URLSession.shared.dataTask(with: GoodURL) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(Goods.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(Goods.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in getting Good")
                        print(error)
                        completion(nil)
                    }
                }
                
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    
    func postGood(post: Goods, completion: ((Error?) -> Void)?) {
        
        let GoodPostUrl = baseURL.appendingPathComponent("Goods")
        let components = URLComponents(url: GoodPostUrl, resolvingAgainstBaseURL: true)!
        let GoodURL = components.url!
        var request = URLRequest(url: GoodURL)
        request.httpMethod = "POST"
        
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(post)
            // ... and set our request's HTTP body
            request.httpBody = jsonData
            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
        } catch {
            completion?(error)
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else {
                completion?(responseError!)
                return
            }
            
            // APIs usually respond with the data you just sent in your POST request
            if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                print("response: ", utf8Representation)
            } else {
                print("no readable data received in response")
            }
        }
        task.resume()
    }
}
