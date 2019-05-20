//
//  userReports.swift
//  Djinaro
//
//  Created by Azat on 26.03.2019.
//  Copyright © 2019 Azat. All rights reserved.
//

import Foundation
import UIKit
// Отчет для админов

struct mainReport: Codable {
    var records: [mainResults]
    enum CodingKeys: String, CodingKey {
        case records = "records"
    }
}


struct mainResults: Codable {
    var check_type_id: Int?
    var type_goods_id: Int?
    var name : String?
    var tg_nm : String?
    var g_nm : String?
    var cnt_c : Int?
    var sum_c : Decimal?
    
    
    enum CodingKeys: String, CodingKey {
        case check_type_id = "check_type_id"
        case type_goods_id = "type_goods_id"
        case tg_nm = "tg_nm"
        case g_nm = "g_nm"
        case name = "name"
        case cnt_c = "cnt_c"
        case sum_c = "sum_c"
    }
}


struct datesForMainResult: Codable {
    var date_from: String
    var date_to: String
    var employees_id: Int?
    var check_type_id: Int?
    var type_goods_id: Int?
    enum CodingKeys: String, CodingKey {
        case date_from = "date_from"
        case date_to = "date_to"
        case employees_id = "employees_id"
        case check_type_id = "check_type_id"
        case type_goods_id = "type_goods_id"
    }
}

struct reportDescription: Codable {
    var id: Int?
    var name: String?
    var description: String?
    var code: String?
    var isTimeInterval: Bool?
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case description = "description"
        case code = "code"
        case isTimeInterval = "isTimeInterval"
    }
}

struct reportContent: Codable {
  //  var records: [String: Any]?
    var current_level: Int?
    var params_to_next_level: [String?]
    enum CodingKeys: String, CodingKey {
    //    case records = "records"
        case current_level = "current_level"
        case params_to_next_level = "params_to_next_level"
    }
}

class Reports: UserSettings {
    
    var report = reportDescription()
    var baseURL = URL(string: "http://87.117.180.87:7000")!
    var currentLevel = 0
    var paramsToNextLevel = [String: String]()
    var levelParams = [[String]]()
    var content = [[String: Any]]()
    var viewedContent = [[String: Any]]()

    
    func reportContent(code: String, completion: @escaping ([String: Any]?) -> Void ) {
        
        let PostReceipt = baseURL.appendingPathComponent("/api/report/" + "\(code)")
        let components = URLComponents(url: PostReceipt, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        print("URL IS \(ReceiptURL)")
        
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Settings.token)", forHTTPHeaderField: "Authorization")
        if self.paramsToNextLevel.count > 0 {
            print("paparms: \(self.paramsToNextLevel)")
            let jsonEcoder = JSONEncoder()
            let jsonData = try? jsonEcoder.encode(self.paramsToNextLevel)
            request.httpBody = jsonData
        }
        
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            if let data = data{
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    guard let idk = json as? [String: Any] else {return}
                    
                    self.currentLevel = idk["current_level"] as? Int ?? 0
                    
                    if let paramsToNextLevel = idk["params_to_next_level"] as? [String]  {
                        
                        for params in paramsToNextLevel {
                            self.paramsToNextLevel[params] = ""
                        }
                        self.levelParams.append(paramsToNextLevel)
                    }
                    
                    if let nestedDictionary = idk["records"] as? [[String: Any]] {
                            self.content = nestedDictionary
                    }
                    
                    self.getViewedContent()
                    
                    completion(idk)
                } catch let error {
                    print("error in getting reportContent")
                    print(error)
                    completion(nil)
                }
            } else {
               // print(error, response)
                completion(nil)
            }
        }
        task.resume()
        
    }
    
    func reportsList( completion: @escaping ([reportDescription]?) -> Void ) {
        let reportsListURL = baseURL.appendingPathComponent("/api/report/")
        let components = URLComponents(url: reportsListURL, resolvingAgainstBaseURL: true)!
        let ReceiptURL = components.url!
        var request = URLRequest(url: ReceiptURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Settings.token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data{
                do {
                    let decoder = JSONDecoder()
                    let report = try decoder.decode([reportDescription].self, from: data)
                    completion(report)
                } catch let error {
                    print("error in getting reportDescription")
                    print(error)
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func getDefaultDaysForReport(with report: reportDescription) {
        if let isTimeInterval = report.isTimeInterval, isTimeInterval == true {
            let dateEnd = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            if let dateStart = Calendar.current.date(byAdding: .day, value: -7, to: Date()) {
                let dateStartText = formatter.string(from: dateStart)
                self.paramsToNextLevel["date_from"] = dateStartText
            }
            let dateEndText = formatter.string(from: dateEnd)
            self.paramsToNextLevel["date_to"] = dateEndText
            self.paramsToNextLevel["date_from"] = dateEndText
        }
    }
    
    func goToPreviousLevel() {
        print("current \(self.currentLevel)")
        if self.currentLevel > 1 {
            print("levelParams: \(levelParams)")
            for i in self.levelParams[currentLevel - 2] {
                if i != "date_from" && i != "date_to" {
                    self.paramsToNextLevel.removeValue(forKey: i)
                }
            }
        } else  {
            for i in self.paramsToNextLevel {
                if i.value != "date_from" && i.value != "date_to" {
                    self.paramsToNextLevel.removeValue(forKey: i.value)
                }
            }
            self.currentLevel = 0
        }
    }
    
    func getViewedContent() {
        viewedContent = content
        for key in paramsToNextLevel.keys {
            for i in viewedContent.indices {
                viewedContent[i].removeValue(forKey: key)
            }
        }
    }
}

