//
//  ReceiptController.swift
//  Djinaro
//
//  Created by Azat on 14.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import Foundation
import UIKit




class ReceiptController {
   // var baseURL = URL(string: "http://91.203.195.74:5001")!
    var baseURL = URL(string: "http://192.168.88.190")!
    let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
    var token : String?
    var tokenType : String?
    
    init () {
        if let udrl = defaults?.value(forKey:"baseUrl") as? String {
            self.baseURL = URL(string: udrl)!
        }
    }
    
    init(useMultiUrl: Bool) {
        if useMultiUrl == true {
            if let udrl = defaults?.value(forKey:"baseUrl") as? String {
                self.baseURL = URL(string: udrl)!
            }
        }
    }
    
    
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
        print("token request is \(request)")
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
               // let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
               // let newViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
               // self.present(newViewController, animated: true, completion: nil)
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
                    } catch _ {
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
    // Проведение документа поступления
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
    // Изменение документа поступления
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
    
    // Получение документа поступления
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
    //Удаление документа поступления
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
    
    // Печать документа поступления
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
    // Печать модели поступления
    func PRINTAllGoodReceiptsInDocument (token: String,receiptDocumentId: String, goodId: String, completion: @escaping (String?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/Receipt/PrintLabelModel/" + receiptDocumentId + "/" + goodId)
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
    
    // Получение списка поступлений
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

    
    // Печать поступления
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
    
    
    // ПОиск товаров
    func GetGoods(token: String, completion: @escaping ([Goods]?) -> Void) {
        let GetReceipt = baseURL.appendingPathComponent("/api/Goods/")
        let components = URLComponents(url: GetReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("token request is \(request)")
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
    
    
    // Поиск товара через QR код
    func POSTSearchGoods (token: String, post: InventoryCode, completion: @escaping (Goods?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/goods/scaner/")
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
                if let list = try? jsonDecoder.decode(Goods.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(Goods.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in Post searchGoods by QR")
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
    
    // поиск списка товаров
    func GetGoodsSearch(token: String, search:String, sizes: String, is_remains: String, is_archive: String, completion: @escaping ([Goods]?) -> Void) {
        let GetReceipt = baseURL.appendingPathComponent("/api/Goods/Search")
        var components = URLComponents(url: GetReceipt, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "start", value: "0"), URLQueryItem(name: "length", value: "1000")]
        if sizes != "" {
            components.queryItems?.append(URLQueryItem(name: "sizes", value: sizes))
        } else if search != "" {
            components.queryItems?.append(URLQueryItem(name: "search", value:  search))
        }
        
        if is_remains != "" {
            components.queryItems?.append(URLQueryItem(name: "is_remains", value: is_remains))
        }
        
        if is_archive != "" {
            components.queryItems?.append(URLQueryItem(name: "is_archive", value: is_archive))
        }
        
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print(request)
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
    //ПОлучение одного товара
    
    func GetGood(token: String, goodId: String, completion: @escaping (Goods?) -> Void) {
        let GetGood = baseURL.appendingPathComponent("/api/Goods/" + goodId)
        let components = URLComponents(url: GetGood, resolvingAgainstBaseURL: true)!
        let GoodURL = components.url!
        var request = URLRequest(url: GoodURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print(request)
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
    
// изменение товара
    func PUTGood (token: String, post: Goods, completion: @escaping (Goods?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/Goods/" + String(post.id))
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
                if let list = try? jsonDecoder.decode(Goods.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(Goods.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in PUT Goods")
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
    //Запрос требуемого размера
    func POSTRequiredSize (token: String, goodId: String, sizeId: String , completion: @escaping (String?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/Goods/NoSize/" + goodId + "/" + sizeId)
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        // let jsonEcoder = JSONEncoder()
        // let jsonData = try? jsonEcoder.encode(post)
        // request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
                    print("responsee 200")
                    completion("Запрос принят")
                } else {
                    completion("Произошла ошибка")
                }
            }
        }
        task.resume()
    }
    
    
    
    //Печать этикетки товара
    func POSTGoodPrintLable (token: String, goodId: String, sizeId: String , completion: @escaping (String?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/Goods/PrintLabel/" + goodId + "/" + sizeId)
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
       // let jsonEcoder = JSONEncoder()
       // let jsonData = try? jsonEcoder.encode(post)
       // request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            if let data = data{
                let answer = String(data: data, encoding: String.Encoding.utf8)
                completion(answer ?? "Неизвестная ошибка")
            } else {
                completion("Неизвестная ошибка")
            }
        }
        task.resume()
    }
    
    //
    func POSTGoodPrintShopLabel (token: String, goodId: String, completion: @escaping (String?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("api/goods/PrintLabelShop/" + goodId)
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        print(request)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        // let jsonEcoder = JSONEncoder()
        // let jsonData = try? jsonEcoder.encode(post)
        // request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            if let data = data{
                let answer = String(data: data, encoding: String.Encoding.utf8)
                completion(answer ?? "Неизвестная ошибка")
            } else {
                completion("Неизвестная ошибка")
            }
        }
        task.resume()
    }
    
    // создание товара
    func POSTGood (token: String, post: Goods, completion: @escaping (Goods?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/Goods")
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
                if let list = try? jsonDecoder.decode(Goods.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(Goods.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in Post Goods")
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
    
    // Прикрепление изображения к товару
    func POSTGoodImageAsData (token: String, image: UIImage, good: Goods, completion: @escaping (goodsImages?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/GoodImage/Create/" + String(good.id))
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "POST"
        let boundary = generateBoundaryString()
        
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let image_data = image.pngData()
        
        let body = NSMutableData()
        let fname = "image.png"
        let mimetype = "image/png"
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"image\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("hi\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"image\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(image_data!)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        request.httpBody = body as Data

        print(request)
        print("data send image")
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(goodsImages.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(goodsImages.self, from: data)
                        completion(product)
                    } catch _ {
                        print("error in Post goodsImages")
                        //print(error)
                        //print(response)
                        //print(String(data: data, encoding: String.Encoding.utf8))
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
    
    func generateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().uuidString)"
    }
    // Сделать изображение главным
    func MakeGoodsImageMain (token: String, imageId: String , completion: @escaping (String?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/GoodImage/Main/" + imageId)
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print(request)
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
                    print("responsee 200")
                    completion("Товар изменен")
                }
            }
            
            if let data = data{
                let answer = String(data: data, encoding: String.Encoding.utf8)
                //print(answer)
                completion(answer ?? "Неизвестная ошибка")
            } else {
                completion("Неизвестная ошибка")
            }
        }
        task.resume()
    }
    
    
    // Получение изображения товара
    func getGoodImage(url: String, completion: @escaping (UIImage?) -> Void) {
        let GetImageGood = baseURL.appendingPathComponent(url)
        let components = URLComponents(url: GetImageGood, resolvingAgainstBaseURL: true)!
        let GoodURL = components.url!
        let request = URLRequest(url: GoodURL)
        print("request is \(request)")
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                print("success image get")
                completion(image)
                
            } else {
                print("success image error")
               // print(response)
               // print(error)
                completion(nil)
            }
        }
        task.resume()
    }
    // Удаление изображения
    func DELETEGoodsImage (token: String, imageId: String , completion: @escaping (String?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/GoodImage/" + imageId)
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print(request)
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
                    print("responsee 200")
                    completion("Товар удален")
                }
            }
            
            if let data = data{
                let answer = String(data: data, encoding: String.Encoding.utf8)
               // print(answer)
                completion(answer ?? "Неизвестная ошибка")
            } else {
                completion("Неизвестная ошибка")
            }
        }
        task.resume()
    }
    
    
    // Получение размеров
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
    
    // Размеры по типу
    func GetSizesByType(token: String, type: String ,completion: @escaping ([Sizes]?) -> Void) {
        let GetGood = baseURL.appendingPathComponent("/api/Sizes/Type/" + type)
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
    
    //Получение типов товара
    func GETTypeGoods(token: String, completion: @escaping ([TypeGoods]?) -> Void) {
        let GetGood = baseURL.appendingPathComponent("/api/TypeGoods/")
        let components = URLComponents(url: GetGood, resolvingAgainstBaseURL: true)!
        let GoodURL = components.url!
        var request = URLRequest(url: GoodURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print(request)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode([TypeGoods].self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode([TypeGoods].self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in getting typeGood")
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
    // Получение группы товаров
    func GETGroupGoods(token: String, completion: @escaping ([GroupGoods]?) -> Void) {
        let GetGood = baseURL.appendingPathComponent("/api/GroupGoods")
        let components = URLComponents(url: GetGood, resolvingAgainstBaseURL: true)!
        let GoodURL = components.url!
        var request = URLRequest(url: GoodURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print(request)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode([GroupGoods].self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode([GroupGoods].self, from: data)
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
               // print(answer)
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
    // Складская инвентаризация
    // Инвентаризация добавление товара к общему количеству
    func POSTInventoryCode (token: String, code: String, post: InventoryCode, completion: @escaping (scannedGoodsInStockinventory?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/Inventory/Enter/")
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
                
                let jsonDecoder = JSONDecoder()
                if let list = try? jsonDecoder.decode(scannedGoodsInStockinventory.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(scannedGoodsInStockinventory.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in getting scannedGoodStockInventory List")
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
    //finish
    func POSTFinish (token: String,completion: @escaping (String?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("api/Inventory/finish/")
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print(request)
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
                    print("responsee 200")
                    completion("Поступление создано")
                } else {
                    completion("Произошла ошибка")
                }
            }
            else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    
    // Изменение количества товара
    func PUTScannedGoodInStock (token: String, put: scannedGoodsInStockinventory, id: String, completion: @escaping (String?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("api/Inventory/" + id)
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
           // let jsonDecoder = JSONDecoder()
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
                    print("responsee 200")
                    completion("Данные по инвентаризации удалены")
                } else {
                    completion("Произошла ошибка")
                }
            }
             else {
                completion(nil)
            }
        }
        task.resume()
    }
    func GetScannedGoodInStock(id: String, token: String, completion: @escaping (scannedGoodsInStockinventory?) -> Void) {
        let GetReceipt = baseURL.appendingPathComponent("api/Inventory/" + id)
        let components = URLComponents(url: GetReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print(request)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(scannedGoodsInStockinventory.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(scannedGoodsInStockinventory.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in getting StockInventoryGoods List")
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
    
    
    //  Получение списка моделей на складе
    func GetStockInventoryGoods(typeGood: String, token: String, is_all: Bool, userId: String, completion: @escaping (stockInventoryView?) -> Void) {
        let GetReceipt = baseURL.appendingPathComponent("/api/Inventory/View/" + typeGood)
        var components = URLComponents(url: GetReceipt, resolvingAgainstBaseURL: true)!
        
        if is_all == true {
            components.queryItems = [URLQueryItem(name: "start", value: "0"), URLQueryItem(name: "length", value: "1000"), URLQueryItem(name: "is_all", value: "true")]
        } else {
            components.queryItems = [URLQueryItem(name: "start", value: "0"), URLQueryItem(name: "length", value: "1000")]
        }
        if userId != "" {
            components.queryItems?.append(URLQueryItem(name: "user_id", value: userId))
        }
        
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print(request)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(stockInventoryView.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(stockInventoryView.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in getting StockInventoryGoods List")
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
    // отсканированные товары пользователем
    func GetStockInventoryGoodsByUser(typeGood: String, token: String, userId: String, is_all: Bool,completion: @escaping (stockInventoryView?) -> Void) {
        let GetReceipt = baseURL.appendingPathComponent("/api/Inventory/View/" + typeGood)
        var components = URLComponents(url: GetReceipt, resolvingAgainstBaseURL: true)!
        if is_all == true {
            components.queryItems = [URLQueryItem(name: "start", value: "0"), URLQueryItem(name: "length", value: "1000"), URLQueryItem(name: "user_id", value: userId), URLQueryItem(name: "is_all", value: "true")]
        } else {
            components.queryItems = [URLQueryItem(name: "start", value: "0"), URLQueryItem(name: "length", value: "1000"), URLQueryItem(name: "user_id", value: userId)]
        }
        
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print(request)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(stockInventoryView.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(stockInventoryView.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in getting StockInventoryGoods List")
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
    
    // Очистка результата
    func POSTClearStockInventoryResults (token: String, completion: @escaping (String?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("api/Inventory/clear")
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        // let jsonEcoder = JSONEncoder()
        // let jsonData = try? jsonEcoder.encode(post)
        // request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
                    print("responsee 200")
                    completion("Данные по инвентаризации удалены")
                } else {
                    completion("Произошла ошибка")
                }
            }
        }
        task.resume()
    }
    
    // Загрузка данных по типу товара
    func POSTLoadStockInventoryResults (token: String, typeId: String, completion: @escaping (String?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("api/Inventory/load/" + typeId)
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        // let jsonEcoder = JSONEncoder()
        // let jsonData = try? jsonEcoder.encode(post)
        // request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
                    print("responsee 200")
                    completion("Данные загружены")
                } else {
                    completion("Произошла ошибка")
                }
            }
        }
        task.resume()
    }
    
    /// Удаление сканирования по товарам
    func POSTDeleteGoodModelFromScan (token: String, goodId: String, completion: @escaping (String?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/Inventory/CleanOut/" + goodId)
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        // let jsonEcoder = JSONEncoder()
        // let jsonData = try? jsonEcoder.encode(post)
        // request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
                    print("responsee 200")
                    completion("Сканирования по модели удалены")
                } else {
                    completion("Произошла ошибка")
                }
            }
        }
        task.resume()
    }
    
    /// Изменение true на false
    func POSTApproveInventory (token: String, inventoryId: String, completion: @escaping (String?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("/api/Inventory/Approve/" + inventoryId)
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        // let jsonEcoder = JSONEncoder()
        // let jsonData = try? jsonEcoder.encode(post)
        // request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
                    print("responsee 200")
                    completion("Подтверждено")
                } else {
                    completion("Произошла ошибка")
                }
            }
        }
        task.resume()
    }
    
    /// Получение отчета по итогу складской ивентаризации
    func GetResultInventoryStock(token: String, completion: @escaping (stockInventoryResult?) -> Void) {
        let GetReceipt = baseURL.appendingPathComponent("/api/Inventory/Res/")
        let components = URLComponents(url: GetReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print(request)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(stockInventoryResult.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(stockInventoryResult.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in getting StockInventoryGoods List")
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
    
    // Витринная инвентаризация
    // список просканированных товаров
    func GetFrontInventoryGoods(url: String, token: String, completion: @escaping (InventoryFrontShopList?) -> Void) {
        let GetReceipt = baseURL.appendingPathComponent("/api/\(url)/View")
        let components = URLComponents(url: GetReceipt, resolvingAgainstBaseURL: true)!
//        components.queryItems = [URLQueryItem(name: "start", value: "0"), URLQueryItem(name: "length", value: "100"),URLQueryItem(name: "search", value: search)]
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print(request)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(InventoryFrontShopList.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(InventoryFrontShopList.self, from: data)
                        completion(product)
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
    // Скан товара витринной инвентаризации

    func POSTInventoryEnter (url: String, token: String, code: String, post: InventoryCode, completion: @escaping (ResponseScannedGood?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("api/\(url)/Enter")
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
                let jsonDecoder = JSONDecoder()
                if let list = try? jsonDecoder.decode(ResponseScannedGood.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(ResponseScannedGood.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in getting ResponseScannedGood")
                        print(error)
                        self.denyAuthorisation(data: data)
                        completion(nil)
                    }
                }
                
                // let answer = String(data: data, encoding: String.Encoding.utf8)
                // completion(answer ?? "Неизвестная ошибка")
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    // Проверка записи
    func GetInventoryFrontShopRow(token: String, rawId: String, completion: @escaping (InventoryFrontShopRow?) -> Void) {
        let GetReceipt = baseURL.appendingPathComponent("/api/InventoryFrontShop/" + rawId)
        let components = URLComponents(url: GetReceipt, resolvingAgainstBaseURL: true)!
        //        components.queryItems = [URLQueryItem(name: "start", value: "0"), URLQueryItem(name: "length", value: "100"),URLQueryItem(name: "search", value: search)]
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(InventoryFrontShopRow.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(InventoryFrontShopRow.self, from: data)
                        completion(product)
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
    
    
    // Достижения продавцов
    func GetReportPersonal(token: String, completion: @escaping ([userListAchivements]?) -> Void) {
        let GetReceipt = baseURL.appendingPathComponent("/api/report/Personal")
        let components = URLComponents(url: GetReceipt, resolvingAgainstBaseURL: true)!
        //        components.queryItems = [URLQueryItem(name: "start", value: "0"), URLQueryItem(name: "length", value: "100"),URLQueryItem(name: "search", value: search)]
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode([userListAchivements].self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode([userListAchivements].self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in getting [userListAchivements] List")
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
    
    // Оставшееся время
    
    func GETtimeRemaning(token: String, completion: @escaping (timeRemaning?) -> Void) {
        let GetReceipt = baseURL.appendingPathComponent("/api/report/time_remaining")
        let components = URLComponents(url: GetReceipt, resolvingAgainstBaseURL: true)!
        //        components.queryItems = [URLQueryItem(name: "start", value: "0"), URLQueryItem(name: "length", value: "100"),URLQueryItem(name: "search", value: search)]
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(timeRemaning.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(timeRemaning.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in getting [userListAchivements] List")
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
    
    
    func POSTMainReport (token: String,  post: datesForMainResult, completion: @escaping (mainReport?) -> Void) {
        let PostReceipt = baseURL.appendingPathComponent("api/report/main_results")
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print(request)
        let jsonEcoder = JSONEncoder()
        let jsonData = try? jsonEcoder.encode(post)
        request.httpBody = jsonData
        print(request)
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode(mainReport.self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(mainReport.self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in get mainREsults to check")
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
    
    
    // Получение отчета по продажам
    func GETdaySales(token: String, completion: @escaping ([salesDay]?) -> Void) {
        let GetReceipt = baseURL.appendingPathComponent("/api/report/Sales")
        let components = URLComponents(url: GetReceipt, resolvingAgainstBaseURL: true)!
        //        components.queryItems = [URLQueryItem(name: "start", value: "0"), URLQueryItem(name: "length", value: "100"),URLQueryItem(name: "search", value: search)]
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode([salesDay].self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode([salesDay].self, from: data)
                        completion(product)
                    } catch let error {
                        print("error in getting day sales report")
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


