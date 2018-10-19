//
//  AddReceiptToArrivalViewController.swift
//  Djinaro
//
//  Created by Azat on 19.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class AddReceiptToArrivalViewController: UIViewController {

    let receiptController = ReceiptController()
    @IBOutlet var goodSIze: UITextField!
    @IBOutlet var goodCount: UITextField!
    @IBOutlet var goodPrise: UITextField!
    @IBOutlet var addChangeReceipt: UIButton!
    @IBAction func addChangeReceiptAction(_ sender: Any) {
        

        sizes_Id = Int(goodSIze.text ?? "111")
        cost = Decimal(string: goodPrise.text ?? "10.1")
        count = Int(goodCount.text ?? "3")
        
        
        let PostReceipt = Receipt.init(id: 1, receipt_Document_Id: receipt_Document_Id, goods_Id: goods_Id, sizes_Id: sizes_Id, cost: cost, count: count, receiptDocument: nil, goods: nil, sizes: nil)
        
        receiptController.POSTReceipt(post: PostReceipt) { (receipt) in
            if let receipt = receipt {
                self.receipt = receipt
                print("congratulations your first post is created")
                print(self.receipt)
            } else {
                print("problem to Post")
            }
        }
        
    }
    
    var receipt : Receipt?

    var receipt_Document_Id: Int?
    var goods_Id: Int?
    var sizes_Id: Int?
    var cost: Decimal?
    var count: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let receipt = receipt {
            goodSIze.text = String(receipt.sizes_Id!)
            goodCount.text = String(receipt.count!)
            goodPrise.text = receipt.cost!.formattedAmount
        }

        
        print("receipt_Document_Id: \(receipt_Document_Id)")
        print("goods_Id: \(goods_Id)")
        print("sizes_Id")
        print("receipt \(receipt)")
        
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
