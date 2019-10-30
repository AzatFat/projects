//
//  Good.swift
//  Djinaro
//
//  Created by azat fatykhov on 07/10/2019.
//  Copyright © 2019 Azat. All rights reserved.
//

import Foundation
import UIKit


protocol ViewForImagePresenting: UIViewController {
    
}

protocol ReloadData {
    func reloadData()
}

protocol changeValue {
    func changeGoodsValues<T> (newValue: T, bind: goodChangeBind)
}

enum goodChangeBind {
       case name
       case location
       case price
       case discountPrice
       case articul
       case manufacturer
       case type
       case group
       case isArchive
       case broadcast_New
       case save
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
    var type_Goods_Id: Int?
    var type_Goods: TypeGoods?
    var available_sizes:  [Available_sizes]?
    var price: Decimal?
    var priceReceipt: Decimal?
    var images: [goodsImages]?
    var image: String?
    var isArchive: Bool?
    var price_Discount: Decimal?
    var broadcast_New: Bool?
    var factory: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case group_Goods_Id = "Group_Goods_Id"
        case name = "Name"
        case code =  "Code"
        case description = "Description"
        case location = "Location"
        case vendor_Code = "Vendor_Code"
        case groupGoods = "GroupGoods"
        case type_Goods = "Type_Goods"
        case type_Goods_Id = "Type_Goods_Id"
        case available_sizes = "Available_sizes"
        case price = "Price"
        case priceReceipt = "Price_Receipt"
        case images = "Images"
        case image = "Image"
        case isArchive = "Is_Archive"
        case price_Discount = "Price_Discount"
        case broadcast_New = "Broadcast_New"
        case factory = "Factory"
    }
    
}


extension Goods {
    var goodCells: [GooodsCellRepresentation] {
        get {
            print(self)
            let cells = [
                GooodsCellRepresentation(title: self.name ?? "", description: "Название", goodCompletion: {print(1)}, cellType: .text, goodChangeBind: .name),
                GooodsCellRepresentation(title: self.location ?? "", description: "Локация", boolValue: nil, goodCompletion: {print(2)}, cellType: .text, goodChangeBind: .location),
                GooodsCellRepresentation(title: self.price?.formattedAmount ?? "", description: "Цена", goodCompletion: {print(3)}, cellType: .number, goodChangeBind: .price),
                GooodsCellRepresentation(title: self.price_Discount?.formattedAmount ?? "", description: "Цена со скидкой", goodCompletion: {print(4)}, cellType: .number, goodChangeBind: .discountPrice),
                GooodsCellRepresentation(title: self.vendor_Code ?? "", description: "Артикул", goodCompletion: {print(6)}, cellType: .text, goodChangeBind: .articul),
                GooodsCellRepresentation(title: self.factory ?? "", description: "Фабрика", goodCompletion: {print(6)}, cellType: .text, goodChangeBind: .manufacturer),
                GooodsCellRepresentation(title: self.type_Goods?.name ?? "", description: "Тип товара", goodCompletion: {print(4)}, cellType: .picker, goodChangeBind: .type),
                GooodsCellRepresentation(title: self.groupGoods?.name ?? "", description: "Группа", goodCompletion: {print(5)}, cellType: .groupPicker, goodChangeBind: .group),
                GooodsCellRepresentation(title: "Товар активный", boolValue: !(self.isArchive ?? true), goodCompletion: {print(6)}, cellType: .bool, goodChangeBind: .isArchive),
                GooodsCellRepresentation(title: "Отображается на сайте", boolValue: self.broadcast_New ?? false, goodCompletion: {}, cellType: .bool, goodChangeBind: .broadcast_New),
                GooodsCellRepresentation(title: "Сохранить", goodCompletion: {}, cellType: .save, goodChangeBind: .save),
                GooodsCellRepresentation(title: "1", goodCompletion: {}, cellType: .imagesCollection)
                ]
                return cells
            }
        }
}

protocol CellRepresentation {
    var description : String? {get}
    var title : String {get}
    var cellType: GoodsCellType {get}
}

enum GoodsCellType {
    case text
    case number
    case bool
    case picker
    case groupPicker
    case imagesCollection
    case save
}

struct goodUIimages {
    var id: String
    var image: UIImage
    var main: Bool
}

struct GooodsCellRepresentation: CellRepresentation {
    var title: String
    var description: String?
    var delegate: ViewForImagePresenting? = nil
    var delegateForUISwitch: changeValue? = nil
    var delegateForReloadingTable: ReloadData? = nil
    var boolValue: Bool?
    var goodUIImagesDict: [goodUIimages]? = []
    var goodCompletion: () -> ()
    var cellType: GoodsCellType
    var goodChangeBind: goodChangeBind? = nil
    var goods: Goods?
}


extension GooodsCellRepresentation: Searchable {
    var query: String {
        return title
    }
}

extension GooodsCellRepresentation: CellConfigurations {
    var completion: () -> () {
        goodCompletion
    }
    
    var cellHeight: CGFloat {
        switch self.cellType {
        case .save:
            return 80
        case .imagesCollection:
            return 120
        default:
            return 60
        }
    }
}



extension Goods: Searchable {
    var query: String {
        return name ?? ""
    }
}

