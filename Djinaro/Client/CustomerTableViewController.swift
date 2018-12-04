//
//  CustomerTableViewController.swift
//  Djinaro
//
//  Created by Azat on 06.11.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class CustomerTableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet var searchBar: UISearchBar!
    
    @IBAction func addCustomer(_ sender: Any) {
        performSegue(withIdentifier: "CreateClient", sender: nil)
    }
    
    var checkRecord: CheckRecord?
    var recieptController = ReceiptController(useMultiUrl: true)
    var customerList = [Customer]()
    var customer : Customer?
    let defaults = UserDefaults.standard
    var token = ""
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        token = defaults.object(forKey:"token") as? String ?? ""
        self.addPreload(start_stop: true)
        GetCustomerList()
        searchBar.delegate = self
    }

    
    override func viewDidAppear(_ animated: Bool) {
        self.addPreload(start_stop: true)
        GetCustomerList()
    }
    func GetCustomerList(){
        recieptController.GetCustomerList(token: token) { (customerList) in
            if let customerList = customerList {
                self.customerList = customerList
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.addPreload(start_stop: false)
            }
        }
    }
    
    func searchCustomer (search: String) {
        print("trying search for Customer")
        if search != "" {
            recieptController.GetCustomerSearch(token: token, search: search) { (listCustomer) in
                if let listCustomer = listCustomer {
                    print("listReceipt get succes")
                    self.customerList = listCustomer
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.addPreload(start_stop:  false)
                }
            }
        }
    }
    // add customer co Check
    
    func addCustomerToCheck(checkId: String, customerId: String) {
        recieptController.POSTCustomerToCheck(token: token, checkId: checkId, customerId: customerId) { (check) in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "addCustomerToCheck", sender: self)
            }
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CustomerCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CustomerTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GoodsTableViewCell.")
        }
        // Configure the cell...
       
        let customerName = customerList[indexPath.row].name ?? " "
        let customerMiddle = customerList[indexPath.row].middle_Name ?? " "
        let customerSurname = customerList[indexPath.row].surname ?? " "
        let customerPhone = customerList[indexPath.row].phone ?? " "
        let customerEmail = customerList[indexPath.row].email ?? " "
        
        cell.customerName.text = customerName + " " + customerMiddle + " " + customerSurname
        cell.customerEmail.text = customerEmail
        cell.customerPhone.text = customerPhone

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cell = tableView.cellForRow(at: indexPath as IndexPath)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        if let checkRecord = checkRecord, let checkId = checkRecord.check_Id {
            let customerId = customerList[indexPath.row].id
            addCustomerToCheck(checkId: String(checkId), customerId: String(customerId))
        } 
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 77.5
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let ViewCustomer = UITableViewRowAction(style: .normal, title: "Редактировать") { (action, indexPath) in
            self.customer = self.customerList[indexPath.row]
            self.performSegue(withIdentifier: "CreateClient", sender: nil)
        }
        ViewCustomer.backgroundColor = UIColor.blue
        
        return [ViewCustomer]
    }
    
    
    
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
        GetCustomerList()
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(" search Click")
        
        searchBar.showsCancelButton = false;
        searchBar.showsScopeBar = false
        searchBar.sizeToFit()
        
        self.addPreload(start_stop: true)
        if searchBar.text != "" {
            searchCustomer(search: searchBar.text!)
        }
        searchBar.resignFirstResponder()
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
    
    // addCustomerToCheck
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCustomerToCheck" {
            let controller = segue.destination as! CheckRecordViewController
            controller.checkId = checkRecord?.check_Id
        }
        
        if segue.identifier == "CreateClient" {
            let controller = segue.destination as! CustomerInfoViewController
            controller.customer = customer
            controller.checkRecord = checkRecord
        }
    }
}
