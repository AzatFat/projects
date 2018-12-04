//
//  GoodsArrivalTableViewController.swift
//  Djinaro
//
//  Created by Azat on 13.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class GoodsArrivalTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet var searchButton: UISearchBar!
    @IBAction func barButtonNewGood(_ sender: Any) {}
    @IBOutlet var arrives: UINavigationItem!
    @IBOutlet var barButonNewGoodOutlet: UIBarButtonItem!
    @IBAction func addArrival(_ sender: Any) {
    }
    let searchController = UISearchController(searchResultsController: nil)
    var recieptController = ReceiptController(useMultiUrl: true)
    var recieptDocumentList = [ReceiptDocument]()
    var recieptDocumentId = ""
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let defaults = UserDefaults.standard
    var token = ""
    
    
    struct Objects {
        
        var sectionName : String!
        var sectionObjects : [ReceiptDocument]!
    }
    
    var objectArray = [Objects]()
    
    func createSectionsForObject(recieptDocumentList: [ReceiptDocument]) -> [Objects] {
        var objectArray = [Objects]()
        var objectDictionary: Dictionary = [String: [ReceiptDocument]]()
        
        for i in recieptDocumentList {
            if let date = i.create_Date?.components(separatedBy: "T") {
                if  objectDictionary[date[0]] != nil {
                    objectDictionary[date[0]]!.append(i)
                } else {
                    objectDictionary[date[0]] = [i]
                }
            }
        }
        
        for (key, value) in objectDictionary {
            objectArray.append(Objects(sectionName: key, sectionObjects: value))
        }
        
        objectArray.sort(by: {$0.sectionName > $1.sectionName})
        return objectArray
    }
    
    func getReceiptDocuments() {
        print("token when function work \(token)")
        recieptController.GetReceiptDocuments(token: token) { (listReceipt) in
            if let listReceipt = listReceipt {
                print("GetReceiptDocuments get succes")
                self.recieptDocumentList = listReceipt
            }
            DispatchQueue.main.async {
                self.objectArray = self.createSectionsForObject(recieptDocumentList:
                    self.recieptDocumentList)
                self.tableView.reloadData()
                self.addPreload(start_stop: false)
            }
        }
    }
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CRUDArrival" {
            let controller = segue.destination as! ArrivalInfoViewController
            controller.receiptId = recieptDocumentId
        }
    }
    
    override func viewDidLoad() {
        token = defaults.object(forKey:"token") as? String ?? ""
        print("token when load view \(token)")
        self.addPreload(start_stop: true)
        getReceiptDocuments()
        super.viewDidLoad()
        searchButton.delegate = self
        searchController.searchBar.delegate = self

    }

    override func viewDidAppear(_ animated: Bool) {
        token = defaults.object(forKey:"token") as? String ?? ""
        self.addPreload(start_stop: true)
        getReceiptDocuments()
    }
    ///// Search bar controller
    
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
        getReceiptDocuments()
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let scopeString = searchBar.scopeButtonTitles? [searchBar.selectedScopeButtonIndex] else {return }
        searchBar.showsCancelButton = false;
        searchBar.showsScopeBar = false
        searchBar.sizeToFit()
        
        self.addPreload(start_stop: true)
        getReceiptDocuments()
        searchBar.resignFirstResponder()
    }
    /////
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return objectArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return objectArray[section].sectionObjects.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "arrivalCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GoodsArrivalTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GoodsArrivalTableViewCell.")
        }
        
        let receipt = objectArray[indexPath.section].sectionObjects[indexPath.row]
        
        
        if let arrivalName = receipt.name{
            cell.arrivalName.text = String(arrivalName)
        }
        
        if let receiptListCostCount = receipt.totalCost {
            cell.arrivalPrise.text = receiptListCostCount.formattedAmount
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return objectArray[section].sectionName
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath as IndexPath)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let receipt = objectArray[indexPath.section].sectionObjects[indexPath.row]
        recieptDocumentId = String(receipt.id)
        
        performSegue(withIdentifier: "CRUDArrival", sender: cell)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let receiptDocument = objectArray[indexPath.section].sectionObjects[indexPath.row]
            // Delete the row from the data source
            recieptController.DELETEReceiptDocument(token: token, id: String(receiptDocument.id)) { (receiptDocument) in
                DispatchQueue.main.async {
                    self.objectArray[indexPath.section].sectionObjects.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
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
