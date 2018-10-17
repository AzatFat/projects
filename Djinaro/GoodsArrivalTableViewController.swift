//
//  GoodsArrivalTableViewController.swift
//  Djinaro
//
//  Created by Azat on 13.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class GoodsArrivalTableViewController: UITableViewController {
    
    let mockData = String("""
        [{
        "Id": 5,
        "Employees_Id": 1,
        "Name": "1122112",
        "Create_Date": "2018-10-13T12:02:03.0263+03:00",
        "Receipt_Date": "2018-10-13T00:00:00",
        "The_Date": "2018-10-13T00:00:00",
        "Employees": null,
        "ReceiptList": [
            {
            "Id": 8,
            "Receipt_Document_Id": 5,
            "Goods_Id": 875,
            "Sizes_Id": 1,
            "Cost": 2500.2,
            "Count": 2,
            "ReceiptDocument": null,
            "Sizes": null,
            "Goods": {
                "Id": 875,
                "Group_Goods_Id": 358,
                "Name": "Ремень Off White",
                "Code": "                                                  ",
                "Description": null,
                "Location": "                                                  ",
                "Vendor_Code": null,
                "GroupGoods": null
                }
            }
        ]
    },
    {
        "Id": 6,
        "Employees_Id": 1,
        "Name": "Document postuplenit",
        "Create_Date": "2018-10-13T12:02:03.0263+03:00",
        "Receipt_Date": "2018-10-13T00:00:00",
        "The_Date": "2018-10-13T00:00:00",
        "Employees": null,
        "ReceiptList": [
            {
            "Id": 8,
            "Receipt_Document_Id": 5,
            "Goods_Id": 875,
            "Sizes_Id": 1,
            "Cost": 2500.2,
            "Count": 2,
            "ReceiptDocument": null,
            "Sizes": null,
            "Goods": {
                "Id": 875,
                "Group_Goods_Id": 358,
                "Name": "Ремень Off White",
                "Code": "                                                  ",
                "Description": null,
                "Location": "                                                  ",
                "Vendor_Code": null,
                "GroupGoods": null
                }
            },
            {
            "Id": 9,
            "Receipt_Document_Id": 5,
            "Goods_Id": 875,
            "Sizes_Id": 2,
            "Cost": 2500.2,
            "Count": 2,
            "ReceiptDocument": null,
            "Sizes": null,
            "Goods": {
                "Id": 875,
                "Group_Goods_Id": 358,
                "Name": "Ремень Off White",
                "Code": "                                                  ",
                "Description": null,
                "Location": "                                                  ",
                "Vendor_Code": null,
                "GroupGoods": null
                }
            }
        ]
    },
    {
        "Id": 6,
        "Employees_Id": 1,
        "Name": "1122112",
        "Create_Date": "2018-10-12T12:02:03.0263+03:00",
        "Receipt_Date": "2018-10-13T00:00:00",
        "The_Date": "2018-10-13T00:00:00",
        "Employees": null,
        "ReceiptList": [
            {
            "Id": 8,
            "Receipt_Document_Id": 5,
            "Goods_Id": 875,
            "Sizes_Id": 1,
            "Cost": 2500.2,
            "Count": 2,
            "ReceiptDocument": null,
            "Sizes": null,
            "Goods": {
                "Id": 875,
                "Group_Goods_Id": 358,
                "Name": "Ремень Off White",
                "Code": "                                                  ",
                "Description": null,
                "Location": "                                                  ",
                "Vendor_Code": null,
                "GroupGoods": null
                }
            }
        ]
    },
    {
        "Id": 8,
        "Employees_Id": 1,
        "Name": "1122112",
        "Create_Date": "2018-10-11T12:02:03.0263+03:00",
        "Receipt_Date": "2018-10-13T00:00:00",
        "The_Date": "2018-10-13T00:00:00",
        "Employees": null,
        "ReceiptList": [
            {
            "Id": 8,
            "Receipt_Document_Id": 5,
            "Goods_Id": 875,
            "Sizes_Id": 1,
            "Cost": 2500.2,
            "Count": 2,
            "ReceiptDocument": null,
            "Sizes": null,
            "Goods": {
                "Id": 875,
                "Group_Goods_Id": 358,
                "Name": "Ремень Off White",
                "Code": "                                                  ",
                "Description": null,
                "Location": "                                                  ",
                "Vendor_Code": null,
                "GroupGoods": null
                }
            }
        ]
    },
    {
        "Id": 9,
        "Employees_Id": 1,
        "Name": "1122112",
        "Create_Date": "2018-10-11T12:02:03.0263+03:00",
        "Receipt_Date": "2018-10-13T00:00:00",
        "The_Date": "2018-10-13T00:00:00",
        "Employees": null,
        "ReceiptList": [
            {
            "Id": 8,
            "Receipt_Document_Id": 5,
            "Goods_Id": 875,
            "Sizes_Id": 1,
            "Cost": 2500.2,
            "Count": 2,
            "ReceiptDocument": null,
            "Sizes": null,
            "Goods": {
                "Id": 875,
                "Group_Goods_Id": 358,
                "Name": "Ремень Off White",
                "Code": "                                                  ",
                "Description": null,
                "Location": "                                                  ",
                "Vendor_Code": null,
                "GroupGoods": null
                }
            }
        ]
    },
    {
        "Id": 10,
        "Employees_Id": 1,
        "Name": "1122112",
        "Create_Date": "2018-10-11T12:02:03.0263+03:00",
        "Receipt_Date": "2018-10-13T00:00:00",
        "The_Date": "2018-10-13T00:00:00",
        "Employees": null,
        "ReceiptList": [
            {
            "Id": 8,
            "Receipt_Document_Id": 5,
            "Goods_Id": 875,
            "Sizes_Id": 1,
            "Cost": 2500.2,
            "Count": 2,
            "ReceiptDocument": null,
            "Sizes": null,
            "Goods": {
                "Id": 875,
                "Group_Goods_Id": 358,
                "Name": "Ремень Off White",
                "Code": "                                                  ",
                "Description": null,
                "Location": "                                                  ",
                "Vendor_Code": null,
                "GroupGoods": null
                }
            }
        ]
    }]
    """).data(using: .utf8)!
    
    @IBAction func barButtonNewGood(_ sender: Any) {}
    @IBOutlet var arrives: UINavigationItem!
    @IBOutlet var barButonNewGoodOutlet: UIBarButtonItem!
    @IBAction func addArrival(_ sender: Any) {
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
                
                print(self.recieptDocumentList)
            } else {
                print("GetReceiptDocuments get fail")
                let data = self.mockData

                    do {
                        let decoder = JSONDecoder()
                        let product = try decoder.decode([ReceiptDocument].self, from: data)
                        self.recieptDocumentList = product
                    } catch let error {
                        print("error in getting ReceiptDocuments")
                        print(error)
                    }
            }
            DispatchQueue.main.async {
                self.objectArray = self.createSectionsForObject(recieptDocumentList: self.recieptDocumentList)
                print(self.objectArray)
                self.tableView.reloadData()
                self.addPreload(start_stop: false)
            }
        }

        
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
        
        if let receiptListCostCount = receipt.receiptList {
            var cost: Decimal = 0
            for i in receiptListCostCount {
                if let receiptCost = i.cost {
                    cost += receiptCost
                }
            }
            cell.arrivalPrise.text = cost.formattedAmount
        }
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return objectArray[section].sectionName
    }
    
    
  /*  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }*/
    
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
