//
//  GoodsArrivalTableViewController.swift
//  Djinaro
//
//  Created by Azat on 13.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class GoodsArrivalTableViewController: UITableViewController {
    
    @IBAction func barButtonNewGood(_ sender: Any) {}
    @IBOutlet var arrives: UINavigationItem!
    @IBOutlet var barButonNewGoodOutlet: UIBarButtonItem!
    @IBAction func addArrival(_ sender: Any) {}
    
    var recieptController = ReceiptController()
    var recieptList = [Receipt]()
    override func viewDidLoad() {
        
       
        recieptController.GetReceipts { (listReceipt) in
            if let listReceipt = listReceipt {
                print("listReceipt get succes")
                self.recieptList = listReceipt
                print(self.recieptList)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
               // self.addPreload(start_stop: false)
            }
        }
        /*
        goodsController.fetchSearhGoods(search: "") { (listGoods) in
            if let listGoods = listGoods {
                print("request List success searchBarCancelButtonClicked")
                self.goodList = listGoods
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.addPreload(start_stop: false)
            }
        }*/
        
        
     //   barButonNewGoodOutlet.
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }



    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recieptList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "arrivalCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GoodsArrivalTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GoodsArrivalTableViewCell.")
        }
        let receipt = recieptList[indexPath.row]
        if let arrivaltDate = receipt.receiptDocument?.create_Date {
                cell.arrivalDate.text = String(arrivaltDate)
        }
        
        if let arrivalName = receipt.goods?.name{
            cell.arrivalName.text = String(arrivalName)
        }
        
        if let arrivalPrise = receipt.cost {
            
            cell.arrivalPrise.text = arrivalPrise.formattedAmount
        }
        
        // Configure the cell...

        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Decimal {
    var formattedAmount: String? {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber)
    }
}
