//
//  AddGoodsToArrivalViewController.swift
//  Djinaro
//
//  Created by Azat on 18.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class AddGoodsToArrivalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet var goodPrise: UITextField!
    
    @IBAction func changePrise(_ sender: Any) {
        if let prise = goodPrise.text, prise != "", good != nil {
            good?.price = Decimal(string: prise)
            addPreload(start_stop: true)
            changeGood(good: good!, message: "цена изменена")
        }
        self.view.endEditing(true)
    }
    @IBOutlet var goodLocation: UITextField!
    @IBAction func ChangeLocation(_ sender: Any) {
        if let location = goodLocation.text, location != "", good != nil {
            good?.location = location
            addPreload(start_stop: true)
            changeGood(good: good!, message: "локация поменялась")
        }
        self.view.endEditing(true)
    }
    @IBOutlet var goodName: UITextField!
    
    @IBAction func changeName(_ sender: Any) {
        if let goodName = goodName.text, goodName != "", good != nil {
            good?.name = goodName
            addPreload(start_stop: true)
            changeGood(good: good!, message: "имя изменено")
        }
        self.view.endEditing(true)
    }
    
    
    @IBOutlet var tableVIew: UITableView!
    @IBAction func unwindToContainerVC(segue: UIStoryboardSegue) {}
    
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
    var receiptController = ReceiptController(useMultiUrl: true)
    let defaults = UserDefaults.standard
    var token = ""
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
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
       // goodLocation.delegate = self
        goodName.text = good?.name
        goodLocation.text = good?.location
        goodPrise.text = good?.price?.formattedAmount
        var priceReceipt = good?.priceReceipt?.formattedAmount
        if goodPrise.text == ",00" {
            goodPrise.text = "" /*
            if priceReceipt != ",00" {
                goodPrise.text = ""
            } else {
                goodPrise.text = ""
            }*/
        }
        hideKeyboardWhenTappedAround()
    }
    override func viewDidAppear(_ animated: Bool) {
        tableVIew.reloadData()
        goodPrise.text = good?.price?.formattedAmount
    }
    /*
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("trying to reload data")
        print(receipts)
        tableVIew.reloadData()
    }*/
    
    func changeGood(good: Goods, message: String) {
        receiptController.PUTGood(token: token, post: good) { (good) in
            if let good = good {
                self.goodName.text = good.location
            }
            DispatchQueue.main.async {
                self.error(title: message)
                self.addPreload(start_stop: false)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addReceipt" {
            let controller = segue.destination as! AddReceiptToArrivalViewController
            controller.receipt = receipt
            controller.sizes_name = getSize(sizeId: receipt?.sizes_Id)
            controller.good = good
            controller.cost = good?.price
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
    
    func error(title : String) {
        addPreload(start_stop: false)
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    /*
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }*/
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
}
