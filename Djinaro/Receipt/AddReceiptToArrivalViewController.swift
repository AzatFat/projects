//
//  AddReceiptToArrivalViewController.swift
//  Djinaro
//
//  Created by Azat on 19.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class AddReceiptToArrivalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    let receiptController = ReceiptController(useMultiUrl: true)
    @IBOutlet var errorLable: UILabel!
    @IBOutlet var goodSIze: UITextField!
    @IBOutlet var goodCount: UITextField!
    @IBOutlet var goodPrise: UITextField!
    @IBOutlet var addChangeReceipt: UIButton!
    @IBOutlet var tableView: UITableView!
    
    let defaults = UserDefaults.standard
    var token = ""

    @IBOutlet var printOrSetReceipt: UIBarButtonItem!
    @IBAction func printReceipt(_ sender: Any) {
        if PostOrPut {
            acceptPrinting()
            
        }else {
            dismissKeyboard()
            POSTReceipts()
            
            //print(postReceipts)
            
        }
    }
    
    
    var PostOrPut = false
    @IBAction func addChangeReceiptAction(_ sender: Any) {
        if PostOrPut {
            PUTReceipt()
        } else {
            PostReceipt()
        }
    }
 
    @IBOutlet var receiptInput: UISegmentedControl!
    @IBAction func receiptInputType(_ sender: Any) {
        switch receiptInput.selectedSegmentIndex
        {
        case 0:
            goodSIze.isHidden = false
            goodCount.isHidden = false
            goodPrise.isHidden = false
            addChangeReceipt.isHidden = false
            tableView.isHidden = true
            self.navigationItem.rightBarButtonItem = nil
            print("First Segment Selected")
        case 1:
            goodSIze.isHidden = true
            goodCount.isHidden = true
            goodPrise.isHidden = true
            addChangeReceipt.isHidden = true
            tableView.isHidden = false
            tableView.frame = CGRect(x: 0, y: 120, width: self.view.frame.width, height: self.view.frame.height - 120)
            printOrSetReceipt.title = "Create"
            self.navigationItem.rightBarButtonItem = self.printOrSetReceipt
            print("Second Segment Selected")
        default:
            break
        }
    }
    
    
    var receipt : Receipt?
    var receiptId = ""
    var receipt_Document_Id: Int?
   // var goods_Id: Int?
    var postReceipts: [Receipt]?
    var succesPostReceipts: [Receipt] = []
    var good : Goods?
    var sizes_id: Int?
    var sizes_name: String?
    var cost: Decimal?
    var count: Int?
    var sizes: [Sizes]?
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    private let pickerView = ToolbarPickerView()
    var pickerData: [Sizes] = []
    var sizeId = 0
    
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
        
        self.navigationItem.rightBarButtonItem = nil
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        
        token = defaults.object(forKey:"token") as? String ?? ""
        tableView.isHidden = true
        
        if good?.type_Goods_Id == 8 {
            goodSIze.isHidden = true
            goodSIze.text = "БЕЗ РАЗМЕРА"
            sizeId = 118
        }
        
        getSizesType(type: String(good!.type_Goods_Id!))
        
        
        
        /*
        receiptController.GetSizes(token: token) { (sizes) in
            if let sizes = sizes{
                self.sizes = sizes
            }
        }*/
        
        if let receipt = receipt {
            PostOrPut = true
            printOrSetReceipt.title = "Print"
            self.navigationItem.rightBarButtonItem = self.printOrSetReceipt
            receiptInput.isHidden = true
            tableView.isHidden = true
            addValuesToFields(receipt: receipt)
        } else {
            goodPrise.text = cost?.formattedAmount
     /*       if goodPrise.text == ",00" {
                goodPrise.text = good?.priceReceipt?.formattedAmount
                goodPrise.backgroundColor = UIColor.yellow
            }*/
            goodPrise.text = goodPrise.text == ",00" ? "" : goodPrise.text
            //pastLastReceiptPrice()
            /*receiptController.GetReceipt(token: token, id: receiptId) { (receipt) in
                if let receipt = receipt {
                    DispatchQueue.main.async {
                        self.addValuesToFields(receipt: receipt)
                    }
                }
            }*/
        }

        
        self.goodSIze.inputView = self.pickerView
        self.goodSIze.inputAccessoryView = self.pickerView.toolbar
        
        
        self.pickerView.dataSource = self as? UIPickerViewDataSource
        self.pickerView.delegate = self as? UIPickerViewDelegate
        self.pickerView.toolbarDelegate = self as? ToolbarPickerViewDelegate
        
        hideKeyboardWhenTappedAround() 
        // Do any additional setup after loading the view.
    }
    func addValuesToFields(receipt: Receipt) {
        goodSIze.text = receipt.sizes?.name
        goodCount.text = String(receipt.count!)
        goodPrise.text = receipt.cost!.formattedAmount
        addChangeReceipt.setTitle("Изменить", for: .normal)
        sizeId = receipt.sizes_Id!
        self.title = receipt.goods?.name
        goodPrise.text = goodPrise.text == ",00" ? "" : goodPrise.text
      //  pastLastReceiptPrice()
    }

    
    func getSizesType(type: String) {
        let receiptController = ReceiptController(useMultiUrl: true)
        let defaults = UserDefaults.standard
        let token = defaults.object(forKey:"token") as? String ?? ""
        receiptController.GetSizesByType(token: token, type: type) { (sizes) in
            if let sizes = sizes {
                self.pickerData = sizes
                self.postReceipts = Array(repeating: Receipt.init(id: 1, receipt_Document_Id: self.receipt_Document_Id, goods_Id: self.good?.id, sizes_Id: 1, cost: self.cost, count: 0, receiptDocument: nil, goods: nil, sizes: nil), count: sizes.count)
                for (i, size) in sizes.enumerated() {
                    self.postReceipts?[i].sizes_Id = size.id
                }
               // print(self.postReceipts)
                DispatchQueue.main.async {
                    
                    if self.PostOrPut  == false{
                 //       print(self.postReceipts)
                        print("pastLastReceiptPrice")
                        self.pastLastReceiptPrice()
                        self.tableView.reloadData()
                    }
                    self.pickerView.reloadAllComponents()
                    if self.good != nil {
                        for i in sizes {
                            if self.good?.type_Goods_Id == i.id {
                                self.goodSIze.text = i.name
                                break
                            }
                        }
                    }
                }
            }
        }
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
            if receipt != nil {
                print("Receipts is \(succesPostReceipts)" )
                if PostOrPut {
                    controller.addReceipt = receipt
                    controller.changeReceipt()
                } else {
                    controller.receipts.append(receipt!)
                }
            } else if succesPostReceipts.count > 0 {
                print("succesPostReceipts is \(succesPostReceipts)" )
                for receipt in succesPostReceipts {
                    controller.receipts.append(receipt)
                }
            }
            controller.good = good
        }
    }
    
    func PostReceipt () {
        var needPost = true
        if goodSIze.text != "" {
            sizes_id = sizeId
            // sizes_id = getSizes(text: goodSIze.text!)
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
        if needPost {
            let PostReceipt = Receipt.init(id: 1, receipt_Document_Id: receipt_Document_Id, goods_Id: good!.id, sizes_Id: sizes_id, cost: cost, count: count, receiptDocument: nil, goods: nil, sizes: nil)
            addPreload(start_stop: true)
            receiptController.POSTReceipt(token: token, post: PostReceipt) { (receipt) in
                if let receipt = receipt {
                    self.receipt = receipt
                    DispatchQueue.main.async {
                        self.addPreload(start_stop: false)
                        self.changePriseAfterPostorPutReceipt()
                       // self.performSegue(withIdentifier: "unvindToArrivalInfo", sender: self)
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
            receipt?.sizes_Id = sizeId != 0 ? sizeId : receipt!.sizes_Id
            //receipt?.sizes_Id = getSizes(text: goodSIze.text!)
        } else {
            errorLable.text = "Размер не найден"
            needPut = false
        }
        if goodPrise.text != "" {
            var prize = goodPrise.text!.replacingOccurrences(of: ",", with: ".")
            prize = prize.replacingOccurrences(of: " ", with: "")
            cost = Decimal(string: prize)
            receipt?.cost = cost
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
                    self.changePriseAfterPostorPutReceipt()
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
    
    func POSTReceipts() {
        var unsuccessReceipt : [Receipt]?
        var countSuccessReceipt = 0
        let myGroup = DispatchGroup()
        
        if let receipts = postReceipts {
            addPreload(start_stop: true)
            for receipt in receipts {
                myGroup.enter()
                
                if let cost = receipt.cost, let count = receipt.count, count > 0, cost > Decimal(floatLiteral: 0.0) {
                    receiptController.POSTReceipt(token: token, post: receipt) { (successReceipt) in
                        if let createdReceipt = successReceipt {
                            countSuccessReceipt += 1
                            self.succesPostReceipts.append(createdReceipt)
                            print("receipt is created \(self.succesPostReceipts)")
                        } else {
                            print("receipt is not created")
                            unsuccessReceipt?.append(receipt)
                        }
                        myGroup.leave()
                    }
                } else {
                    myGroup.leave()
                }
            }
            myGroup.notify(queue: .main) {
                if unsuccessReceipt == nil {
                    self.successPostReceipts(title: "Все поступления в количестве \(countSuccessReceipt) успешно созданы")
                } else {
                    self.successPostReceipts(title: "Создано \(countSuccessReceipt) поступлений")
                }
                self.addPreload(start_stop: false)
            }
        }
    }
    
    
    func changePriseAfterPostorPutReceipt() {
        if good?.price != cost {
            let alert = UIAlertController(title: "Цена поступления не равна цене товара, изменить цену товара?", message: nil, preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { action in
                self.good?.price = self.cost
                self.addPreload(start_stop: true)
                self.receiptController.PUTGood(token: self.token, post: self.good!, completion: { (good) in
                    DispatchQueue.main.async {
                        self.addPreload(start_stop: false)
                        let alert = UIAlertController(title: "Цена товара изменена", message: nil, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            self.performSegue(withIdentifier: "unvindToArrivalInfo", sender: self)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }))
            
            alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: { action in
                print("No")
                self.performSegue(withIdentifier: "unvindToArrivalInfo", sender: self)
            }))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "unvindToArrivalInfo", sender: self)
        }
    }
    
    func pastLastReceiptPrice() {
        print("pastLastReceiptPrice called")
        
        receiptController.GetGood(token: token, goodId: String(good!.id)) { (good) in
            if let good = good {
                DispatchQueue.main.async {
                    print(good.price, good.priceReceipt, Decimal(integerLiteral: 0))
                    if good.price == Decimal(integerLiteral: 0), good.priceReceipt != Decimal(integerLiteral: 0) {
                        let alert = UIAlertController(title: "Цена товара не указана. Желаете поставить последнюю цену поступления \(good.priceReceipt)", message: nil, preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { action in
                            self.cost = good.priceReceipt
                            self.goodPrise.text = self.cost?.formattedAmount
                            if let count = self.postReceipts?.count {
                                print("start chnage price in postReceipts?")
                                for i in 0 ..< count {
                                    self.postReceipts![i].cost = self.cost
                                }
                                self.tableView.reloadData()
                            }
                        }))
                        
                        alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: { action in
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func successPostReceipts (title : String) {
        self.addPreload(start_stop: false)
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.changePriseAfterPostorPutReceipt()
            //self.performSegue(withIdentifier: "unvindToArrivalInfo", sender: self)
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
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pickerData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "addReceiptToArrival"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AddReceiptToArrivalTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GoodsArrivalTableViewCell.")
        }

        if let goodCost = postReceipts?[indexPath.row].cost?.formattedAmount {
            cell.goodCost.text = goodCost == ",00" ? "" : String(goodCost)
        } else {
            cell.goodCost.text = ""
        }
        
        if let goodCount = postReceipts?[indexPath.row].count {
            cell.goodCount.text = String(goodCount) == "0" ? "" : String(goodCount)
        } else {
            cell.goodCount.text = ""
        }
        
        cell.goodSize.text = pickerData[indexPath.row].name
        
        cell.returnValueForCost = { value in
            print(value)
            self.postReceipts?[indexPath.row].cost = Decimal(string: value)
            cell.goodCost.text = value
            //cell.goodCount.text = self.pickerData[indexPath.row].name
        }
        cell.returnValueForCount = { value in
            print(value)
            cell.goodCount.text = value
            self.postReceipts?[indexPath.row].count = Int(value)
            //cell.goodCount.text = self.pickerData[indexPath.row].name
        }
        return cell
    }
    
    @objc func keyboardWillShow(notification:Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }
    @objc func keyboardWillHide(notification:Notification) {
        
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
}

extension AddReceiptToArrivalViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerData[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.goodSIze.text = self.pickerData[row].name
        self.sizeId = self.pickerData[row].id
    }
}

extension AddReceiptToArrivalViewController: ToolbarPickerViewDelegate {    
    func didTapDone() {
        let row = self.pickerView.selectedRow(inComponent: 0)
        self.pickerView.selectRow(row, inComponent: 0, animated: false)
        self.goodSIze.text = self.pickerData[row].name
        self.goodSIze.resignFirstResponder()
    }
    
    func didTapCancel() {
        self.goodSIze.text = nil
        self.goodSIze.resignFirstResponder()
    }
}
