//
//  GoodInformationViewController.swift
//  Djinaro
//
//  Created by azat fatykhov on 08/10/2019.
//  Copyright © 2019 Azat. All rights reserved.
//

import UIKit




class GoodInformationViewController:  BaseTableVewSearchController<GoodInfoCell,  GooodsCellRepresentation>, ViewForImagePresenting {

    fileprivate var request: AnyObject?
    var goodId: Int?
    var goods: Goods?
    var pickerData: [TypeGoods]?
    
    
    var goodUIImagesDict = [goodUIimages.init(id: "main", image: UIImage(named: "addPhoto")!, main: false)]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let goodId = goodId {
            GetGood(goodId: goodId)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Печать", style: .plain, target: self, action: #selector(addTapped))
        
        // Do any additional setup after loading the view.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        print(models[indexPath.row].cellType)
        switch models[indexPath.row].cellType {
        case .groupPicker:
            let vc = CellEditForGroups()
            vc.bindType =  models[indexPath.row].goodChangeBind
            vc.title = models[indexPath.row].description
            vc.text = models[indexPath.row].title
            vc.delegate = self
            modalPresentationStyle = .fullScreen
            self.present(vc, animated: true) {
               // The popover is visible.
            }
        case .picker:
        
            let vc = CellEditCOntrollerWithDataPicker()
            vc.bindType =  models[indexPath.row].goodChangeBind
            vc.title = models[indexPath.row].description
            vc.text = models[indexPath.row].title
            vc.pickerData = pickerData ?? []
            vc.delegate = self
            modalPresentationStyle = .fullScreen
            self.present(vc, animated: true) {
               // The popover is visible.
            }
        case .bool:
            break
        case .save:
            
            if let goods = goods {
                changeGood(good: goods)
            }
        default:
            let vc = CellEditController()
            vc.bindType =  models[indexPath.row].goodChangeBind
            vc.title = models[indexPath.row].description
            vc.text = models[indexPath.row].title
            switch models[indexPath.row].cellType {
            case .number:
                vc.keyboardType = .decimalPad
            default :
                vc.keyboardType = .default
            }
            vc.delegate = self
            modalPresentationStyle = .fullScreen
            self.present(vc, animated: true) {
               // The popover is visible.
            }
        }
        
    }
    
    func updateTableView(goods: Goods) {
        self.getGoodImage()
        self.getGoodsType()
        var mod = goods.goodCells
        mod[9].delegateForUISwitch = self
        mod[8].delegateForUISwitch = self
        mod[10].delegateForUISwitch = self
        if  mod[11] != nil {
            mod[11].delegate = self
            mod[11].goods = goods
               // self?.models[11].delegateForReloadingTable = self
        }
        self.models = mod
    }
    
    func GetGood(goodId: Int) {
        let goods = GoodInformation(goodId: goodId)
        let goodRequest = ApiRequest(resource: goods)
        request = goodRequest
        goodRequest.load { [weak self] (goods: Goods?) in
            if let goods = goods {
                self?.goods = goods
                self?.updateTableView(goods: goods)
                    // self?.models
            } else {
                print("data good not loaded")
            }
        }
    }
    
    /// TO DO change to networkLayer
    func getGoodImage() {
        let receiptController = ReceiptController(useMultiUrl: true)
        if let goodImages = goods?.images {
            let myGroup = DispatchGroup()
            for images in goodImages {
                myGroup.enter()
                if let imageUrl = images.url?.main {
                    receiptController.getGoodImage(url: imageUrl) { (image) in
                        if let image = image {
                            print("full success get image")
                            self.goodUIImagesDict.append(goodUIimages.init(id: String(images.id), image: image, main: images.is_Main ?? false))
                            
                            myGroup.leave()
                        }else {
                            myGroup.leave()
                        }
                    }
                } else {
                    myGroup.leave()
                }
            }
            myGroup.notify(queue: .main) {
                self.models[11].goodUIImagesDict = self.goodUIImagesDict
                //self.tableView.reloadData()
                //self.setImages().reloadData()
            }
        }
    }
    
    @objc func addTapped() {
        printGoodsLableShop()
    }
    
    
    
    func printGoodsLableShop() {
        let receiptController = ReceiptController(useMultiUrl: true)
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        if let good_id = goods?.id,  goods?.price != nil {
            receiptController.POSTGoodPrintShopLabel(token: token, goodId: String(good_id)) { (answer) in
                DispatchQueue.main.async {
                    if let answer = answer {
                        self.error(title: answer)
                    }
                }
            }
        } else {
            error(title: "Цена товара равна нулю. Печать не возможна")
        }
    }
    
    func changeGood(good: Goods) {
        let receiptController = ReceiptController(useMultiUrl: true)
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        receiptController.PUTGood(token: token, post: good) { (answer) in
            DispatchQueue.main.async {
                self.error(title: "Товар успешно изменен")
               // updateTableView(goods: good)
            }
        }
    }
    
    func getGoodsType () {
        let receiptController = ReceiptController(useMultiUrl: true)
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        receiptController.GETTypeGoods(token: token) { (typeGoods) in
            if let typeGoods = typeGoods {
                DispatchQueue.main.async {
                    if self.goods != nil {
                        self.pickerData = typeGoods
                        for i in typeGoods {
                            if self.goods?.type_Goods_Id == i.id {
                                self.models[6].title = i.name ?? ""
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    func error(title : String) {
        //self.addPreload(start_stop: false)
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
}




extension GoodInformationViewController: changeValue {
    func changeGoodsValues<T> (newValue: T, bind: goodChangeBind) {
       
        switch bind {
        case .name:
            goods?.name = newValue as? String
        case .location:
            goods?.location = newValue as? String
        case .price:
            goods?.price = Decimal(string: newValue as! String)
        case .discountPrice:
            goods?.price_Discount = Decimal(string: newValue as! String)
        case .group:
            let group = newValue as? (String, Int )
            goods?.groupGoods = GroupGoods(id: group?.1 ?? 0,  name: group?.0)
            goods?.group_Goods_Id = group?.1
        case .type:
            let group = newValue as? (String, Int )
            goods?.type_Goods?.name = group?.0
            goods?.type_Goods_Id = group?.1
        case .manufacturer:
            goods?.factory = newValue as? String
        case .articul:
            goods?.vendor_Code = newValue as? String
        case .isArchive:
            goods?.isArchive = !(newValue as! Bool)
        case .broadcast_New:
            goods?.broadcast_New = (newValue as! Bool)
        case .save:
         
            if let goods = goods {
                print("save")
                changeGood(good: goods)
            }
            
        }
        if let good = goods {
           self.updateTableView(goods: good)
        }
    }
}
