//
//  GoodsTableViewController.swift
//  Djinaro
//
//  Created by Azat on 14.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class GoodsTableViewController: UITableViewController, UISearchBarDelegate {

    var recieptController = ReceiptController()
    
    var goods = [Goods]()
    var goodId = ""
    var good: Goods?
    var receipts : [Receipt]?
    var segue = "goodInfo"
    var receipt_Document_Id : Int?
    var groupReceiptsList = [GroupReceipts]()
    let defaults = UserDefaults.standard
    var token = ""
    var checkRecord: CheckRecord?
    
    @IBOutlet var searchBar: UISearchBar!
    
   // let searchController = UISearchController(searchResultsController: nil)
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func addPreload(start_stop: Bool){
        if start_stop {
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.style = UIActivityIndicatorView.Style.gray
            tableView.addSubview(activityIndicator)
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        token = defaults.object(forKey:"token") as? String ?? ""
        self.addPreload(start_stop: true)
        getGoods()
        searchBar.delegate = self
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return goods.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "goodsCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GoodsTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GoodsTableViewCell.")
        }
        // Configure the cell...
        let good  = goods[indexPath.row]
        if let goodName = good.name {
            cell.goodName.text  = goodName
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath as IndexPath)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        goodId = String(goods[indexPath.row].id)
        good = goods[indexPath.row]
        receipts = searchExistGoodInArrival(good: good)
        performSegue(withIdentifier: segue, sender: cell)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goodInfo" {
            let controller = segue.destination as! GoodViewController
            controller.goodId = goodId
            controller.checkRecord = checkRecord
        }
        
        if segue.identifier == "addGoodToArrival" {
            let controller = segue.destination as! AddGoodsToArrivalViewController
            controller.good = good
            if let receipts = receipts {
                controller.receipts = receipts
            }
            controller.receipt_Document_Id = receipt_Document_Id
        }
    }
    
    func getGoods () {
        recieptController.GetGoods(token: token) { (listGoods) in
            if let listGoods = listGoods {
                print("listReceipt get succes")
                self.goods = listGoods
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.addPreload(start_stop:  false)
            }
        }
    }
    
    func searchGoods (search: String) {
        print("trying search Good")
        if search != "" {
            recieptController.GetGoodsSearch(token: token, search: search) { (listGoods) in
                if let listGoods = listGoods {
                    print("listReceipt get succes")
                    self.goods = listGoods
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.addPreload(start_stop:  false)
                }
            }
        }
    }
    ///Search bar controller
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true;
        searchBar.showsScopeBar = true
        searchBar.sizeToFit()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = nil
        searchBar.showsCancelButton = false;
        searchBar.showsScopeBar = false
        searchBar.sizeToFit()
        
        addPreload(start_stop: true)
        getGoods()
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(" search Click")

        searchBar.showsCancelButton = false;
        searchBar.showsScopeBar = false
        searchBar.sizeToFit()
        
        self.addPreload(start_stop: true)
        if searchBar.text != "" {
            searchGoods(search: searchBar.text!)
        }
        searchBar.resignFirstResponder()
    }
    //////

    
    func searchExistGoodInArrival(good: Goods?) -> [Receipt]? {
        print("trying to found")
        if groupReceiptsList.count >= 1  {
            for i in groupReceiptsList{
                if i.objectGood.id == good?.id {
                    receipts = i.objectRaw
                    return receipts
                }
            }
        }
        return nil
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
