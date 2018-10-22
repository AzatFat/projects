//
//  Receipt.swift
//  Djinaro
//
//  Created by Azat on 14.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import Foundation

// Список поступлений
struct ListReceipt: Codable {
    
    let ListReceipt: [Receipt]
}



//  Поступление
struct Receipt: Codable {
    var id : Int
    var receipt_Document_Id: Int?
    var goods_Id: Int?
    var sizes_Id: Int?
    var cost: Decimal?
    var count: Int?
    var receiptDocument: ReceiptDocument?
    var goods: Goods?
    var sizes: Sizes?

    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case goods_Id = "Goods_Id"
        case receipt_Document_Id = "Receipt_Document_Id"
        case sizes_Id = "Sizes_Id"
        case cost = "Cost"
        case count = "Count"
        case receiptDocument = "ReceiptDocument"
        case goods = "Goods"
        case sizes = "Sizes"
    }
}

// Документ поступления
struct ReceiptDocument: Codable {
    var id: Int
    var employees_Id: Int?
    var name: String?
    var create_Date: String?
    var receipt_Date: String?
    var the_Date: String?
    var employees: Employees?
    var receiptList: [Receipt]?
    var totalCost: Decimal?
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case employees_Id = "Employees_Id"
        case name = "Name"
        case create_Date = "Create_Date"
        case receipt_Date = "Receipt_Date"
        case the_Date = "The_Date"
        case employees = "Employees"
        case receiptList = "ReceiptList"
        case totalCost = "TotalCost"
    }
    
}

// Товары в поступлении
struct Goods: Codable {
    var id: Int
    var group_Goods_Id: Int?
    var name: String?
    var code: String?
    var description: String?
    var location: String?
    var vendor_Code: String?
    var groupGoods: GroupGoods?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case group_Goods_Id = "Group_Goods_Id"
        case name = "Name"
        case code =  "Code"
        case description = "Description"
        case location = "Location"
        case vendor_Code = "Vendor_Code"
        case groupGoods = "GroupGoods"
    }

}

struct GoodsSearch: Codable {
    var recordsTotal: Int
    var recordsFiltered: Int
    var data: [Goods]
    enum CodingKeys: String, CodingKey {
        case recordsTotal = "recordsTotal"
        case recordsFiltered = "recordsFiltered"
        case data = "data"
    }
}

// Группа товаров
struct GroupGoods: Codable {
    
    var id: Int
    var type_Goods_Id: Int?
    var name: String?
    var code: String?
    var typeGoods: TypeGoods?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case type_Goods_Id = "Type_Goods_Id"
        case name = "Name"
        case code = "Code"
        case typeGoods = "TypeGoods"
        
    }
    
}
// Сотрудники
struct Employees: Codable {
    var id: Int
    var surname: String?
    var name: String?
    var middle_Name: String?
    var birth_Date: String?
    var nickname: String?
    var password: String?
    var role_Id: Int?
    var is_Active: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case surname = "Surname"
        case name = "Name"
        case middle_Name = "Middle_Name"
        case birth_Date = "Birth_Date"
        case nickname = "Nickname"
        case password = "Password"
        case role_Id = "Role_Id"
        case is_Active = "Is_Active"
    }
}


// Размеры
struct Sizes: Codable {
    var id: Int
    var name: String?
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
    }
    
}

// Типы товаров
struct TypeGoods: Codable {
    var id: Int
    var name: String?
    var code: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case code = "Code"
    }
}

struct GroupReceipts {
    var objectGood : Goods!
    var objectRaw : [Receipt]!
    var objectCost : String!
}
