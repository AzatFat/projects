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
    @IBAction func addArrival(_ sender: Any) {
      recieptDocumentId = ""

        performSegue(withIdentifier: "CRUDArrival", sender: nil)
    }
    
    var recieptController = ReceiptController()
    var recieptDocumentList = [ReceiptDocument]()
    var recieptDocumentId = ""
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
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
        
        self.addPreload(start_stop: true)
       
        recieptController.GetReceiptDocuments { (listReceipt) in
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

        super.viewDidLoad()
    }



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
