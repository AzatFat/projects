//
//  AddGoodsToArrivalViewController.swift
//  Djinaro
//
//  Created by Azat on 18.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class AddGoodsToArrivalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receipts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "GoodsInArrival"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AddGoodsToArrivalTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GoodsArrivalTableViewCell.")
        }
        cell.goodCount.text = String(receipts[indexPath.row].count)
        cell.goodPrise.text = receipts[indexPath.row].cost?.formattedAmount
       // cell.goodSize = receipts[indexPath.row].
        
        
        // print(CostEachreceipt.inn(forKey: indexPath.row))
        return cell
    }
    
    
    
    
    
    @IBOutlet var goodName: UITextField!
    @IBOutlet var tableVIew: UITableView!
    
    var receipts = [Receipt]()
    var goodname = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        tableVIew.reloadData()
        goodName.text = goodname
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
