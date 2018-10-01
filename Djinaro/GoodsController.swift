//
//  GoodsController.swift
//  Djinaro
//
//  Created by Azat on 25.09.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import Foundation


class GoodsController {

    let baseURL = URL(string: "http://91.203.195.74/store/api/v1/")!
    
    func fetchListGoods(completion: @escaping ([Good]?) -> Void) {
        let GoodsItemsUrl = baseURL.appendingPathComponent("good")
        var components = URLComponents(url: GoodsItemsUrl, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "limit", value: "1000000"), URLQueryItem(name: "offset", value: "0")]
        let GoodsURL = components.url!
        print(GoodsURL)
        let task = URLSession.shared.dataTask(with: GoodsURL) {(data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode([Good].self, from: data) {
                    completion(list)
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode([Good].self, from: data)
                    } catch let error {
                        print("error in getting fetchListGoods")
                        print(error)
                    }
                }

            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    // http://91.203.195.74/store/api/v1/good?sizes=40,41,42

    
    
    
    func fetchGood(goodsNamesIds: String, type: String, completion: @escaping (GoodsInfo?) -> Void) {
        
        let initialGoodsItemURL = baseURL.appendingPathComponent("good/info")
        var components = URLComponents(url: initialGoodsItemURL, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "code", value: goodsNamesIds.decodeUrl), URLQueryItem(name: "type", value: type)]
        //components.queryItems = [URLQueryItem(name: "goodIds", value: goodsNamesIds)]
        let GoodsURL = components.url!
        print(goodsNamesIds)
        print(type)
        print(GoodsURL)
        let task = URLSession.shared.dataTask(with: GoodsURL) {(data, response, error) in
            if let data = data {
               // print(response)
                do {
                    let jsonDecoder = JSONDecoder()
                    let good = try jsonDecoder.decode(GoodsInfo.self, from: data)
                    completion(good)
                    print(good)
                } catch let error{
                    print(error)
                }
            } else {
                completion(nil)
                
            }
        }
        task.resume()
    }

    
    func fetchSearhGoods(search: String,completion: @escaping ([Good]?) -> Void) {
        
        let GoodsItemsUrl = baseURL.appendingPathComponent("good")
        var components = URLComponents(url: GoodsItemsUrl, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "limit", value: "100000000"), URLQueryItem(name: "offset", value: "0"),URLQueryItem(name: "search", value: search)]
        let GoodsURL = components.url!
        
        let task = URLSession.shared.dataTask(with: GoodsURL) {(data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode([Good].self, from: data) {
                    completion(list)
                    
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode([Good].self, from: data)
                        
                    } catch let error {
                        print("error in getting fetchListGoods")
                        print(error)
                        print(response)
                    }
                }
                
            } else {
                completion(nil)
            }
        }
        task.resume()
    }

    
    func fetchSearchGoodsBySize(search: String,completion: @escaping ([Good]?) -> Void) {
        
        let GoodsItemsUrl = baseURL.appendingPathComponent("good")
        var components = URLComponents(url: GoodsItemsUrl, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "sizes", value: search)]
        
        let GoodsURL = components.url!
        print(GoodsURL)
        let task = URLSession.shared.dataTask(with: GoodsURL) {(data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data{
                if let list = try? jsonDecoder.decode([Good].self, from: data) {
                    completion(list)
                    
                } else {
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode([Good].self, from: data)
                        
                    } catch let error {
                        print("error in getting fetchListGoods")
                        print(error)
                        print(response)
                    }
                }
                
            } else {
                completion(nil)
            }
        }
        task.resume()
    }

    
    
    
}


extension String{
    var encodeUrl : String
    {
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    }
    var decodeUrl : String
    {
        return self.removingPercentEncoding!
    }
}
