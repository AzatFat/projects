//
//  InventoryViewController.swift
//  Djinaro
//
//  Created by Azat on 27.11.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

protocol InventoryCellTapped: class {
    func segueToItemList(decodedString: String, searchType: String )
}

class InventoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SpyDelegate {
    
    var goodsFrontShop = [InventoryFrontShop]()
    var delegate: InventoryCellTapped!
    var inventoryType = ""
    var goodsStock : stockInventoryView?
    var typeGood = 0
    var typeName =  ""
    var is_all = false
    var userId = ""
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var countLable: UILabel!
    @IBOutlet var allGoods: UIButton!
    @IBAction func allGoodsChange(_ sender: Any) {
        if allGoods.title(for: .normal) == "Сканированные" {
            is_all = false
            allGoods.setTitle("Расхождения", for: .normal)
            self.getStockInventory(typeGood: self.typeGood, typeName: self.typeName, user_id: userId)
        } else {
            is_all = true
            allGoods.setTitle("Сканированные", for: .normal)
            self.getStockInventory(typeGood: self.typeGood, typeName: self.typeName, user_id: userId)
        }
        
    }
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //getFrontInventoryShop()
        tableView.backgroundColor = UIColor.clear
        view.backgroundColor = UIColor.clear
        
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: Any) {
        getStockInventory(typeGood: typeGood, typeName: typeName, user_id: userId)
        
        //  your code to refresh tableView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inventoryType == "frontInventory" {
            return goodsFrontShop.count
        } else if inventoryType == "stockInventory" {
            return goodsStock?.data?.count ?? 0
        }
        
        //countLable.text = String(countItems)
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = CustomCell(frame: CGRect(x : 15, y : 0, width: self.view.frame.width, height: 50))
        
        if inventoryType == "frontInventory" {
            let inventoryGood  = goodsFrontShop[indexPath.row]
            cell.cellTitleLabel.text = "\(inventoryGood.location ?? "Нет локации") | \(inventoryGood.g_nm_short ?? "Нет названия")"
            cell.cellLabel.text = "минимальный:  \(inventoryGood.s_min_nm ??  "не указано") | отсканирован: \(inventoryGood.s_scan_nm ??  "не указано")"
            switch inventoryGood.status {
                
            case 1:
                cell.backgroundColor = UIColor.yellow.withAlphaComponent(0.2)
            case 2:
                cell.backgroundColor = UIColor.red.withAlphaComponent(0.2)
            case 3:
                cell.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            default:
                cell.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            }
        } else if inventoryType == "stockInventory" {
            
            cell.cellTitleLabel.text = "\(goodsStock?.data?[indexPath.row].sizeName ?? "размер не указан") | \(goodsStock?.data?[indexPath.row].g_nm ?? "Нет названия")"
            cell.cellLabel.text = "Просканирован \(goodsStock?.data?[indexPath.row].remainFact ?? 0) | Остаток \(goodsStock?.data?[indexPath.row].remain ?? 0) | Разница \(goodsStock?.data?[indexPath.row].diff ?? 0)"
            cell.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            
            if goodsStock?.data?[indexPath.row].updated_on != nil  {
                cell.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            }
            
            if goodsStock?.data?[indexPath.row].is_approved == true {
                cell.backgroundColor = UIColor.green.withAlphaComponent(0.5)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cell = tableView.cellForRow(at: indexPath as IndexPath)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        if(delegate != nil) {
            if inventoryType == "frontInventory" {
                alertOnClickFrontShop(indexPath: indexPath.row)
            } else if inventoryType == "stockInventory" {
                alertOnClickStockRemain(indexPath: indexPath.row)
            }
            
        } else {
            print("delegate is nil")
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if inventoryType == "stockInventory" {
            let approveChange = UITableViewRowAction(style: .normal, title: "Подтвердить") { (action, indexPath) in
                if let approveId = self.goodsStock?.data?[indexPath.row].id {
                    self.approveStockChanges(indexPath: indexPath.row, invenoryId: approveId)
                }
            }
            return [approveChange]
        }
        return nil
        
    }
    
    /// Approve расхождения в инвентаризации
    func approveStockChanges(indexPath: Int, invenoryId: Int) {
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        let receiptController = ReceiptController(useMultiUrl: true)
        
        receiptController.POSTApproveInventory(token: token, inventoryId: String(invenoryId)) { (answer) in
            DispatchQueue.main.async {
                self.getStockInventory(typeGood: self.typeGood, typeName: self.typeName, user_id: self.userId)
                if let answer = answer {
                    self.error(title: answer)
                }
            }
        }
    }
    
    /// Действия при складской инвентаризации
    func alertOnClickStockRemain(indexPath: Int) {
        var loginTextField: UITextField?
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        var message = ""
        message += "Сканирован: \(goodsStock?.data?[indexPath].remainFact ?? 0)"
        message += "\nОстаток:    \(goodsStock?.data?[indexPath].remain ?? 0)"
        
        let messageText = NSMutableAttributedString(
            string: message,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
        )
        
        let alertController = UIAlertController(title: "\(goodsStock?.data?[indexPath].sizeName ?? "Нет названия") | \(goodsStock?.data?[indexPath].g_nm ?? "Нет названия")", message: nil, preferredStyle: .alert)
        
        alertController.setValue(messageText, forKey: "attributedMessage")
        alertController.addTextField { (textField) -> Void in
            loginTextField = textField
            loginTextField?.delegate = self as? UITextFieldDelegate //REQUIRED
            loginTextField?.placeholder = "Количество товаров"
            loginTextField?.keyboardType = .numberPad
        }
        
        let cancelAction = UIAlertAction(title: "К списку", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Исправить", style: .default) { (action) in
            
            
            if let textField = loginTextField?.text, textField != "" {
                let putGood = scannedGoodsInStockinventory.init(id: self.goodsStock?.data?[indexPath].id ?? 0, goods_id: self.goodsStock?.data?[indexPath].goodId, sizes_id: self.goodsStock?.data?[indexPath].sizesId, remain: self.goodsStock?.data?[indexPath].remain, remain_fact: Int(textField) ?? 0, goods: nil)
                self.putChangeToStockInventory(putScannedGood: putGood, indexPath: indexPath)
            }
            
        }
        
        let viewGood = UIAlertAction(title: "Перейти к товару", style: .default) { (action) in
            self.delegate.segueToItemList(decodedString: String(self.goodsStock!.data![indexPath].goodId!), searchType: "findGoodFromInventory")
            
        }
        
        let deleteScanned = UIAlertAction(title: "Удалить сканы по модели", style: .default) { (action) in
            
            self.POSTDeleteGoodModelFromScan(goodId: self.goodsStock!.data![indexPath].goodId!)
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        alertController.addAction(viewGood)
        alertController.addAction(deleteScanned)

        
        present(alertController, animated: true, completion: nil)
    }
    
    func alertOnClickFrontShop(indexPath: Int) {
        var message = ""
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let inventoryGood  = goodsFrontShop[indexPath]
        switch inventoryGood.status {
        case 1:
            message = "\nПросканирован два раза"
        case 2:
            message = "\nПросканирован Не минимальный размер"
            message += "\n\nминимальный:  \(inventoryGood.s_min_nm ??  "не указано")"
            message += "\n\nотсканирован: \(inventoryGood.s_scan_nm ??  "не указано")"
        case 3:
            message = "\nТовар не просканирован"
        default:
            message = "\nТовар не просканирован"
        }
        message += "\n\nЛокация:      \(inventoryGood.location ?? "Не указано")"
        
        let messageText = NSMutableAttributedString(
            string: message,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
        )
        
        let alertController = UIAlertController(title: inventoryGood.g_nm, message: nil, preferredStyle: .alert)
        alertController.setValue(messageText, forKey: "attributedMessage")
        
        let cancelAction = UIAlertAction(title: "К списку", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Перейти к товару", style: .default) { (action) in
            self.delegate.segueToItemList(decodedString: String(self.goodsFrontShop[indexPath].goods_id), searchType: "findGoodFromInventory")
            
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    func putChangeToStockInventory(putScannedGood: scannedGoodsInStockinventory, indexPath: Int) {
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        let receiptController = ReceiptController(useMultiUrl: true)
        receiptController.PUTScannedGoodInStock(token: token, put: putScannedGood, id: String(putScannedGood.id)) { (answer) in
            if answer != nil {
                DispatchQueue.main.async {
                    receiptController.GetScannedGoodInStock(id: String(putScannedGood.id), token: token, completion: { (scannedGood) in
                        if let scannedGood = scannedGood {
                            self.goodsStock?.data?[indexPath].remainFact = scannedGood.remain_fact
                            self.goodsStock?.data?[indexPath].diff = scannedGood.remain_fact! - scannedGood.remain!
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            }
        }
    }
    
    func getFrontInventoryShop(url: String) {
       // print("table reloaded")
        inventoryType = "frontInventory"
        countLable.text = "Ждем обновления"
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        let receiptController = ReceiptController(useMultiUrl: true)
        receiptController.GetFrontInventoryGoods(url: url,token: token) { (frontGoods) in
            if let frontGoods = frontGoods {
               self.goodsFrontShop = frontGoods.list
                DispatchQueue.main.async {
                    self.countLable.text = "\(String(frontGoods.scanned)) из \(String(frontGoods.totalAll))"
                }
            }
            DispatchQueue.main.async {
                self.goodsFrontShop.sort(by: { (lhs: InventoryFrontShop, rhs: InventoryFrontShop) -> Bool in
                    return lhs.status! < rhs.status!
                })
                self.tableView.reloadData()
               // self.addPreload(start_stop:  false)
            }
        }
    }

    func getStockInventory(typeGood: Int, typeName: String, user_id: String) {
        inventoryType = "stockInventory"
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        let receiptController = ReceiptController(useMultiUrl: true)
        receiptController.GetStockInventoryGoods(typeGood: String(typeGood), token: token, is_all: is_all, userId: user_id) { (stockInventory) in
            if let stockInventory = stockInventory {
                self.goodsStock = stockInventory
                if let data = self.goodsStock?.data, data.count > 0  {
                    DispatchQueue.main.async {
                        print()
                        self.countLable.text = "\(typeName) \(String(stockInventory.recordsFiltered ?? 0)) из \(String(stockInventory.recordsTotal)) "
                    }
                }
                DispatchQueue.main.async {
                    self.countLable.text = "\(typeName) \(String(stockInventory.recordsFiltered ?? 0)) из \(String(stockInventory.recordsTotal)) "
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            } else {
                print("dont get stockInventory")
                DispatchQueue.main.async {
                    self.countLable.text = "\(typeName) 0 из 0"
                }
            }
        }
    }
    
    func getStockInventorybyUser(typeGood: Int, typeName: String, userId: String) {
        inventoryType = "stockInventory"
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        let receiptController = ReceiptController(useMultiUrl: true)
        receiptController.GetStockInventoryGoodsByUser(typeGood: String(typeGood), token: token, userId: userId, is_all: is_all) { (stockInventory) in
            if let stockInventory = stockInventory {
                self.goodsStock = stockInventory
                if let data = self.goodsStock?.data, data.count > 0  {
                    DispatchQueue.main.async {
                        print()
                        self.countLable.text = "\(typeName) \(String(stockInventory.recordsTotal)) "
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            } else {
                print("dont get stockInventory")
            }
        }
    }
    
    /// Удаление сканирований по товару
    func POSTDeleteGoodModelFromScan(goodId: Int) {
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        let receiptController = ReceiptController(useMultiUrl: true)
        receiptController.POSTDeleteGoodModelFromScan(token: token, goodId: String(goodId)) { (answer) in
            DispatchQueue.main.async {
                self.getStockInventory(typeGood: self.typeGood, typeName: self.typeName, user_id: self.userId)
                if let answer = answer {
                    self.error(title: answer)
                }
            }
        }
    }
    
    func error(title : String) {
        //self.addPreload(start_stop: false)
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
           // self.found_bar = 0
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
 /*   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "GoodList" {
            let vc : QRScannerController = segue.destination as! QRScannerController
            vc.delegate = self
        }
    }*/
}

class CustomCell: UITableViewCell {
    var cellTitleLabel: UILabel!
    var cellLabel: UILabel!
    
    init(frame: CGRect) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "InventoryCell")
        
        cellLabel = UILabel(frame: CGRect(x: 15, y: 17, width: self.frame.width, height: 40))
        cellLabel.textColor = UIColor.white
        cellLabel.font = cellLabel.font.withSize(11)
        //cellLabel.font = //set font here
            
        cellTitleLabel = UILabel(frame: CGRect(x: 15, y: 5, width: self.frame.width, height: 30))
        cellTitleLabel.font = cellTitleLabel.font.withSize(12)
        cellTitleLabel.textColor = UIColor.white
       // cellTitleLabel.text = title
        
        addSubview(cellLabel)
        addSubview(cellTitleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
}

