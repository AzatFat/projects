//
//  ItemsInfoTableViewController.swift
//  Djinaro
//
//  Created by Azat on 23.09.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit


class ItemsInfoTableViewController: UITableViewController {

    
    var goodsController = GoodsController()
    var id: String!
    var good:  GoodsInfo?
    var location = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        goodsController.fetchGood(goodsNamesIds: id)
        { (goodInfo) in
            if let goodInfo = goodInfo {
                
                self.good = goodInfo
                
                if let goodLocation = self.good?.location {
                    self.location = goodLocation
                }
                
            } else {
                print("error in getting GoodInfo")
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
               // self.performSegue(withIdentifier: "location", sender: nil)
            }
        }
        
        
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "location" {
            if let controller = segue.destination as? LocationImageViewController {
                controller.contentString = location
            }
        }
    }
    
    */
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if good != nil {
            
            if good!.available_sizes.count == 0 {
                return 1
            } else {
                return good!.available_sizes.count
            }
            
        } else {
            return 1
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GoodsInfoTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        if let  sizes = good?.available_sizes.count, sizes > 0 {
            
            if let count = good?.available_sizes[indexPath.row].count {
                cell.count.text = String(count)
            } else {
                print("count is unavalible")
            
            }
            
            if let cost = good?.available_sizes[indexPath.row].cost {
                cell.prise.text = String(cost)
            }else {
                print("prise is unavalible")
               
            }
            
            if let size = good?.available_sizes[indexPath.row].size {
                 cell.size.text = String(size)
            }else {
                print("size is unavalible")
               
            }
            
            print(sizes)
            
            
            return cell
        } else {
            
            cell.count.text = "Нет в наличии"
            cell.prise.text = "?"
            cell.size.text = "?"
            
            return cell
        }
        
        
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
