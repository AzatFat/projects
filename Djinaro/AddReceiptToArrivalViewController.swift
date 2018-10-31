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
    @IBOutlet var errorLable: UILabel!
    @IBOutlet var goodSIze: UITextField!
    @IBOutlet var goodCount: UITextField!
    @IBOutlet var goodPrise: UITextField!
    @IBOutlet var addChangeReceipt: UIButton!
    let defaults = UserDefaults.standard
    var token = ""

    @IBAction func printReceipt(_ sender: Any) {
        acceptPrinting()
    }
    
    
    var PostOrPut = false
    @IBAction func addChangeReceiptAction(_ sender: Any) {
        if PostOrPut {
            PUTReceipt()
        } else {
            PostReceipt()
        }
    }
 
    
    var receipt : Receipt?
    var receiptId = ""
    var receipt_Document_Id: Int?
    var goods_Id: Int?
    var sizes_id: Int?
    var sizes_name: String?
    var cost: Decimal?
    var count: Int?
    var sizes: [Sizes]?
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        token = defaults.object(forKey:"token") as? String ?? ""
        
        receiptController.GetSizes(token: token) { (sizes) in
            if let sizes = sizes{
                self.sizes = sizes
            }
        }
        if let receipt = receipt {
            PostOrPut = true
            addValuesToFields(receipt: receipt)
        } else {
            receiptController.GetReceipt(token: token, id: receiptId) { (receipt) in
                if let receipt = receipt {
                    DispatchQueue.main.async {
                        self.addValuesToFields(receipt: receipt)
                    }
                }
            }
        }

        hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    func addValuesToFields(receipt: Receipt) {
        goodSIze.text = receipt.sizes?.name
        goodCount.text = String(receipt.count!)
        goodPrise.text = receipt.cost!.formattedAmount
        addChangeReceipt.setTitle("Изменить", for: .normal)
        self.title = receipt.goods?.name
    }

    func getSizes(text: String) -> Int? {
        let searchtext = text.uppercased()
        if let sizes = sizes {
            for i in sizes {
                if i.name == searchtext {
                    return i.id
                }
            }
        }
        return nil
    }
    
    func getSizesName(id: Int) -> String? {
        if let sizes = sizes {
            for i in sizes {
                if i.id == id {
                    return i.name
                }
            }
        }
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unvindToArrivalInfo" {
            let controller = segue.destination as! AddGoodsToArrivalViewController
            print(PostOrPut)
            if receipt != nil {
                if PostOrPut {
                    controller.addReceipt = receipt
                    controller.changeReceipt()
                } else {
                    controller.receipts.append(receipt!)
                }
            }
        }
    }
    
    func PostReceipt () {
        var needPost = true
        if goodSIze.text != "" {
            sizes_id = getSizes(text: goodSIze.text!)
        } else {
            errorLable.text = "Размер не найден"
            needPost = false
        }
        if goodPrise.text != "" {
            var prize = goodPrise.text!.replacingOccurrences(of: ",", with: ".")
            prize = prize.replacingOccurrences(of: " ", with: "")
            cost = Decimal(string: prize)
        } else {
            errorLable.text = "Цена указана не верно"
            needPost = false
        }
        
        if goodCount.text != "" {
            count = Int(goodCount.text!)
        } else {
            errorLable.text = " Количество указана не верно"
            needPost = false

        }
        addPreload(start_stop: true)
        if needPost {
            let PostReceipt = Receipt.init(id: 1, receipt_Document_Id: receipt_Document_Id, goods_Id: goods_Id, sizes_Id: sizes_id, cost: cost, count: count, receiptDocument: nil, goods: nil, sizes: nil)
            
            receiptController.POSTReceipt(token: token, post: PostReceipt) { (receipt) in
                if let receipt = receipt {
                    self.receipt = receipt
                    DispatchQueue.main.async {
                        self.addPreload(start_stop: false)
                        self.performSegue(withIdentifier: "unvindToArrivalInfo", sender: self)
                        //self.performSegue(withIdentifier: "backToAddGoods", sender: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        print("problem to Post")
                        self.addPreload(start_stop: false)
                        self.error(title: "Произошка ошибка при добавлении товара, возможно документ уже проведен или одно из полей введено неверно.")
                    }
                }
            }
        }
    }
    
    func PUTReceipt () {
        print("trying to put")
        var needPut = true
        if goodSIze.text != "" {
            receipt?.sizes_Id = getSizes(text: goodSIze.text!)
        } else {
            errorLable.text = "Размер не найден"
            needPut = false
        }
        if goodPrise.text != "" {
            var prize = goodPrise.text!.replacingOccurrences(of: ",", with: ".")
            prize = prize.replacingOccurrences(of: " ", with: "")
            receipt?.cost = Decimal(string: prize)
        } else {
            errorLable.text = "Цена указана не верно"
            needPut = false
        }
        
        if goodCount.text != "" {
            receipt?.count = Int(goodCount.text!)
        } else {
            errorLable.text = " Количество указана не верно"
            needPut = false
        }
        addPreload(start_stop: true)
        if needPut {
            receiptController.PUTReceipt(token: token, put: receipt!, id: String(receipt!.id)) { (receipt) in
                DispatchQueue.main.async {
                    self.addPreload(start_stop: false)
                    self.performSegue(withIdentifier: "unvindToArrivalInfo", sender: self)
                    //self.performSegue(withIdentifier: "backToAddGoods", sender: nil)
                }
            }
        }
    }
    
    func acceptPrinting() {
        let alert = UIAlertController(title: "Вы действительно хотите распечатать поступление?", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField(configurationHandler: { textField in
            textField.keyboardType = .decimalPad
            textField.placeholder = "Количество этикеток"
        })
        
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { action in
            let textField = alert.textFields![0]
            if textField.text != "" {
                if let recieptPrint = self.receipt {
                    self.addPreload(start_stop: true)
                    self.receiptController.PRINTReceipt(token: self.token, post: recieptPrint, count: textField.text! ,completion: { (title) in
                        DispatchQueue.main.async {
                            self.printingDocument(title: title ?? "Произошла ошибка")
                        }
                    })
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: { action in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func printingDocument(title : String) {
        self.addPreload(start_stop: false)
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func error(title : String) {
        self.addPreload(start_stop: false)
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
