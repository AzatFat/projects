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

    @IBAction func addGood(_ sender: Any) {
        
        receipt = nil
        performSegue(withIdentifier: "addReceipt", sender: nil)
    }
    
    var receipt_Document_Id : Int?
    var receipts = [Receipt]()
    var good : Goods?
    var receipt : Receipt?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableVIew.reloadData()
        goodName.text = good?.name
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        tableVIew.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addReceipt" {
            let controller = segue.destination as! AddReceiptToArrivalViewController
            controller.receipt = receipt
            controller.goods_Id = good?.id
            controller.receipt_Document_Id = receipt_Document_Id
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
    
    
}
