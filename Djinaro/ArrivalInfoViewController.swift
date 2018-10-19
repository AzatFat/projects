//
//  ArrivalInfoViewController.swift
//  Djinaro
//
//  Created by Azat on 16.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class ArrivalInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBAction func addNewGood(_ sender: Any) {
        performSegue(withIdentifier: "GoodsList", sender: nil)
    }
    @IBOutlet var tableView: UITableView!
    @IBOutlet var arrivalName: UITextField!
    @IBOutlet var receiptDate: UITextField!
    @IBOutlet var theDate: UITextField!
    
    var receiptId = ""
    let receiptController = ReceiptController()
    var recieptDocument: ReceiptDocument?
    var receipts: [Receipt]?
    var receiptsToAddNewGoodsController =  [Receipt]()
    var receiptsnameToAddNewGoodsController: Goods?
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    struct GroupReceipts {
        var objectGood : Goods!
        var objectRaw : [Receipt]!
        var objectCost : String!
    }
    
    var GroupReceiptsList = [GroupReceipts]()
    
    
    func addPreload(start_stop: Bool){
        if start_stop {
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.style = UIActivityIndicatorView.Style.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        
    }
    
    func countCostEachreceipt(receipts: [Receipt]) -> [GroupReceipts] {
        var GroupReceiptsList = [GroupReceipts]()
        var receiptDictionary : Dictionary = [String:[Receipt]]()
        for i in receipts {
            if let receiptId = i.goods_Id {
                if receiptDictionary[String(receiptId)] != nil {
                    receiptDictionary[String(receiptId)]!.append(i)
                } else {
                    receiptDictionary[String(receiptId)] = [i]
                }
            }
        }
        
        for i in receiptDictionary {
            var cost : Decimal = 0.0
            let good = i.value[0].goods
            for j in i.value {
                if let goodCost = j.cost {
                    cost += goodCost * Decimal(j.count!)
                }
            }
            GroupReceiptsList.append(GroupReceipts(objectGood: good, objectRaw: i.value, objectCost: cost.formattedAmount))
        }
        return GroupReceiptsList
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GroupReceiptsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "arrivalInfoCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ArrivalInfoTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GoodsArrivalTableViewCell.")
        }
        cell.arrivalGood.text = GroupReceiptsList[indexPath.row].objectGood.name
        cell.arrivalCost.text = GroupReceiptsList[indexPath.row].objectCost
        // print(CostEachreceipt.inn(forKey: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath as IndexPath)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        if let receipts = GroupReceiptsList[indexPath.row].objectRaw {
            receiptsToAddNewGoodsController = receipts
            receiptsnameToAddNewGoodsController = GroupReceiptsList[indexPath.row].objectGood
        }
        
        performSegue(withIdentifier: "addGoodToArrival", sender: cell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addGoodToArrival" {
            let controller = segue.destination as! AddGoodsToArrivalViewController
            controller.receipts = receiptsToAddNewGoodsController
            controller.good = receiptsnameToAddNewGoodsController
            controller.receipt_Document_Id = recieptDocument?.id
        }
        if segue.identifier == "GoodsList" {
            let controller = segue.destination as! GoodsTableViewController
            controller.segue = "addGoodToArrival"
            controller.title = "Выбор товара"
            controller.receipts = receiptsToAddNewGoodsController
            controller.receipt_Document_Id = recieptDocument?.id
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addPreload(start_stop: true)
        
        if receiptId != "" {

            receiptController.GetReceiptDocument(id: receiptId) { (receiptDocument) in
                
                if let receiptDocument = receiptDocument {
                    self.recieptDocument = receiptDocument
                }
                DispatchQueue.main.async {
                   // self.tableView.reloadData()
                    
                    if let receipts = self.recieptDocument?.receiptList {
                        self.GroupReceiptsList = self.countCostEachreceipt(receipts: receipts)
                        self.tableView.reloadData()
                    }
                    self.arrivalName.text = self.recieptDocument?.name
                    self.receiptDate.text = self.recieptDocument?.receipt_Date?.components(separatedBy: "T")[0]
                    self.theDate.text = self.recieptDocument?.the_Date?.components(separatedBy: "T")[0]
                    self.addPreload(start_stop: false)
                }
            }
        }
    }
}

