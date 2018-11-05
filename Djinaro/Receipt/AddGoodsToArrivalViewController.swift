//
//  AddGoodsToArrivalViewController.swift
//  Djinaro
//
//  Created by Azat on 18.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class AddGoodsToArrivalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var goodName: UILabel!
    @IBOutlet var tableVIew: UITableView!
    @IBAction func unwindToContainerVC(segue: UIStoryboardSegue) {
        
    }
    @IBAction func addGood(_ sender: Any) {
        
        receipt = nil
        performSegue(withIdentifier: "addReceipt", sender: nil)
    }
    
    var receipt_Document_Id : Int?
    var receipts = [Receipt]()
    var addReceipt : Receipt?
    var good : Goods?
    var receipt : Receipt?
    var sizes: [Sizes]?
    var receiptController = ReceiptController()
    let defaults = UserDefaults.standard
    var token = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        token = defaults.object(forKey:"token") as? String ?? ""
        receiptController.GetSizes(token: token) { (sizes) in
            if let sizes = sizes{
                self.sizes = sizes
            }
            DispatchQueue.main.async {
                    self.tableVIew.reloadData()
            }
        }
        goodName.text = good?.name
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        tableVIew.reloadData()
    }
    /*
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("trying to reload data")
        print(receipts)
        tableVIew.reloadData()
    }*/
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addReceipt" {
            let controller = segue.destination as! AddReceiptToArrivalViewController
            controller.receipt = receipt
            controller.sizes_name = getSize(sizeId: receipt?.sizes_Id)
            controller.goods_Id = good?.id
            controller.receipt_Document_Id = receipt_Document_Id
            controller.title = good?.name
        }
    }
    
// Working with table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receipts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "GoodsInArrival"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AddGoodsToArrivalTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GoodsArrivalTableViewCell.")
        }
        if let  sizes = getSize(sizeId: receipts[indexPath.row].sizes_Id) {
            cell.goodSize.text = sizes
            
        }
        
        cell.goodCount.text = String(receipts[indexPath.row].count!)
        cell.goodPrise.text = receipts[indexPath.row].cost?.formattedAmount
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath as IndexPath)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        receipt = receipts[indexPath.row]

        performSegue(withIdentifier: "addReceipt", sender: cell)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let receipt = receipts[indexPath.row]
            receiptController.DELETEReceipt(token: token, id: String(receipt.id)) { (receipt) in
                DispatchQueue.main.async {
                    self.receipts.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    func getSize(sizeId: Int?) -> String? {
        if sizeId == nil {
            return ""
        }
        
        if let sizes = sizes {
            for i in sizes {
                if i.id == sizeId {
                    return i.name!
                }
            }
        }
        return ""
    }
    
    func appendReceipt() {
        if addReceipt != nil {
            print("trying to append")
            if receipts.count != 0 {
                receipts.append(addReceipt!)
            } else {
                receipts = [addReceipt!]
            }
        }
    }
    
    func changeReceipt() {
        if addReceipt != nil {
            print("trying to change")
            if receipts.count != 0 {
                for (n,i) in receipts.enumerated() {
                    if i.id == addReceipt!.id {
                        receipts[n] = addReceipt!
                        break
                    }
                }
            }
        }
    }
}
