//
//  NewReceiptDocumentViewController.swift
//  Djinaro
//
//  Created by Azat on 21.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class NewReceiptDocumentViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var errorLable: UILabel!
    @IBOutlet var addNewReceiptDocument: UIButton!
    @IBOutlet var NumberReceiptDocument: UITextField!
    var receiptDocument: ReceiptDocument?
    var receiptController = ReceiptController()
    let defaults = UserDefaults.standard
    var token = ""
    
    @IBAction func AddReceiptDocumentAction(_ sender: Any) {
        if NumberReceiptDocument.text != "" {
            let POSTreceiptDocument = ReceiptDocument.init(id: 1, employees_Id: 1, name: NumberReceiptDocument.text, create_Date: nil, receipt_Date: nil, the_Date: nil, employees: nil, receiptList: nil, totalCost: nil)
            
            receiptController.POSTReceiptDocument(token: token, post: POSTreceiptDocument) { (receiptDocument) in
                if let receiptDocument = receiptDocument {
                    self.receiptDocument = receiptDocument
                }
                if receiptDocument != nil {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "AddReceiptDocument", sender: nil)
                    }
                } else {
                    self.errorLable.text = "не удалось создать поступление"
                }
            }
        }
    }
    
    override func viewDidLoad() {
        NumberReceiptDocument.delegate = self
        token = defaults.object(forKey:"token") as? String ?? ""
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        errorLable.text = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddReceiptDocument"{
            let controller = segue.destination as! ArrivalInfoViewController
            controller.receiptId = String(receiptDocument!.id)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    

}
