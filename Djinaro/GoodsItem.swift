//
//  GoodsItem.swift
//  Djinaro
//
//  Created by Azat on 25.09.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import Foundation

struct Good: Codable {
    
    var id: String
    var name: String
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
    }
}

struct ListGoods: Codable {
    
    let listGoods: [Good]
}


struct GoodsInfo: Codable {
    var name: String
    var location: String
    var image: String
    var available_sizes: [avaliableSizes]
    
    enum CodingKeys: String, CodingKey {
        case name
        case location
        case image
        case available_sizes
    }
    

    
}
struct avaliableSizes: Codable {
    
    var size: String?
    var cost: String?
    var count: String?
    
    enum CodingKeys: String, CodingKey {
        
        case size
        case cost
        case count
    }

}

