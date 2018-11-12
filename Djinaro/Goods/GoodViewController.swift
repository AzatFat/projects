//
//  GoodViewController.swift
//  Djinaro
//
//  Created by Azat on 15.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class GoodViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    @IBOutlet var doneOutlet: UIBarButtonItem!
    @IBAction func doneAction(_ sender: Any) {}
    
    var recieptController = ReceiptController()
    var goodsInfoViewController = GoodInfoViewController()
    
    var goodId = ""
    var good: Goods?
    var receipt_Document_Id : Int?
    var location = ""
    var name = ""
    let defaults = UserDefaults.standard
    var token = ""
    var userId = ""
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var checkRecord: CheckRecord?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPreload(start_stop: true)
        token = defaults.object(forKey:"token") as? String ?? ""
        userId = defaults.object(forKey:"userId") as? String ?? ""
        
        recieptController.GetGood(token: token, goodId: goodId) { (good) in
            if let good = good {
                self.good = good
                if let goodName = good.name, let goodLocation = good.location {
                    self.location = goodLocation
                    self.name = goodName
                    self.goodsInfoViewController.changeLocation(goodName:  self.name, goodLocation:  self.location)
                }
            }
            DispatchQueue.main.async {
                self.addPreload(start_stop: false)
                self.table.reloadData()
            }
        }
        // Do any additional setup after loading the view.
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let good = good, let avaliableSizes = good.available_sizes {
            return avaliableSizes.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // print(CostEachreceipt.inn(forKey: indexPath.row))
        let cellIdentifier = "avaliableGood"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GoodsAvailableTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GoodsAvailableTableViewCell.")
        }
        if let good = good, let avaliableSizes = good.available_sizes {
            cell.goodCount.text = String(avaliableSizes[indexPath.row].count!)
            cell.goodSize.text = String(avaliableSizes[indexPath.row].sizes!.name!)
            cell.goodPrise.text = String(avaliableSizes[indexPath.row].cost!.formattedAmount!)
        }
        return cell
    }
   /*
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .addGoodToCheck {
            
        }
        
    }*/
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let addGoodToCheck = UITableViewRowAction(style: .normal, title: "Добавить в чек") { (action, indexPath) in
            if let checkRecord = self.checkRecord, let good = self.good, let avaliableSizes = self.good!.available_sizes {
                print(good)
                self.addGoodTocheck(checkRecord: checkRecord, goodId: good.id, sizes_Id: (avaliableSizes[indexPath.row].sizes!.id), cost: avaliableSizes[indexPath.row].cost!)
            } else if let good = self.good, let avaliableSizes = self.good!.available_sizes{
                self.addNewCheck(goodId: good.id, sizes_Id: (avaliableSizes[indexPath.row].sizes!.id), cost: avaliableSizes[indexPath.row].cost!)
            }
        }
        addGoodToCheck.backgroundColor = UIColor.blue
        
        return [addGoodToCheck]
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? GoodInfoViewController, segue.identifier == "goodInfo" {
            controller.goodName = location
            controller.goodLocation = name
            self.goodsInfoViewController = controller
        }
        if segue.identifier == "addGoodToCheck" {
            let controller = segue.destination as! CheckRecordViewController
            controller.checkId = checkRecord?.check_Id
        }
        
    }
    
    func addPreload(start_stop: Bool){
        if start_stop {
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.style = UIActivityIndicatorView.Style.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            //   activityIndicator.style = UIActivityIndicatorView.t
            // itemsTableViewController.shared.beginIgnoringInteractionEvents()
        } else {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                // UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
        
    }
    
    func addGoodTocheck(checkRecord: CheckRecord, goodId: Int, sizes_Id: Int, cost: Decimal) {
        var POSTCheckRecord = checkRecord
        
        POSTCheckRecord.goods_Id = goodId
        POSTCheckRecord.sizes_Id = sizes_Id
        POSTCheckRecord.cost = cost
        POSTCheckRecord.discount = 0
        POSTCheckRecord.total_Cost = cost
        print(POSTCheckRecord)
        self.recieptController.POSTCheckRecord(token: self.token, post: POSTCheckRecord) { (checkRecord) in
            if let checkRecord = checkRecord {
                print("added checkRecord is \(checkRecord)")
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "addGoodToCheck", sender: self)
                }
            } else {
                print("error in add checkRecord \(String(describing: checkRecord))")
            }
        }
    }
    
    func addNewCheck(goodId: Int, sizes_Id: Int, cost: Decimal){
        recieptController.GetLastShift(token: token) { (shift) in
            if let shift = shift {
                 let newCheck = Check.init(id: 1, customer_Id: 0, employees_Id: Int(self.userId), shift_Id: shift.id, check_Type_Id: 1, payment_Type_Id: nil, cash: nil, card: nil, is_Deferred: nil, is_Cancelled: nil, create_Date: nil, the_Date: nil, customer: nil, checkType: nil, employees: nil, shift: nil, checkRecordList: nil, payment: nil)
                self.recieptController.POSTCheck(token: self.token, post: newCheck) { (check) in
                    if let check = check {
                        var POSTCheckRecord = CheckRecord.init(id: 1, check_Id: check.id, goods_Id: nil, sizes_Id: nil, employees_Id: Int(self.userId), customer_Id: 0, count: 1, cost: nil, discount: nil, total_Cost: nil, stockRemainsCount: nil, check: nil, goods: nil, sizes: nil, employees: nil, customer: nil)
                        
                        POSTCheckRecord.goods_Id = goodId
                        POSTCheckRecord.sizes_Id = sizes_Id
                        POSTCheckRecord.cost = cost
                        POSTCheckRecord.discount = 0
                        POSTCheckRecord.total_Cost = cost
                        
                        self.recieptController.POSTCheckRecord(token: self.token, post: self.checkRecord!) { (checkRecord) in
                            if let checkRecord = checkRecord {
                                print("added checkRecord is \(checkRecord)")
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "addGoodToCheck", sender: self)
                                }
                            } else {
                                print("error in add checkRecord \(String(describing: checkRecord))")
                            }
                        }
                    }
                }
            }
        }
    }
/*
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }*/
    

}
