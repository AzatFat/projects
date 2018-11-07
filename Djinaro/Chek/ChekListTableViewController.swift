//
//  ChekListTableViewController.swift
//  Djinaro
//
//  Created by Azat on 05.11.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class ChekListTableViewController: UITableViewController {
    //Tokens and user unfo
    let defaults = UserDefaults.standard
    var token = ""
    var userId = ""
    // Preloader
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    // URL
    var recieptController = ReceiptController()
    
    var checkList = [Check]()
    var checkTotalCostList = [String]()
    
    var check: Check?
    var checkTotalCost = ""
    
    var lastShiftId: Int?
    
    @IBAction func addNewCheck(_ sender: Any) {
        addNewCheck()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPreload(start_stop: true)
       // self.title = "Мои открытые чеки"
        token = defaults.object(forKey:"token") as? String ?? ""
        userId = defaults.object(forKey:"userId") as? String ?? ""
        recieptController.GetCheckList(userId: userId, token: token) { (chekList) in
            if let chekList = chekList {
                self.checkList = chekList
            }
            DispatchQueue.main.async {
                self.addPreload(start_stop: false)
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        recieptController.GetCheckList(userId: userId,token: token) { (chekList) in
            if let chekList = chekList {
                self.checkList = chekList
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return checkList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "chekListCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CheckListTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GoodsTableViewCell.")
        }
        let check = checkList[indexPath.row]
        if let date  = check.create_Date?.components(separatedBy: "T")[1] {
            let time = date.components(separatedBy: ".")[0]
            cell.Time.text = time
        }
        
        if let checkRecordList = check.checkRecordList {
            var checkTotalCost: Decimal = 0
            for checkRecord in checkRecordList {
                checkTotalCost += checkRecord.total_Cost ?? 0
            }
            cell.Cost.text = checkTotalCost.formattedAmount
            checkTotalCostList.append(checkTotalCost.formattedAmount ?? "")
        }
        cell.CheckId.text = String(check.id)
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cell = tableView.cellForRow(at: indexPath as IndexPath)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        check = checkList[indexPath.row]
        checkTotalCost = checkTotalCostList[indexPath.row]
        performSegue(withIdentifier: "CheckInfo", sender: nil)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let check = checkList[indexPath.row]
            recieptController.DELETECheck(token: token, id: String(check.id)) { (receipt) in
                DispatchQueue.main.async {
                    self.checkList.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
            // Delete the row from the data source
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CheckInfo" {
            let controller = segue.destination as! CheckRecordViewController
            controller.check = check
            controller.checkId = check?.id
            controller.totalCost = checkTotalCost
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
    
    func addNewCheck() {
        recieptController.GetLastShift(token: token) { (shift) in
            if let shift = shift {
                self.lastShiftId = shift.id
                let newCheck = Check.init(id: 1, customer_Id: 0, employees_Id: Int(self.userId), shift_Id: self.lastShiftId, check_Type_Id: 1, payment_Type_Id: nil, cash: nil, card: nil, is_Deferred: nil, is_Cancelled: nil, create_Date: nil, the_Date: nil, customer: nil, checkType: nil, employees: nil, shift: nil, checkRecordList: nil, payment: nil)
                self.recieptController.POSTCheck(token: self.token, post: newCheck) { (check) in
                    if let check = check {
                        self.check = check
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "CheckInfo", sender: nil)
                        }
                    }
                }
            }
        }
    }
}
