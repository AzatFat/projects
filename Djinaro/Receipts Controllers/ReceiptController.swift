//
//  ReceiptController.swift
//  Djinaro
//
//  Created by Azat on 14.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import Foundation
import UIKit

class ReceiptController : UIViewController {
    let baseURL = URL(string: "http://91.203.195.74:5001")!
    var token : String?
    var tokenType : String?

// Token
    
    func POSTToken (username: String, password: String, completion: @escaping (Token?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/Token")
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let params = "grant_type=password&username=\(username)&password=\(password)"
        request.httpBody = params.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                //print(String(data: data, encoding: String.Encoding.utf8))
                if let list = try? jsonDecoder.decode(Token.self, from: data) {
                    print("token is \(list)")
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(Token.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in Post Token + \(error)")
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
//checkToken
    func denyAuthorisation(data: Data) {

        do {
            let decoder = JSONDecoder()
            let product = try decoder.decode(DenyInAuthorisation.self, from: data)
            if product.Message == "Для этого запроса отказано в авторизации." {
                print("trying change view")
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                self.present(newViewController, animated: true, completion: nil)
            }
            
        } catch let error {
            print("error in getting making SignOut")
            print(error)
        }
    }
    
///User Info
    func GetUserInfo(token: String, completion: @escaping (UserInfo?) -> Void) {
        let GetReceipt = baseURL.appendingPathComponent("/api/ReceiptDocument")
        let components = URLComponents(url: GetReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(UserInfo.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(UserInfo.self, from: data)
                        print(product)
                        completion(product)
                    } catch let error {
                        print("error in getting User Info")
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
                
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    
// Список документов поступлениий
    func GetReceiptDocuments(token: String, completion: @escaping ([ReceiptDocument]?) -> Void) {
        let GetReceipt = baseURL.appendingPathComponent("/api/ReceiptDocument")
        let components = URLComponents(url: GetReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request){ (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode([ReceiptDocument].self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode([ReceiptDocument].self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in getting ReceiptDocuments")
                        print(error)
                        DispatchQueue.main.async {
                            self.denyAuthorisation(data: data)
                        }
                        completion(nil)
                    }
                }
                
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    
    func POSTReceiptDocument (token: String, post: ReceiptDocument, completion: @escaping (ReceiptDocument?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/ReceiptDocument")
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let jsonEcoder = JSONEncoder()
        let jsonData = try? jsonEcoder.encode(post)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(ReceiptDocument.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(ReceiptDocument.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in Post ReceiptsDOcument")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func CLOSEReceiptDocument (token: String, post: ReceiptDocument, completion: @escaping (ReceiptDocument?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/ReceiptDocument/Close/" + String(post.id))
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(ReceiptDocument.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(ReceiptDocument.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in Post ReceiptsDocument")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func PUTReceiptDocument (token: String, put: ReceiptDocument, id: String,completion: @escaping (ReceiptDocument?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/ReceiptDocument/" + id)
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let jsonEcoder = JSONEncoder()
        let jsonData = try? jsonEcoder.encode(put)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(ReceiptDocument.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(ReceiptDocument.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in Post ReceiptsDOcument")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    
    func GetReceiptDocument(token: String, id: String,completion: @escaping (ReceiptDocument?) -> Void) {
        let GetReceipt = baseURL.appendingPathComponent("/api/ReceiptDocument/" + id)
        let components = URLComponents(url: GetReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(ReceiptDocument.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(ReceiptDocument.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in getting ReceiptDocument")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
                
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    func DELETEReceiptDocument (token: String,id: String,completion: @escaping (ReceiptDocument?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/ReceiptDocument/" + id)
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(ReceiptDocument.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(ReceiptDocument.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in DELETE ReceiptsDOcument")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    
    func PRINTReceiptDocument (token: String,post: ReceiptDocument, completion: @escaping (String?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/ReceiptDocument/PrintLabel/" + String(post.id))
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            if let data = data{
                let answer = String(data: data, encoding: String.Encoding.utf8)
                    completion(answer ?? "Неизвестная ошибка")
            } else {
                completion("Не успех")
            }
        }
        task.resume()
    }
    
    func GetReceipts(token: String,completion: @escaping ([Receipt]?) -> Void) {
        let GetReceipt = baseURL.appendingPathComponent("/api/Receipt")
        let components = URLComponents(url: GetReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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
                        self.denyAuthorisation(data: data)
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
    
    
    func GetReceipt(token: String, id: String, completion: @escaping (Receipt?) -> Void) {
        let GetReceipt = baseURL.appendingPathComponent("/api/Receipt/" + id)
        let components = URLComponents(url: GetReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(Receipt.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(Receipt.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in getting Receipts")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
                
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    func POSTReceipt (token: String, post: Receipt, completion: @escaping (Receipt?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/Receipt")
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let jsonEcoder = JSONEncoder()
        let jsonData = try? jsonEcoder.encode(post)
        request.httpBody = jsonData
        print(request)
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(Receipt.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(Receipt.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in Post Receipts")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
                
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func PUTReceipt (token: String, put: Receipt, id: String,completion: @escaping (Receipt?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/Receipt/" + id)
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let jsonEcoder = JSONEncoder()
        let jsonData = try? jsonEcoder.encode(put)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(Receipt.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(Receipt.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in Post ReceiptsDOcument")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    
    func DELETEReceipt (token: String, id: String,completion: @escaping (Receipt?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/Receipt/" + id)
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(Receipt.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(Receipt.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in Post ReceiptsDOcument")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }

    func PRINTReceipt (token: String, post: Receipt,count: String, completion: @escaping (String?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/Receipt/PrintLabel/" + String(post.id) + "/" + count)
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            if let data = data{
                let answer = String(data: data, encoding: String.Encoding.utf8)
                completion(answer ?? "Неизвестная ошибка")
            } else {
                completion("Не успех")
            }
        }
        task.resume()
    }
    
    
    
    func GetGoods(token: String, completion: @escaping ([Goods]?) -> Void) {
        let GetReceipt = baseURL.appendingPathComponent("/api/Goods/")
        let components = URLComponents(url: GetReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
                
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    
    func GetGoodsSearch(token: String, search:String, completion: @escaping ([Goods]?) -> Void) {
        let GetReceipt = baseURL.appendingPathComponent("/api/Goods/Search")
        var components = URLComponents(url: GetReceipt, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "start", value: "0"), URLQueryItem(name: "length", value: "100"),URLQueryItem(name: "search", value: search)]
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(GoodsSearch.self, from: data) {
                    completion(list.data)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(GoodsSearch.self, from: data)
                        completion(product.data)
                    } catch let error {
                        print("error in getting Goods")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
                
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    
    func GetGood(token: String, goodId: String, completion: @escaping (Goods?) -> Void) {
        let GetGood = baseURL.appendingPathComponent("/api/Goods/" + goodId)
        let components = URLComponents(url: GetGood, resolvingAgainstBaseURL: true)!
        let GoodURL = components.url!
        var request = URLRequest(url: GoodURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
                
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    
    func postGood(token: String, post: Goods, completion: ((Error?) -> Void)?) {
        
        let GoodPostUrl = baseURL.appendingPathComponent("/api/Goods")
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
    
    
    func GetSizes(token: String, completion: @escaping ([Sizes]?) -> Void) {
        let GetGood = baseURL.appendingPathComponent("/api/Sizes/")
        let components = URLComponents(url: GetGood, resolvingAgainstBaseURL: true)!
        let GoodURL = components.url!
        var request = URLRequest(url: GoodURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode([Sizes].self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode([Sizes].self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in getting Good")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
                
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    
    // Чеки (список чеков)
    func GetCheckList(userId: String, token: String, completion: @escaping ([Check]?) -> Void) {
        let GetGood = baseURL.appendingPathComponent("/api/check/New/" + userId)
        let components = URLComponents(url: GetGood, resolvingAgainstBaseURL: true)!
        let GoodURL = components.url!
        var request = URLRequest(url: GoodURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode([Check].self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode([Check].self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in getting Check")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
                
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    // Чеки (один чек)
    func GetCheck(id: String,  token: String, completion: @escaping (Check?) -> Void) {
        let GetGood = baseURL.appendingPathComponent("/api/check/" + id)
        let components = URLComponents(url: GetGood, resolvingAgainstBaseURL: true)!
        let GoodURL = components.url!
        var request = URLRequest(url: GoodURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(Check.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(Check.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in getting Check")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
                
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    // Создание чека
    func POSTCheck (token: String, post: Check, completion: @escaping (Check?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/check/")
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let jsonEcoder = JSONEncoder()
        let jsonData = try? jsonEcoder.encode(post)
        request.httpBody = jsonData
        print(request)
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(Check.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(Check.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in Post Receipts")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    // Удаление чека
    func DELETECheck (token: String, id: String, completion: @escaping (Check?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/Check/" + id)
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(Check.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(Check.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in Post ReceiptsDOcument")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    // Добавление товара к чеку
    func POSTCheckRecord (token: String, post: CheckRecord, completion: @escaping (CheckRecord?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/CheckRecord/")
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let jsonEcoder = JSONEncoder()
        let jsonData = try? jsonEcoder.encode(post)
        request.httpBody = jsonData
        print(request)
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(CheckRecord.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(CheckRecord.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in Post Receipts")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    // Нахожение товара для добавления к чеку по BarCode
    func GetBarCodeFind(barcode: String, token: String, completion: @escaping (BarCodeFind?) -> Void) {
        let GetGood = baseURL.appendingPathComponent("api/barcode/Find/" + barcode)
        let components = URLComponents(url: GetGood, resolvingAgainstBaseURL: true)!
        let GoodURL = components.url!
        var request = URLRequest(url: GoodURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(BarCodeFind.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(BarCodeFind.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in getting BarCodeFind")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
                
            } else {
                completion(nil)
            }
        }
        task.resume()
    }

    
    
    // Удаление товара из чека
    func DELETECheckRecord (token: String, id: String, completion: @escaping (CheckRecord?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/CheckRecord/" + id)
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(CheckRecord.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(CheckRecord.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in delete CheckRecord")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    
    //Получение последней смены
    func GetLastShift(token: String, completion: @escaping (Shift?) -> Void) {
        let GetGood = baseURL.appendingPathComponent("/api/shift/Last")
        let components = URLComponents(url: GetGood, resolvingAgainstBaseURL: true)!
        let GoodURL = components.url!
        var request = URLRequest(url: GoodURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(Shift.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(Shift.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in getting Check")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
                
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    // Добавление клиента в чек
    func POSTCustomerToCheck (token: String, checkId: String, customerId: String, completion: @escaping (Check?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/check/" + checkId + "/SetCustomer/" + customerId)
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "POST"
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        //let jsonEcoder = JSONEncoder()
        //let jsonData = try? jsonEcoder.encode(post)
        //request.httpBody = jsonData
        print(request)
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(Check.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(Check.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in add Client to check")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    //Получение списка клиентов
    func GetCustomerList(token: String, completion: @escaping ([Customer]?) -> Void) {
        let GetGood = baseURL.appendingPathComponent("/api/Customer")
        let components = URLComponents(url: GetGood, resolvingAgainstBaseURL: true)!
        let GoodURL = components.url!
        var request = URLRequest(url: GoodURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode([Customer].self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode([Customer].self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in getting Check")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
                
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
//Поиск клиентов

    func GetCustomerSearch(token: String, search:String, completion: @escaping ([Customer]?) -> Void) {
        let GetReceipt = baseURL.appendingPathComponent("api/customer/Search")
        var components = URLComponents(url: GetReceipt, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "start", value: "0"), URLQueryItem(name: "length", value: "100"),URLQueryItem(name: "search", value: search)]
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(CustomerSearch.self, from: data) {
                    completion(list.data)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(CustomerSearch.self, from: data)
                        completion(product.data)
                    } catch let error {
                        print("error in getting Customer List")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
                
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    // Создание клиента
    func POSTCustomer (token: String, post: Customer, completion: @escaping (String?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/Customer")
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let jsonEcoder = JSONEncoder()
        let jsonData = try? jsonEcoder.encode(post)
        request.httpBody = jsonData
        print(request)
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            if let data = data{
                let answer = String(data: data, encoding: String.Encoding.utf8)
                print(answer)
                completion(answer ?? "Неизвестная ошибка")
            } else {
                completion("Неизвестная ошибка")
            }
        }
        task.resume()
    }
    
    // Редактирование клиента
    func  PUTCustomer (token: String, post: Customer, completion: @escaping (Customer?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/Customer/" + String(post.id))
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let jsonEcoder = JSONEncoder()
        let jsonData = try? jsonEcoder.encode(post)
        request.httpBody = jsonData
        print(request)
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(Customer.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(Customer.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in Put Customer")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}
