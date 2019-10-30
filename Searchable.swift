//
//  Searchable.swift
//  Djinaro
//
//  Created by azat fatykhov on 07/10/2019.
//  Copyright © 2019 Azat. All rights reserved.
//

import Foundation

protocol Searchable {
    var query: String { get }
}

protocol ModelSearch  {
    associatedtype  ModelItems
    func searchModel(query: String) -> ModelItems?
}

class searchItems <T>: ModelSearch {
    
    typealias ModelItems = T
    
    func searchModel(query: String) -> T? {
        return nil
    }
}
