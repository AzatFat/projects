//
//  ApiResource.swift
//  Djinaro
//
//  Created by azat fatykhov on 07/10/2019.
//  Copyright © 2019 Azat. All rights reserved.
//


import Foundation

enum dataDecoderFaluries: Error {
    case decodeFail(messsage: String)
}


protocol ApiResource {
    associatedtype Model: Decodable
    var methodPath: String {get}
    var httpMethod: HTTPMethod {get}
    var urlRequest: URLRequest {get}
    func optionalRequestConfiguration(request: URLRequest) -> URLRequest
    func makeModel(data: Data) throws -> Model?
}

extension ApiResource {
    var url : URL {
        let baseURL = Settings.base
        let url = baseURL + methodPath
        return URL(string: url)!
    }
    
    func defaultRequestConfiguration() -> URLRequest {
        var request  = URLRequest(url: url)
        request.httpMethod = httpMethod.description
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Settings.token)", forHTTPHeaderField: "Authorization")
        return optionalRequestConfiguration(request: request)
    }
    
    func optionalRequestConfiguration(request: URLRequest) -> URLRequest {
        return request
    }
    
    var urlRequest: URLRequest {
        return defaultRequestConfiguration()
    }
    
    func makeModel(data: Data) throws  -> Model? {
        let decoder = JSONDecoder()
        guard let model = try? decoder.decode(Model.self, from: data) else{
            do {
                _ = try decoder.decode(Goods.self, from: data)
            } catch let error {
                //print(error)
                //print(String(data: data, encoding: String.Encoding.utf8))
            }
            throw dataDecoderFaluries.decodeFail(messsage: "decoding data from API resource with \(methodPath) is failed ")
        }
        return model
    }
    
    /**
    # 'Use this function for change base API if one of requests retrurn - "access denied"'
    */
    func changeBaseURL () {
        Settings.base =  Settings.base == Settings.outURL ? Settings.inURL : Settings.outURL
    }
    
}

struct GoodInformation: ApiResource {
    typealias Model = Goods
    var methodPath = "/api/Goods/"
    var httpMethod = HTTPMethod.GET
    init(goodId: Int) {
        self.methodPath += "\(goodId)"
    }
}


/*
struct RepositoryResource: ApiResource {
    
    typealias Model = Repositories
    var methodPath = "/search/repositories"
    
    init(searchQuery: String) {
        self.methodPath += "?q=\(searchQuery)"
    }
}
*/
