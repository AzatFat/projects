//
//  InventoryViewController.swift
//  Djinaro
//
//  Created by Azat on 27.11.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit



class InventoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SpyDelegate {
    
    var goodsFrontShop = [InventoryFrontShop]()
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var countLable: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFrontInventoryShop()
        tableView.backgroundColor = UIColor.clear
        view.backgroundColor = UIColor.clear
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let countItems = goodsFrontShop.count
        countLable.text = String(countItems)
        return countItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "InventoryCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? InventoryTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GoodsTableViewCell.")
        }
        
        let inventoryGood  = goodsFrontShop[indexPath.row]
        cell.inventoryGoodName.text  = inventoryGood.g_nm
        
        cell.contentView.backgroundColor = UIColor.clear
        switch inventoryGood.status {
            
        case 1:
            cell.backgroundColor = UIColor.yellow.withAlphaComponent(0.1)
        case 2:
            cell.backgroundColor = UIColor.red.withAlphaComponent(0.1)
        case 3:
            cell.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        default:
            cell.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        }
        return cell
    }
    
    func getFrontInventoryShop() {
        print("table reloaded")
        let defaults = UserDefaults.standard
        let token = defaults.object(forKey:"token") as? String ?? ""
        let receiptController = ReceiptController(useMultiUrl: true)
        receiptController.GetFrontInventoryGoods(token: token) { (frontGoods) in
            if let frontGoods = frontGoods {
               self.goodsFrontShop = frontGoods
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

    
 /*   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "GoodList" {
            let vc : QRScannerController = segue.destination as! QRScannerController
            vc.delegate = self
        }
    }*/
}



