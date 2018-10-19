//
//  GoodViewController.swift
//  Djinaro
//
//  Created by Azat on 15.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class GoodViewController: UIViewController {
    
    var recieptController = ReceiptController()
    var goodId = ""
    var good: Goods?
    var receipt_Document_Id : Int?
    
    @IBOutlet var doneOutlet: UIBarButtonItem!
    @IBOutlet var GoodName: UITextField!
    @IBOutlet var GoodPrise: UITextField!
    @IBOutlet var GoodLocation: UITextField!
    @IBOutlet var GoodOverview: UITextView!
    
    @IBAction func doneAction(_ sender: Any) {
        
        
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        GoodOverview.layer.borderColor = borderColor.cgColor
        GoodOverview.layer.cornerRadius = 5.0
        
        recieptController.GetGood(goodId: goodId) { (good) in
            if let good = good {
                self.good = good

            }
            DispatchQueue.main.async {
                self.GoodName.text = self.good?.name
                self.GoodLocation.text = self.good?.location
                self.GoodOverview.text = self.good?.description
            }
        }
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
