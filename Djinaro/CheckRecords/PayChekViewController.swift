//
//  PayChekViewController.swift
//  Djinaro
//
//  Created by Azat on 02.02.2019.
//  Copyright © 2019 Azat. All rights reserved.
//

import UIKit

class PayChekViewController: UIViewController {


    @IBOutlet var cashImage: UIImageView!
    @IBOutlet var cardImage: UIImageView!
    @IBOutlet var payType: UISegmentedControl!
    @IBOutlet var checkChange: UILabel!
    @IBOutlet var payCheckBtnOutlet: UIButton!
    @IBOutlet var checkTotalCost: UILabel!
    
    @IBOutlet var cardSum: UITextField! {
        didSet {
            cardSum?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForCheckChange)))
        }
    }
    
    @IBOutlet var cashSum: UITextField!{
        didSet {
            cashSum?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForCashSum)))
        }
    }
    
    
    @IBAction func payCheckBTN(_ sender: Any) {
        let alert = UIAlertController(title: "Выберите принтер", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "принтер 1", style: .default, handler: { action in
            self.payCheck(printer: 1)
            
        }))
        
        alert.addAction(UIAlertAction(title: "принтер 2", style: .default, handler: { action in
            self.payCheck(printer: 2)
            
        }))
        
        alert.addAction(UIAlertAction(title: "принтер 3", style: .default, handler: { action in
            self.payCheck(printer: 3)
            
        }))
        self.present(alert, animated: true,completion : nil)
        
    }
    
    @IBAction func PayTypeAction(_ sender: Any) {
        cashSumNum = 0.0
        cardSumNum = 0.0
        cashSum.text = ""
        cardSum.text = ""
        checkChange.text = " "
        
        
        switch payType.selectedSegmentIndex {
        case 0:
            cardSum.isHidden = true
            cardImage.isHidden = true
            cashSum.isHidden = false
            cashImage.isHidden = false
            check?.payment_Type_Id = 1
        case 1:
            cardSumNum = totalCost ?? 0.0
            cardSum.isHidden = true
            cardImage.isHidden = true
            cashSum.isHidden = true
            cashImage.isHidden = true
            check?.payment_Type_Id = 2
            
        case 2:
            cardSum.isHidden = false
            cashSum.isHidden = false
            cashImage.isHidden = false
            cardImage.isHidden = false
            check?.payment_Type_Id = 3
            
        default:
            break
        }
    }
    
    var check: Check?
    var totalCost: Decimal?
    var cardSumNum: Decimal = 0
    var cashSumNum: Decimal = 0
    
    var recieptController = ReceiptController(useMultiUrl: true)
    let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
    var token = ""
    var userId = ""
    
    // Preloader
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func countChange() {
        
        cardSumNum = Decimal(string: cardSum.text?.replacingOccurrences(of: ",", with: ".") ?? "0") ?? 0.0
        cashSumNum = Decimal(string: cashSum.text?.replacingOccurrences(of: ",", with: ".") ?? "0") ?? 0.0
        
        if let totalCost = totalCost {
            if cardSumNum +  cashSumNum > totalCost {
                let count = cardSumNum + cashSumNum - totalCost
                print(count)
                checkChange.text = count.formattedAmount ?? ""
            }
        }
    }
    
    @objc func doneButtonTappedForCheckChange() {
        countChange()
        cardSum.resignFirstResponder()
    }
    
    @objc func doneButtonTappedForCashSum() {
        countChange()
        cashSum.resignFirstResponder()
    }

    func payCheck(printer: Int) {
        if let check = check, let totalCost = totalCost, cashSumNum + cardSumNum >= totalCost, cardSumNum <= totalCost {
            addPreload(start_stop: true)
            let printCheck = CheckPrint.init(id: check.id, cash: totalCost - cardSumNum, card: cardSumNum, printer: printer)
            let putCheck = Check.init(id: check.id, customer_Id: check.customer_Id, employees_Id: check.employees_Id, shift_Id: check.shift_Id, check_Type_Id: check.check_Type_Id, payment_Type_Id: check.payment_Type_Id, cash: nil, card: nil, is_Deferred: nil, is_Cancelled: nil, create_Date: nil, the_Date: nil, customer: nil, checkType: nil, employees: nil, shift: nil, checkRecordList: nil, payment: nil, totalCost: nil)
            
            recieptController.PUTChek(token: token, post: putCheck) { (answerPutChek) in

                if let answerPutChek = answerPutChek, answerPutChek == "done" {
                    
                    self.recieptController.POSTCheckPrint(token: self.token, post: printCheck) { (answer) in
                        if let answer = answer, answer == "done" {
                            DispatchQueue.main.async {
                                if check.payment_Type_Id == 2 || check.payment_Type_Id == 3 {
                                    self.printAnotherCheck(check: printCheck)
                                } else {
                                    self.error(title: "Чек проведен")
                                    self.addPreload(start_stop: true)
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.error(title: " Произошла ошибка при проведении чека")
                                self.addPreload(start_stop: true)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.error(title: " Произошла ошибка при указании типа оплаты")
                        self.addPreload(start_stop: true)
                    }
                }
            }
        } else {
            error(title: "Суммы указаны неверно")
        }
    }
    
    func printAnotherCheck(check: CheckPrint) {
        
        let alert = UIAlertController(title: "Распечать чек повторно", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.recieptController.POSTCheckPrint(token: self.token, post: check) { (answer) in
                if let answer = answer, answer == "done" {
                    DispatchQueue.main.async {
                        self.error(title: "Чек проведен")
                        self.addPreload(start_stop: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.error(title: " Произошла ошибка при проведении чека")
                        self.addPreload(start_stop: true)
                    }
                }
            }
        }))
        
        self.present(alert, animated: true,completion : nil)
        
    }
    
    func error(title : String) {
        //self.addPreload(start_stop: false)
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if title == "Чек проведен" {
                self.performSegue(withIdentifier: "backToCheckList", sender: self)
            }
        }))
        
        self.present(alert, animated: true,completion : nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardSum.isHidden = true
        cardImage.isHidden = true
        cashSum.isHidden = false
        cashImage.isHidden = false
        check?.payment_Type_Id = 1
        
        var frameRect: CGRect = cardSum.frame;
        frameRect.size.height = 50
        cashSum.frame = frameRect
        cardSum.frame = frameRect
        
        checkTotalCost.text = totalCost?.formattedAmount ?? ""
        checkChange.text = " "
        
        token = defaults?.value(forKey:"token") as? String ?? ""
        userId = defaults?.value(forKey:"userId") as? String ?? ""
        // Do any additional setup after loading the view.
    }
    
    func addPreload(start_stop: Bool){
        if start_stop {
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.style = UIActivityIndicatorView.Style.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
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
