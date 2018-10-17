//
//  ArrivalInfoViewController.swift
//  Djinaro
//
//  Created by Azat on 16.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class ArrivalInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
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
        cell.arrivalGood.text = GroupReceiptsList[indexPath.row].objectName
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
            receiptsnameToAddNewGoodsController = GroupReceiptsList[indexPath.row].objectName
        }
        
        performSegue(withIdentifier: "addGoodToArrival", sender: cell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addGoodToArrival" {
            
            let controller = segue.destination as! AddGoodsToArrivalViewController
            controller.receipts = receiptsToAddNewGoodsController
            controller.goodname = receiptsnameToAddNewGoodsController
            
        }
    }
    
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
    
    let mockData = String("""
        {
        "Id": 5,
        "Employees_Id": 1,
        "Name": "1122112",
        "Create_Date": "2018-10-13T12:02:03.0263+03:00",
        "Receipt_Date": "2018-10-13T00:00:00",
        "The_Date": "2018-10-13T00:00:00",
        "Employees": null,
        "ReceiptList": [
            {
            "Id": 8,
            "Receipt_Document_Id": 5,
            "Goods_Id": 875,
            "Sizes_Id": 1,
            "Cost": 2500.2,
            "Count": 2,
            "ReceiptDocument": null,
            "Sizes": null,
            "Goods": {
                "Id": 875,
                "Group_Goods_Id": 358,
                "Name": "Ремень Off White",
                "Code": "                                                  ",
                "Description": null,
                "Location": "                                                  ",
                "Vendor_Code": null,
                "GroupGoods": null
                }
            },
            {
            "Id": 9,
            "Receipt_Document_Id": 5,
            "Goods_Id": 876,
            "Sizes_Id": 1,
            "Cost": 2500.2,
            "Count": 2,
            "ReceiptDocument": null,
            "Sizes": null,
            "Goods": {
                "Id": 875,
                "Group_Goods_Id": 358,
                "Name": "Off White",
                "Code": "                                                  ",
                "Description": null,
                "Location": "                                                  ",
                "Vendor_Code": null,
                "GroupGoods": null
                }
            },
            {
            "Id": 9,
            "Receipt_Document_Id": 5,
            "Goods_Id": 877,
            "Sizes_Id": 1,
            "Cost": 2500.2,
            "Count": 2,
            "ReceiptDocument": null,
            "Sizes": null,
            "Goods": {
                "Id": 875,
                "Group_Goods_Id": 358,
                "Name": "White",
                "Code": "jkjk",
                "Description": null,
                "Location": "                                                  ",
                "Vendor_Code": null,
                "GroupGoods": null
                }
            }
        ]
    }
    """).data(using: .utf8)!
    
    
    var receiptId = ""
    let receiptController = ReceiptController()
    var recieptDocument: ReceiptDocument?
    var receipts: [Receipt]?
    var receiptsToAddNewGoodsController =  [Receipt]()
    var receiptsnameToAddNewGoodsController = ""
    
    @IBOutlet var arrivalName: UITextField!
    @IBOutlet var receiptDate: UITextField!
    @IBOutlet var theDate: UITextField!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    struct GroupReceipts {
        var objectName : String!
        var objectRaw : [Receipt]!
        var objectCost : String!
    }
    
    var GroupReceiptsList = [GroupReceipts]()
    
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
            let name = i.value[0].goods?.name
            for j in i.value {
                if let goodCost = j.cost {
                    cost += goodCost
                }
            }
            GroupReceiptsList.append(GroupReceipts(objectName: name, objectRaw: i.value, objectCost: cost.formattedAmount))
        }
        return GroupReceiptsList
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addPreload(start_stop: true)
        
        if receiptId != "" {

            receiptController.GetReceiptDocument(id: receiptId) { (receiptDocument) in
                
                if let receiptDocument = receiptDocument {
                    self.recieptDocument = receiptDocument
                } else {
                    print("receiptDocument failed")
                    let data = self.mockData
                    
                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode(ReceiptDocument.self, from: data)
                        self.recieptDocument = product
                        //addPreload(start_stop: false)

                    } catch let error {
                        print("error in getting ReceiptDocument")
                        print(error)
                    }
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
        
        // Do any additional setup after loading the view.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

