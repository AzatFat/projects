//
//  NetworkRequest.swift
//  Djinaro
//
//  Created by azat fatykhov on 07/10/2019.
//  Copyright © 2019 Azat. All rights reserved.
//

import Foundation
import UIKit

enum HTTPMethod {
    case GET
    case PUT
    case PATCH
    case POST
    
    var description: String {
        switch self {
        case .GET:
            return "GET"
        case .PUT:
            return "PUT"
        case .PATCH:
            return "PATCH"
        case .POST:
            return "POST"
        }
    }
}


protocol NetworkRequest: class {
    associatedtype Model
    func load (withCompletion completion: @escaping (Model?) -> Void)
    func decode(_ data: Data) -> Model?
}

extension NetworkRequest {
    fileprivate func load(_ urlRequest: URLRequest , withCompletion completion: @escaping (Model?) -> Void) {
        //print("url request is \(urlRequest) \n \(urlRequest.allHTTPHeaderFields) \n \(urlRequest.value(forHTTPHeaderField: "Authorization"))")
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: urlRequest) {[weak self] (data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let data = data else {
                completion(nil)
                return
            }
            
            let model = self?.decode(data)
            completion(model)
        }
        task.resume()
    }
}

/*
class ImageRequest {
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
}

extension ImageRequest: NetworkRequest {
    
    func decode(_ data: Data) -> UIImage? {
        return UIImage(data: data)
    }
    
    func load(withCompletion completion: @escaping (UIImage?) -> Void) {
        load(url, withCompletion: completion)
    }
}
*/

class ApiRequest<Resource: ApiResource> {
    let resource : Resource

    init(resource: Resource) {
        self.resource = resource
    }
    
}

extension ApiRequest: NetworkRequest {

    func decode(_ data: Data) -> Resource.Model? {
        do {
            let model = try resource.makeModel(data: data)
            return model
        } catch  dataDecoderFaluries.decodeFail(let message){
            assertionFailure(message)
            return nil
        } catch {
            return nil
        }
    }
    
    func load(withCompletion completion: @escaping (Resource.Model?) -> Void) {
        load(resource.urlRequest, withCompletion: completion)
    }
}
