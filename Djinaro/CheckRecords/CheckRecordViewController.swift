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
    @IBAction func AddClient(_ sender: Any) {
        performSegue(withIdentifier: "showClients", sender: nil)
    }
    
    @IBAction func AddChekRecord(_ sender: Any) {
        performSegue(withIdentifier: "addGoodsFromSearch", sender: nil)
    }
    
    @IBAction func Camera(_ sender: Any) {
        performSegue(withIdentifier: "addGoodToCheck", sender: nil)
    }
    @IBAction func unwindToContainerVC(segue: UIStoryboardSegue) {
        
    }
    
    
    
    var recieptController = ReceiptController(useMultiUrl: true)
    let defaults = UserDefaults.standard
    var token = ""
    var userId = ""
    var check: Check?
    var checkId: Int?
    var totalCost = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        token = defaults.object(forKey:"token") as? String ?? ""
        userId = defaults.object(forKey:"userId") as? String ?? ""
        checkAppear()
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
            cell.checkRecordTotalCost.text = checkRecord[indexPath.row].cost?.formattedAmount
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
                    self.check!.checkRecordList!.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
            // Delete the row from the data source
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
                        
                        self.TotalCost.text = chekTotalCost.formattedAmount
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}
