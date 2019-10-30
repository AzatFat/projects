//
//  Receipt.swift
//  Djinaro
//
//  Created by Azat on 14.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import Foundation

/// Access token
struct Token: Codable {
    var access_token : String
    var user_id: String
    var token_type: String
    var expires_in: Int?
    var userName: String
    var issued: String?
    var expires: String?
    var is_Admin: String?
    
    enum CodingKeys: String, CodingKey {
        case access_token = "access_token"
        case user_id = "Id" 
        case token_type = "token_type"
        case expires_in = "expires_in"
        case userName = "userName"
        case issued = ".issued"
        case expires = ".expires"
        case is_Admin = "Is_Admin"
    }
}

struct DenyInAuthorisation: Codable {
    var Message : String?
    enum CodingKeys: String, CodingKey {
        case Message = "Message"
    }
}


//User Info

struct UserInfo: Codable {
    var Email : String?
    var HasRegistered: Bool?
    var LoginProvider: String?
    var Is_Admin: Bool?
    enum CodingKeys: String, CodingKey {
        case Email = "Email"
        case HasRegistered = "HasRegistered"
        case LoginProvider = "LoginProvider"
        case Is_Admin = "Is_Admin"
    }
}

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


struct Available_sizes: Codable {
    var sizes: Sizes?
    var count: Int?
    var cost: Decimal?
    
    enum CodingKeys: String, CodingKey {
        case sizes = "Sizes"
        case count = "Count"
        case cost = "Cost"
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

// Чеки
struct Check: Codable {
    var id: Int
    var customer_Id: Int?
    var employees_Id: Int?
    var shift_Id: Int?
    var check_Type_Id: Int?
    var payment_Type_Id: Int?
    var cash: Decimal?
    var card: Decimal?
    var is_Deferred: Bool?
    var is_Cancelled: Bool?
    var create_Date: String?
    var the_Date: String?
    var customer: Customer?
    var checkType: CheckType?
    var employees: Employees?
    var shift: Shift?
    var checkRecordList: [CheckRecord]?
    var payment: Payment?
    var totalCost: Decimal?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case customer_Id = "Customer_Id"
        case employees_Id = "Employees_Id"
        case shift_Id = "Shift_Id"
        case check_Type_Id = "Check_Type_Id"
        case payment_Type_Id = "Payment_Type_Id"
        case cash = "Cash"
        case card = "Card"
        case is_Deferred = "Is_Deferred"
        case is_Cancelled = "Is_Cancelled"
        case create_Date = "Create_Date"
        case the_Date = "The_Date"
        case customer = "Customer"
        case checkType = "CheckType"
        case employees = "Employees"
        case shift = "Shift"
        case checkRecordList = "CheckRecordList"
        case payment = "Payment"
        case totalCost = "TotalCost"
    }
}
///Печать чеков
struct CheckPrint: Codable {
    var id : Int
    var cash : Decimal?
    var card: Decimal?
    var printer: Int?
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case cash = "cash"
        case card = "card"
        case printer = "printer"
    }
}

/// Клиент
struct Customer: Codable {
    var id: Int
    var surname: String?
    var name: String?
    var middle_Name: String?
    var birth_Date: String?
    var phone: String?
    var email: String?
    var vK_Link: String?
    var iNSTA_Link: String?
    var is_Archive: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case surname = "Surname"
        case name = "Name"
        case middle_Name = "Middle_Name"
        case birth_Date = "Birth_Date"
        case phone = "Phone"
        case email = "Email"
        case vK_Link = "VK_Link"
        case iNSTA_Link = "INSTA_Link"
        case is_Archive = "Is_Archive"
    }
}
// Лист поиска клиентов
struct CustomerSearch: Codable {
    var recordsTotal: Int
    var recordsFiltered: Int
    var data: [Customer]
    enum CodingKeys: String, CodingKey {
        case recordsTotal = "recordsTotal"
        case recordsFiltered = "recordsFiltered"
        case data = "data"
    }
}
// ИЗображения клиентов
struct  customerImages: Codable {
    var id: Int
    var name: String?
    var customerId: Int?
    var base64: String?
    var is_Main: Bool?
    var url: imageURLpath?
    
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case customerId = "Customer_Id"
        case base64 = "Base64"
        case url = "Url"
        case is_Main = "Is_Main"
    }
}


/// Тип чека
struct CheckType: Codable {
    var id: Int
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
    }
}

// Смена
struct Shift: Codable {
    var id: Int
    var employees_Id: Int?
    var open_Date: String?
    var close_Date: String?
    var employees: Employees?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case employees_Id = "Employees_Id"
        case open_Date = "Open_Date"
        case close_Date = "Close_Date"
        case employees = "Employees"
    }
}


// Товар в чеке
struct CheckRecord: Codable {
    var id: Int
    var check_Id: Int?
    var goods_Id: Int?
    var sizes_Id: Int?
    var employees_Id: Int?
    var customer_Id: Int?
    var count: Int?
    var cost: Decimal?
    var discount: Decimal?
    var total_Cost: Decimal?
    var stockRemainsCount: Int?
    var check: Check?
    var goods: Goods?
    var sizes: Sizes?
    var employees: Employees?
    var customer: Customer?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case check_Id = "Check_Id"
        case goods_Id = "Goods_Id"
        case sizes_Id = "Sizes_Id"
        case employees_Id = "Employees_Id"
        case customer_Id = "Customer_Id"
        case count = "Count"
        case cost = "Cost"
        case discount = "Discount"
        case total_Cost = "Total_Cost"
        case stockRemainsCount = "StockRemainsCount"
        case check = "Check"
        case goods = "Goods"
        case sizes = "Sizes"
        case employees = "Employees"
        case customer = "Customer"
    }
}

//оплата
struct Payment: Codable{
    var Id: Int
    var Payment_Type_Id: Int?
    var Check_Id: Int?
    var Cost: Decimal?
    var PaymentType: PaymentType?
    //var Check: Check
}

// Тип оплаты
struct PaymentType: Codable {
    var id: Int
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
    }
}

struct BarCodeFind: Codable {
    var id: Int
    var goods_id: Int?
    var sizes_id: Int?
    var code: Decimal?
    var goods: Goods?
    var sizes: Sizes?
    var receipt: Receipt?
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case goods_id = "Goods_Id"
        case sizes_id = "Sizes_Id"
        case code = "Code"
        case goods = "Goods"
        case sizes = "Sizes"
        case receipt = "Receipt"
    }
}

//Режим инвентаризации

struct InventoryCode: Codable {
    var code: String?

    enum CodingKeys: String, CodingKey {
        case code = "code"
    }
}

// Количество товаров на витрине
struct InventoryFrontShop: Codable {
    var goods_id: Int
    var min_size_id: Int?
    var scan_size_id: Int?
    var cnt: Int?
    var status: Int?
    var location: String?
    var type_goods_id: Int?
    var g_nm: String?
    var g_nm_short: String?
    var s_min_nm: String?
    var s_scan_nm: String?
    
    enum CodingKeys: String, CodingKey {
        case goods_id = "goods_id"
        case min_size_id = "min_size_id"
        case scan_size_id = "scan_size_id"
        case cnt = "cnt"
        case status = "status"
        case location = "location"
        case type_goods_id = "type_goods_id"
        case g_nm = "g_nm"
        case g_nm_short = "g_nm_short"
        case s_min_nm = "s_min_nm"
        case s_scan_nm = "s_scan_nm"
    }
}

// Запись одного товара в витринной инвентаризации
struct InventoryFrontShopRow: Codable {
    var id: Int
    var goods_Id: Int?
    var sizes_Id: Int?
    var cnt: Int?
    var status: Int?
    var goods: Int?
    var sizes: String?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case goods_Id = "Goods_Id"
        case sizes_Id = "Sizes_Id"
        case status = "Status"
        case cnt = "Cnt"
        case goods = "Goods"
        case sizes = "Sizes"
    }
}
// Ответ от сканирования товара
struct ResponseScannedGood: Codable {
    var id: Int
    var goods_Id: Int?
    var sizes_Id: Int?
    var sizes_Min_Id: Int?
    var cnt: Int?
    var goods: Goods?
    var sizes: Sizes?
    var sizes_Min: Sizes?
    var status: Int?
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case goods_Id = "Goods_Id"
        case sizes_Id = "Sizes_Id"
        case sizes_Min_Id = "Sizes_Min_Id"
        case cnt = "Cnt"
        case goods = "Goods"
        case sizes = "Sizes"
        case sizes_Min = "Sizes_Min"
        case status = "Status"
    }
}

// Лист товаров для витринной инвентаризации
struct InventoryFrontShopList: Codable {
    var totalAll: Int
    var scanned: Int
    var list: [InventoryFrontShop]
    
    enum CodingKeys: String, CodingKey {
        case totalAll = "TotalAll"
        case scanned = "Scanned"
        case list = "List"
    }
}



// Достижения продавцов
struct userAchivements: Codable {
    var name: String
    var value: Decimal?
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case value = "value"
    }
}

// Лист достижений продавцов
struct userListAchivements: Codable {
    var day: [userAchivements]
    var week: [userAchivements]
    var month: [userAchivements]
    
    enum CodingKeys: String, CodingKey {
        case day = "day"
        case week = "week"
        case month = "month"
    }
}

// ИЗображения товаров

struct goodsImages: Codable {
    var id: Int
    var name: String?
    var goodsId: Int?
    var base64: String?
    var is_Main: Bool?
    var url: imageURLpath?
    
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case goodsId = "Goods_Id"
        case base64 = "Base64"
        case url = "Url"
        case is_Main = "Is_Main"
    }
}
// Отправление картинки товара
struct postImage: Codable {
    var base64: String
    enum CodingKeys: String, CodingKey {
        case base64 = "base64"
    }
}
//  URL goods images path
struct imageURLpath: Codable {
    var min: String
    var main: String
    
    enum CodingKeys: String, CodingKey {
        case min = "min"
        case main = "main"
    }
}

// Оставшееся время 
struct timeRemaning: Codable {
    var day_num: Int
    var day_name: String
    var remaining_time: String
    var cnt_p: Int
    var cnt_c: Int
    
    enum CodingKeys: String, CodingKey {
        case day_num = "day_num"
        case day_name = "day_name"
        case remaining_time = "remaining_time"
        case cnt_p = "cnt_p"
        case cnt_c = "cnt_c"
    }
}


/*
struct mainReportDrill2: Codable {
    var records: [mainResultsDrill2]
    enum CodingKeys: String, CodingKey {
        case records = "records"
    }
}

struct mainResultsDrill2: Codable {
    var tg_nm : String
    var cnt_c : Int
    var sum_c : Decimal
    
    enum CodingKeys: String, CodingKey {
        case tg_nm = "tg_nm"
        case cnt_c = "cnt_c"
        case sum_c = "sum_c"
    }
}

struct mainReportDrill3: Codable {
    var records: [mainResultsDrill3]
    enum CodingKeys: String, CodingKey {
        case records = "records"
    }
}

struct mainResultsDrill3: Codable {
    var g_nm : String
    var cnt_c : Int
    var sum_c : Decimal
    
    enum CodingKeys: String, CodingKey {
        case g_nm = "g_nm"
        case cnt_c = "cnt_c"
        case sum_c = "sum_c"
    }
}*/




// Общие продажи для виджета

struct salesDay: Codable {
    var e_nm: String?
    var e_id: Int?
    var cnt_ch: Int?
    var cnt_p: Int?
    var sum_sls: Int?
    var sum_rtr: Int?
    var sum_socks: Int?
    var sum_goods: Int?
    var ch_p: String?
    var sls_rtr: Int?
    var avg_ch: Int?
    var avg_goods: Decimal?
    var zp: Decimal?
    var sum_zp: String?
    var avg_ch_goods: String?
    enum CodingKeys: String, CodingKey {
        case e_nm = "e_nm"
        case e_id = "e_id"
        case cnt_ch = "cnt_ch"
        case cnt_p = "cnt_p"
        case sum_sls = "sum_sls"
        case sum_rtr = "sum_rtr"
        case sum_socks = "sum_socks"
        case sum_goods = "sum_goods"
        case ch_p = "ch_p"
        case sls_rtr = "sls_rtr"
        case avg_ch = "avg_ch"
        case avg_goods = "avg_goods"
        case zp = "zp"
        case sum_zp = "sum_zp"
        case avg_ch_goods = "avg_ch_goods"
    }
}
// Складская инвентаризация

struct stockInventoryView: Codable {
    var recordsTotal: Int
    var recordsFiltered : Int?
    var data : [stockInventoryViewData]?
    
    enum CodingKeys: String, CodingKey {
        case recordsTotal = "recordsTotal"
        case recordsFiltered = "recordsFiltered"
        case data = "data"
    }
}

struct stockInventoryViewData: Codable {
    var id: Int
    var goodId : Int?
    var sizesId : Int?
    var remain: Int?
    var remainFact: Int?
    var updatedBy: Int?
    var rFact: Int?
    var g_nm: String?
    var location: String?
    var sizeName: String?
    var diff: Int?
    var updated_on: String?
    var is_approved: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case goodId = "goods_id"
        case sizesId = "sizes_id"
        case remain = "remain"
        case remainFact = "remain_fact"
        case updatedBy = "updated_by"
        case rFact = "r_fact"
        case g_nm = "g_nm"
        case location = "location"
        case sizeName = "s_nm"
        case diff = "diff"
        case updated_on = "updated_on"
        case is_approved = "is_approved"
    }
}
struct scannedGoodsInStockinventory: Codable {
    var id : Int
    var goods_id : Int?
    var sizes_id : Int?
    var remain : Int?
    var remain_fact : Int?
    var goods: Goods?
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case goods_id = "Goods_id"
        case sizes_id = "Sizes_Id"
        case remain = "Remain"
        case remain_fact = "Remain_Fact"
        case goods = "Goods"
    }
}
struct stockInventoryResult: Codable {
    var records_off_sale: Int?
    var records_receipts: Int?
    
    enum CodingKeys: String, CodingKey {
        case records_off_sale = "records_off_sale"
        case records_receipts = "records_receipts"
    }
}

struct DeviceToken: Codable {
    var device_token: String?
    
    enum CodingKeys: String, CodingKey {
    case device_token = "device_token"
    }
}


