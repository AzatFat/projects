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
    
    @IBAction func unwindToGoodsTableVC(segue: UIStoryboardSegue) {
        
    }

    @IBAction func createGoods(_ sender: Any) {
        performSegue(withIdentifier: "createGoods", sender: nil)
    }
    
    
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
        searchBar.setImage(UIImage(named: "microphone.png"), for: .bookmark, state: .normal)
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
        
        if segue.identifier == "createGood" {
            let controller = segue.destination as! GoodChangeViewController
        }
    }
    
    func getGoods () {
        /*
        recieptController.GetGoods(token: token) { (listGoods) in
            if let listGoods = listGoods {
                print("listReceipt get succes")
                self.goods = listGoods
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.addPreload(start_stop:  false)
            }
        }*/
        var is_remains = ""
        var is_archive = ""
        /*
        if receipt_Document_Id == nil {
            is_remains = "true"
            is_archive = "false"
        }*/
        recieptController.GetGoodsSearch(token: token, search: "", sizes: "", is_remains: is_remains,is_archive: is_archive) { (listGoods) in
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
    
    func searchGoods (search: String, sizes: String) {
        print("trying search Good")
        var is_remains = ""
        var is_archive = ""
        /*
        if receipt_Document_Id == nil {
            is_remains = "true"
            is_archive = "false"
        }*/
        
        recieptController.GetGoodsSearch(token: token, search: search, sizes: sizes, is_remains: is_remains,is_archive: is_archive) { (listGoods) in
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
    ///Search bar controller
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true;
        searchBar.showsScopeBar = true
        searchBar.scopeButtonTitles = ["Наименование", "Размер"]
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
        guard let scopeString = searchBar.scopeButtonTitles? [searchBar.selectedScopeButtonIndex] else {return }
        searchBar.showsCancelButton = false;
        searchBar.showsScopeBar = false
        searchBar.sizeToFit()
        
        self.addPreload(start_stop: true)
        if searchBar.text != "" {
            if scopeString == "Размер"{
                let searchList_1 = searchBar.text!.replacingOccurrences(of: ", ", with: ",")
                let searchList = searchList_1.replacingOccurrences(of: " ", with: ",")
                searchGoods(search: "", sizes: searchList)
            } else {
                searchGoods(search: searchBar.text!, sizes: "")
            }
        } else {
            getGoods()
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        
        print("bar button clicked")
        performSegue(withIdentifier: "voiceSearch", sender: nil)
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
}

