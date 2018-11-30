//
//  CustomerInfoViewController.swift
//  Djinaro
//
//  Created by Azat on 10.11.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class CustomerInfoViewController: UIViewController, UITextFieldDelegate {

    
    var customer: Customer?
    var checkRecord: CheckRecord?
    private var datePicker: UIDatePicker!
    
    @IBOutlet var CustomerName: UITextField!
    
    @IBOutlet var CustomerMiddle: UITextField!
    
    @IBOutlet var CustomerSecondName: UITextField!
    
    @IBOutlet var CustomerEmail: UITextField!
    
    @IBOutlet var CustomerPhone: UITextField!
    
    @IBOutlet var CustomerDateBirth: UITextField!
    
    @IBOutlet var CreateCustomer: UIButton!
    
    @IBAction func CreateCustomerAction(_ sender: Any) {
        
        guard let name = CustomerName.text, name != "" else {
            error(title: "Имя обязательное поле")
            return
        }
        
        let customerSecondName = CustomerSecondName.text
        let middle_Name = CustomerMiddle.text
        let customerBirthDate = CustomerDateBirth.text ?? "" + "T00:00:00.0263+03:00"

        let phone = CustomerPhone.text
        let email = CustomerEmail.text
        print("customerBirthDate is \(customerBirthDate)")
        print("customer is \(customer)")
        if customer != nil {
            let putCustomer = Customer.init(id: customer!.id, surname: customerSecondName, name: name, middle_Name: middle_Name, birth_Date: customerBirthDate, phone: phone, email: email, vK_Link: nil, iNSTA_Link: nil, is_Archive: nil)
            PUTCustomer(customer: putCustomer)
            
        } else {
            let postCustomer = Customer.init(id: 1, surname: customerSecondName, name: name, middle_Name: middle_Name, birth_Date: customerBirthDate, phone: phone, email: email, vK_Link: nil, iNSTA_Link: nil, is_Archive: nil)
            print(postCustomer)
            POSTCustomer(customer: postCustomer)
        }
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.CustomerName.delegate = self
        self.CustomerMiddle.delegate = self
        self.CustomerSecondName.delegate = self
        self.CustomerPhone.delegate = self
        self.CustomerEmail.delegate = self
        
        if customer != nil {
            CustomerName.text = customer?.name
            CustomerMiddle.text = customer?.middle_Name
            CustomerSecondName.text = customer?.surname
            CustomerEmail.text = customer?.email
            CustomerPhone.text = customer?.phone
            CustomerDateBirth.text = customer?.birth_Date?.components(separatedBy: "T")[0]
            CreateCustomer.setTitle("Редактировать клиента", for: .normal)
        }
        
        hideKeyboardWhenTappedAround() 
        
        let theDateToolBar = UIToolbar().ToolbarPiker(mySelect: #selector(CustomerInfoViewController.receiptDatedismissPicker), clear: #selector(CustomerInfoViewController.clearTheDatedismissPicker))
        CustomerDateBirth.inputAccessoryView = theDateToolBar
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        CustomerDateBirth.inputView = datePicker
        datePicker?.addTarget(self, action: #selector(ArrivalInfoViewController.dateChanged(dateChanged:)), for: .valueChanged)
        
        // Do any additional setup after loading the view.
    }
    

    
    @objc func dateChanged(dateChanged: UIDatePicker) {
        let dateFormatted = DateFormatter()
        dateFormatted.dateFormat = "yyyy-MM-dd"
        CustomerDateBirth.text = dateFormatted.string(from: datePicker.date)
    }
    
    @objc func receiptDatedismissPicker() {
        let dateFormatted = DateFormatter()
        dateFormatted.dateFormat = "yyyy-MM-dd"
        CustomerDateBirth.text = dateFormatted.string(from: datePicker.date)
        //recieptDocument?.receipt_Date = dateFormatted.string(from: datePicker.date) + "T00:00:00.0263+03:00"
        //PUTReceiptDocument()
        view.endEditing(true)
    }
    
    @objc func clearTheDatedismissPicker() {
        CustomerDateBirth.text = ""
        //recieptDocument?.the_Date = nil
        //PUTReceiptDocument()
        view.endEditing(true)
    }
    
    
    func POSTCustomer(customer: Customer) {
        let receiptController = ReceiptController()
        let defaults = UserDefaults.standard
        let token = defaults.object(forKey:"token") as? String ?? ""
        receiptController.POSTCustomer(token: token, post: customer) { (customerId) in
            if let customerId = customerId, let checkRecord = self.checkRecord?.check_Id {
                DispatchQueue.main.async {
                    self.addCustomerToCheck(checkId: String(checkRecord), customerId: customerId)
                }
            }
        }
    }
    
    func PUTCustomer(customer: Customer) {
        let receiptController = ReceiptController()
        let defaults = UserDefaults.standard
        let token = defaults.object(forKey:"token") as? String ?? ""
        receiptController.PUTCustomer(token: token, post: customer) { (customer) in
            DispatchQueue.main.async {
                self.error(title: "Клиент отредактирован")
            }
        }
    }
    
    func addCustomerToCheck(checkId: String, customerId: String) {
        let recieptController = ReceiptController()
        let defaults = UserDefaults.standard
        let token = defaults.object(forKey:"token") as? String ?? ""
        recieptController.POSTCustomerToCheck(token: token, checkId: checkId, customerId: customerId) { (check) in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "addCustomerToCheck", sender: self)
            }
        }
    }
    
    func error(title : String) {
        //self.addPreload(start_stop: false)
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}
