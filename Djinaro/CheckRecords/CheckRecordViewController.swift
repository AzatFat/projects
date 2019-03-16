//
//  CheckRecordViewController.swift
//  Djinaro
//
//  Created by Azat on 05.11.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class CheckRecordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet var TotalCost: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var Client: UILabel!
    
    
    @IBOutlet var addClientBtn: UIButton!
    @IBAction func AddClient(_ sender: Any) {
        performSegue(withIdentifier: "showClients", sender: nil)
    }
    
    @IBAction func AddChekRecord(_ sender: Any) {
        performSegue(withIdentifier: "addGoodsFromSearch", sender: nil)
    }
    
    @IBOutlet var cameraBTN: UIButton!
    @IBAction func Camera(_ sender: Any) {
        performSegue(withIdentifier: "addGoodToCheck", sender: nil)

    }
    
    @IBAction func payCheckBTN(_ sender: Any) {
        performSegue(withIdentifier: "payCheck", sender: nil)

    }
    
    @IBAction func unwindToContainerVC(segue: UIStoryboardSegue) {
        
    }
    
    
    
    var recieptController = ReceiptController(useMultiUrl: true)
    let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
    var token = ""
    var userId = ""
    var check: Check?
    var checkId: Int?
    var totalCost: Decimal = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        token = defaults?.value(forKey:"token") as? String ?? ""
        userId = defaults?.value(forKey:"userId") as? String ?? ""
        checkAppear()
        
        let addClientImage = UIImage(named: "addClient");
        let cameraBtnImage = UIImage(named: "camera4");
        
        let tintedImage = addClientImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        addClientBtn.setImage(tintedImage, for: .normal)
        
        let tintedImage2 = cameraBtnImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        
        cameraBTN.setImage(tintedImage2, for: .normal)
        
        
        addClientBtn.tintColor = self.view.tintColor
        cameraBTN.tintColor = self.view.tintColor
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkAppear()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let check = check, let CheckRecord = check.checkRecordList {
            return CheckRecord.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ChekRecordGoods"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CheckRecordsTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GoodsAvailableTableViewCell.")
        }
        if let check = check, let checkRecord = check.checkRecordList {
            cell.goodName.text = checkRecord[indexPath.row].goods?.name
            cell.checkRecordTotalCost.text = checkRecord[indexPath.row].total_Cost?.formattedAmount
            cell.CheckRecordCountOutlet.text = String(checkRecord[indexPath.row].count!)
            cell.size.text = checkRecord[indexPath.row].sizes?.name
        }
        return cell
 
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let checkRecord = check!.checkRecordList![indexPath.row]
            recieptController.DELETECheckRecord(token: token, id: String(checkRecord.id)) { (receipt) in
                DispatchQueue.main.async {
                    self.check?.checkRecordList?.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
            // Delete the row from the data source
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let checkRecord = check?.checkRecordList?[indexPath.row] {
            alertOnClickCheckRecord(indexPath: indexPath.row, checkRecord: checkRecord)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addGoodToCheck" {
            let controller = segue.destination as! QRScannerController
            if let check = check {
                let checkRecord = CheckRecord.init(id: 1, check_Id: check.id, goods_Id: nil, sizes_Id: nil, employees_Id: Int(userId), customer_Id: 0, count: 1, cost: nil, discount: nil, total_Cost: nil, stockRemainsCount: nil, check: nil, goods: nil, sizes: nil, employees: nil, customer: nil)
                print("checkRecord in chekRecordCOntroller is \(checkRecord)")
                controller.checkRecord = checkRecord
            }
        }
        if segue.identifier == "showClients" {
            let controller = segue.destination as! CustomerTableViewController
            if let check = check {
                let checkRecord = CheckRecord.init(id: 1, check_Id: check.id, goods_Id: nil, sizes_Id: nil, employees_Id: Int(userId), customer_Id: 0, count: 1, cost: nil, discount: nil, total_Cost: nil, stockRemainsCount: nil, check: nil, goods: nil, sizes: nil, employees: nil, customer: nil)
                print("checkRecord in chekRecordCOntroller is \(checkRecord)")
                controller.checkRecord = checkRecord
            }
        }
        
        if segue.identifier == "addGoodsFromSearch" {
            let controller = segue.destination as! GoodsTableViewController
            if let check = check {
                let checkRecord = CheckRecord.init(id: 1, check_Id: check.id, goods_Id: nil, sizes_Id: nil, employees_Id: Int(userId), customer_Id: 0, count: 1, cost: nil, discount: nil, total_Cost: nil, stockRemainsCount: nil, check: nil, goods: nil, sizes: nil, employees: nil, customer: nil)
                print("checkRecord in chekRecordCOntroller is \(checkRecord)")
                controller.checkRecord = checkRecord
            }
        }
        
        if segue.identifier == "payCheck" {
            let controller = segue.destination as! PayChekViewController
            if let check = check {
                controller.check = check
                controller.totalCost = totalCost
            }
        }
    }
    
    func checkAppear() {
        if let checkId = checkId {
            recieptController.GetCheck(id: String(checkId), token: token) { (check) in
                if let check = check {
                    self.check = check
                    DispatchQueue.main.async {
                        self.title = String(check.id)
                        var chekTotalCost: Decimal = 0
                        if let recordList = check.checkRecordList {
                            for checkRecord in recordList {
                                chekTotalCost += checkRecord.total_Cost ?? 0
                            }
                            if recordList.count > 0 {
                                let customerName = recordList[0].customer?.name ?? ""
                                let customerSurname = recordList[0].customer?.middle_Name ?? ""
                                let customerFullNAme = customerName + " " + customerSurname
                                self.Client.text = customerFullNAme
                                
                            }
                        }
                        self.totalCost = chekTotalCost
                        self.TotalCost.text = chekTotalCost.formattedAmount
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    /// Установить скидку на товар
    func alertOnClickCheckRecord(indexPath: Int, checkRecord: CheckRecord) {
        var loginTextField: UITextField?
        var numberOfGoods: UITextField?
        var newCheckRecord = checkRecord
        
        let alertController = UIAlertController(title: "Настройки \(newCheckRecord.goods_Id ?? 1)", message: nil, preferredStyle: .alert)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left

        let messageText = NSMutableAttributedString(
            string: "Скидка и количество",
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
        )
   
        alertController.setValue(messageText, forKey: "attributedMessage")
       // alertController.setValue(messageText, forKey: "attributedMessage")
        alertController.addTextField { (textField) -> Void in
            loginTextField = textField
            loginTextField?.delegate = self as? UITextFieldDelegate //REQUIRED
            loginTextField?.placeholder = "Сумма скидки"
            loginTextField?.keyboardType = .decimalPad
        }
        
        alertController.addTextField { (textField) -> Void in
            numberOfGoods = textField
            numberOfGoods?.delegate = self as? UITextFieldDelegate //REQUIRED
            numberOfGoods?.placeholder = "Количество"
            numberOfGoods?.text = "\(checkRecord.count ?? 1)"
            numberOfGoods?.keyboardType = .decimalPad
        }
        
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        let putDiscount = UIAlertAction(title: "Установить", style: .default) { (action) in
            
            let textField = loginTextField?.text
            let countText = numberOfGoods?.text
            if countText == "" {
                newCheckRecord.count = 1
            } else {
                newCheckRecord.count = Int(countText ?? "1")
            }
            newCheckRecord.discount = Decimal(string: textField ?? "0")
            self.recieptController.PUTChekRecord(token: self.token, post: newCheckRecord, completion: { (checkRecord) in
                if let checkRecord = checkRecord {
                    print(checkRecord)
                    DispatchQueue.main.async {
                        self.checkAppear()
                    }
                }
            })
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(putDiscount)
        
        
        present(alertController, animated: true, completion: nil)
    }
    
    
}
