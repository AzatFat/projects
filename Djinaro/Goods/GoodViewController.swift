//
//  GoodViewController.swift
//  Djinaro
//
//  Created by Azat on 15.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class GoodViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    @IBOutlet var doneOutlet: UIBarButtonItem!
    @IBAction func doneAction(_ sender: Any) {}
    
    var recieptController = ReceiptController()
    var goodsInfoViewController = GoodInfoViewController()
    
    var goodId = ""
    var good: Goods?
    var receipt_Document_Id : Int?
    var location = ""
    var name = ""
    let defaults = UserDefaults.standard
    var token = ""
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPreload(start_stop: true)
        token = defaults.object(forKey:"token") as? String ?? ""
        recieptController.GetGood(token: token, goodId: goodId) { (good) in
            if let good = good {
                self.good = good
                if let goodName = good.name, let goodLocation = good.location {
                    self.location = goodLocation
                    self.name = goodName
                    self.goodsInfoViewController.changeLocation(goodName:  self.name, goodLocation:  self.location)
                }
            }
            DispatchQueue.main.async {
                self.addPreload(start_stop: false)
                self.table.reloadData()
            }
        }
        // Do any additional setup after loading the view.
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let good = good, let avaliableSizes = good.available_sizes {
            return avaliableSizes.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // print(CostEachreceipt.inn(forKey: indexPath.row))
        let cellIdentifier = "avaliableGood"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GoodsAvailableTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GoodsAvailableTableViewCell.")
        }
        if let good = good, let avaliableSizes = good.available_sizes {
            cell.goodCount.text = String(avaliableSizes[indexPath.row].count!)
            cell.goodSize.text = String(avaliableSizes[indexPath.row].sizes!.name!)
            cell.goodPrise.text = String(avaliableSizes[indexPath.row].cost!.formattedAmount!)
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? GoodInfoViewController, segue.identifier == "goodInfo" {
            controller.goodName = location
            controller.goodLocation = name
            self.goodsInfoViewController = controller
            }
        }
    
    func addPreload(start_stop: Bool){
        if start_stop {
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.style = UIActivityIndicatorView.Style.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            //   activityIndicator.style = UIActivityIndicatorView.t
            // itemsTableViewController.shared.beginIgnoringInteractionEvents()
        } else {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                // UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
        
    }
/*
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }*/
    

}
