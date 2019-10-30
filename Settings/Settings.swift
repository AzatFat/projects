//
//  Settings.swift
//  Djinaro
//
//  Created by Azat on 28.03.2019.
//  Copyright © 2019 Azat. All rights reserved.
//

import Foundation



class Settings {
    let sharedInstance = Settings()
    static var inURL = "http://192.168.88.190"
    static var outURL = "http://87.117.180.87:7000"
    static var base = outURL
    
    /**
    `BaseURL use by Reports`
     # Need to delete after refactoring whole network.
     */
    
    
    static var baseURL = URL(string: inURL)
    static var token : String  {
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        return defaults?.value(forKey:"token") as? String ?? ""
        
    }
}




class UserSettings {
    
    let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
    
    init() {
        if let url = defaults?.value(forKey:"baseUrl") as? String {
            Settings.baseURL = URL(string: url)!
        }
    }
}


/*
class UserSettings: Settings {
    let userInstanse = UserSettings(user: userPassword, password: <#String#>)
    let userPassword = ""
    let userLogin = ""
    var baseURL = URL(string: "")!
    var token : Token
    
    init (user: String, password: String) {
        POSTToken(username: user, password: password) { (token) in
            if let token = token {
                self.token = token
            }
        }
    }
    
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
    
}
*/

