//
//  GroupGoods.swift
//  Djinaro
//
//  Created by azat fatykhov on 30/10/2019.
//  Copyright © 2019 Azat. All rights reserved.
//

import Foundation

// Группа товаров
struct GroupGoods: Codable {
    
    var id: Int
    var type_Goods_Id: Int?
    var name: String?
    var code: String?
 //   var typeGoods: TypeGoods?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case type_Goods_Id = "Type_Goods_Id"
        case name = "Name"
        case code = "Code"
 //       case typeGoods = "TypeGoods"
        
    }
    
}
