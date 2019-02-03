//
//  PayChekViewController.swift
//  Djinaro
//
//  Created by Azat on 02.02.2019.
//  Copyright © 2019 Azat. All rights reserved.
//

import UIKit

class PayChekViewController: UIViewController {

    var check: Check?
    
    @IBOutlet var payType: UISegmentedControl!
    @IBOutlet var checkChange: UILabel!
    @IBOutlet var payCheckBtnOutlet: UIButton!
    
    @IBAction func payCheckBTN(_ sender: Any) {
        
    }
    
    @IBOutlet var checkTotalCost: UILabel!
    
    @IBAction func PayTypeAction(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBOutlet var cardSum: UITextField!
    
    @IBAction func cardPaymentCahnge(_ sender: Any) {
    }
    @IBAction func cashPymentChange(_ sender: Any) {
    }
    @IBOutlet var cashSum: UITextField!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
