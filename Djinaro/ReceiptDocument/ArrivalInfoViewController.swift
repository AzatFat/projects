//
//  ArrivalInfoViewController.swift
//  Djinaro
//
//  Created by Azat on 16.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class ArrivalInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBAction func CloseReceiptDocument(_ sender: Any) {
        closeDocument()
    }
    @IBAction func addNewGood(_ sender: Any) {
        performSegue(withIdentifier: "GoodsList", sender: nil)
    }
    @IBOutlet var tableView: UITableView!
    @IBOutlet var arrivalName: UILabel!
    @IBOutlet var receiptDate: UITextField!
    @IBOutlet var theDate: UITextField!
    private var datePicker: UIDatePicker!
    private var theDatePicker: UIDatePicker!
    
    @IBAction func printButton(_ sender: Any) {
        acceptPrintingReceiptDocument()
    }
    var receiptId = ""
    let receiptController = ReceiptController(useMultiUrl: true)
    var recieptDocument: ReceiptDocument?
    var receipts: [Receipt]?
    var receiptsToAddNewGoodsController =  [Receipt]()
    var receiptsnameToAddNewGoodsController: Goods?
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
    var token = ""
    
    var GroupReceiptsList = [GroupReceipts]()
    
    
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
    
    func countCostEachreceipt(receipts: [Receipt]) -> [GroupReceipts] {
        var GroupReceiptsList = [GroupReceipts]()
        var receiptDictionary : Dictionary = [String:[Receipt]]()
        for i in receipts {
            if let receiptId = i.goods_Id {
                if receiptDictionary[String(receiptId)] != nil {
                    receiptDictionary[String(receiptId)]!.append(i)
                } else {
                    receiptDictionary[String(receiptId)] = [i]
                }
            }
        }
        
        for i in receiptDictionary {
            var cost : Decimal = 0.0
            let good = i.value[0].goods
            for j in i.value {
                if let goodCost = j.cost {
                    cost += goodCost * Decimal(j.count!)
                }
            }
            GroupReceiptsList.append(GroupReceipts(objectGood: good, objectRaw: i.value, objectCost: cost.formattedAmount))
        }
        return GroupReceiptsList
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GroupReceiptsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "arrivalInfoCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ArrivalInfoTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GoodsArrivalTableViewCell.")
        }
        cell.arrivalGood.text = GroupReceiptsList[indexPath.row].objectGood.name
        cell.arrivalCost.text = GroupReceiptsList[indexPath.row].objectCost
        // print(CostEachreceipt.inn(forKey: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("trying to perform segue")
        let cell = tableView.cellForRow(at: indexPath as IndexPath)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        if let receipts = GroupReceiptsList[indexPath.row].objectRaw {
            receiptsToAddNewGoodsController = receipts.sorted(by: {$0.sizes!.name! < $1.sizes!.name! })
            receiptsnameToAddNewGoodsController = GroupReceiptsList[indexPath.row].objectGood
        }
        
        performSegue(withIdentifier: "addGoodToArrival", sender: cell)
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let receiptDocumentId = recieptDocument!.id
        let goodId = GroupReceiptsList[indexPath.row].objectGood.id
        let printGoodReceipts = UITableViewRowAction(style: .normal, title: "Печать модели") { (action, indexPath) in
            self.acceptPrintingAllGoodsReceipts(receiptDocumentId: String(receiptDocumentId), goodId: String(goodId))
        }
        
        let deleteReceipts = UITableViewRowAction(style: .normal, title: "Удалить модель") { (action, indexPath) in
            self.deleteReceipts(receipts: self.GroupReceiptsList[indexPath.row].objectRaw, indexPath: indexPath.row, indexPathRow: indexPath)
        }
        
        printGoodReceipts.backgroundColor = UIColor.blue
        deleteReceipts.backgroundColor = UIColor.red
        return [printGoodReceipts,deleteReceipts ]
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addGoodToArrival" {
            let controller = segue.destination as! AddGoodsToArrivalViewController
            controller.receipts = receiptsToAddNewGoodsController
            controller.good = receiptsnameToAddNewGoodsController
            controller.receipt_Document_Id = recieptDocument?.id
        }
        if segue.identifier == "GoodsList" {
            let controller = segue.destination as! GoodsTableViewController
            controller.segue = "addGoodToArrival"
            controller.title = "Выбор товара"
            controller.receipts = receiptsToAddNewGoodsController
            controller.receipt_Document_Id = recieptDocument?.id
            controller.groupReceiptsList = GroupReceiptsList
        }
    }
    
    //////////// Date Picker control
 /*   @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    } */
    
    @objc func dateChanged(dateChanged: UIDatePicker) {
        let dateFormatted = DateFormatter()
        dateFormatted.dateFormat = "yyyy-MM-dd"
        receiptDate.text = dateFormatted.string(from: datePicker.date)
    }
    
    @objc func theDateChanged(dateChanged: UIDatePicker) {
        let dateFormatted = DateFormatter()
        dateFormatted.dateFormat = "yyyy-MM-dd"
        theDate.text = dateFormatted.string(from: theDatePicker.date)
    }
    

    @objc func receiptDatedismissPicker() {
        let dateFormatted = DateFormatter()
        dateFormatted.dateFormat = "yyyy-MM-dd"
        receiptDate.text = dateFormatted.string(from: datePicker.date)
        recieptDocument?.receipt_Date = dateFormatted.string(from: datePicker.date) + "T00:00:00.0263+03:00"
        PUTReceiptDocument()
        view.endEditing(true)
    }
    
    @objc func theDatedismissPicker() {
        let dateFormatted = DateFormatter()
        dateFormatted.dateFormat = "yyyy-MM-dd"
        theDate.text = dateFormatted.string(from: theDatePicker.date)
        recieptDocument?.the_Date = dateFormatted.string(from: theDatePicker.date) + "T00:00:00.0263+03:00"
        PUTReceiptDocument()
        view.endEditing(true)
    }
    
    @objc func clearReceiptDatedismissPicker() {
        receiptDate.text = ""
        recieptDocument?.receipt_Date = nil
        PUTReceiptDocument()
        view.endEditing(true)
    }
    
    @objc func clearTheDatedismissPicker() {
        theDate.text = ""
        recieptDocument?.the_Date = nil
        PUTReceiptDocument()
        view.endEditing(true)
    }
    
    
    func PUTReceiptDocument () {
        self.addPreload(start_stop: true)
        if let Document = recieptDocument {
            receiptController.PUTReceiptDocument(token: token, put: Document, id: receiptId) { (receiptDocument) in
                self.GETReceiptDocument()
            }
        }
    }
    
    func GETReceiptDocument () {
        print("try GETReceiptDocument")
        if receiptId != "" {
            receiptController.GetReceiptDocument(token: token, id: receiptId) { (receiptDocument) in
                if let receiptDocument = receiptDocument {
                    self.recieptDocument = receiptDocument
                }
                DispatchQueue.main.async {
                    // self.tableView.reloadData()
                    
                    if let receipts = self.recieptDocument?.receiptList {
                        self.GroupReceiptsList = self.countCostEachreceipt(receipts: receipts)
                        self.tableView.reloadData()
                    }
                    self.arrivalName.text = self.recieptDocument?.name
                    self.receiptDate.text = self.recieptDocument?.receipt_Date?.components(separatedBy: "T")[0]
                    self.theDate.text = self.recieptDocument?.the_Date?.components(separatedBy: "T")[0]
                    self.addPreload(start_stop: false)
                }
            }
        } else {print("try GETReceiptDocument no receipt == null")}
    }
    
    
    func CloseReceiptDocument ()  {
        self.addPreload(start_stop: true)
        if let recieptDocument = self.recieptDocument {
            var message = "Ошибка в проведении документа"
            if recieptDocument.the_Date == nil {
                receiptController.CLOSEReceiptDocument(token: token, post: recieptDocument) { (document) in
                    if let receiptDocument = document {
                        self.recieptDocument = receiptDocument
                        message = "Документ успешно проведен"
                        
                    }
                    DispatchQueue.main.async {
                        // self.tableView.reloadData()
                        self.printingAnswer(title: message)
                        if let receipts = self.recieptDocument?.receiptList {
                            self.GroupReceiptsList = self.countCostEachreceipt(receipts: receipts)
                            self.tableView.reloadData()
                        }
                        self.arrivalName.text = self.recieptDocument?.name
                        self.receiptDate.text = self.recieptDocument?.receipt_Date?.components(separatedBy: "T")[0]
                        self.theDate.text = self.recieptDocument?.the_Date?.components(separatedBy: "T")[0]
                        self.addPreload(start_stop: false)
                    }
                }
            } else {
                self.printingAnswer(title: "Документ уже проведен, повторное проведение не возможно")
            }
        }
    }
    
    
    func PrintReceiptDocument() {
        self.addPreload(start_stop: true)
        if let recieptPrintDocument = self.recieptDocument {
            self.receiptController.PRINTReceiptDocument(token: token, post: recieptPrintDocument, completion: { (title) in
                DispatchQueue.main.async {
                    self.printingAnswer(title: title ?? "Произошла ошибка")
                    self.addPreload(start_stop: false)
                }
            })
        }
    }
    
    func PrintAllGoodsReceipts(receiptDocumentId: String, goodId: String) {
        self.addPreload(start_stop: true)
        receiptController.PRINTAllGoodReceiptsInDocument(token: token, receiptDocumentId: receiptDocumentId, goodId: goodId) { (title) in
            DispatchQueue.main.async {
                self.printingAnswer(title: title ?? "Произошла ошибка")
                self.addPreload(start_stop: false)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        token = defaults?.value(forKey:"token") as? String ?? ""
        
        let theDateToolBar = UIToolbar().ToolbarPiker(mySelect: #selector(ArrivalInfoViewController.theDatedismissPicker), clear: #selector(ArrivalInfoViewController.clearTheDatedismissPicker))
        
        let receiptDateToolBar = UIToolbar().ToolbarPiker(mySelect: #selector(ArrivalInfoViewController.receiptDatedismissPicker), clear: #selector(ArrivalInfoViewController.clearReceiptDatedismissPicker))
        
        receiptDate.inputAccessoryView = receiptDateToolBar
        theDate.inputAccessoryView = theDateToolBar
        
        datePicker = UIDatePicker()
        theDatePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        theDatePicker?.datePickerMode = .date
        receiptDate.inputView = datePicker
        theDate.inputView = theDatePicker
        
        datePicker?.addTarget(self, action: #selector(ArrivalInfoViewController.dateChanged(dateChanged:)), for: .valueChanged)
        theDatePicker?.addTarget(self, action: #selector(ArrivalInfoViewController.theDateChanged(dateChanged:)), for: .valueChanged)
       // let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ArrivalInfoViewController.viewTapped(gestureRecognizer:)))
       // view.addGestureRecognizer(tapGesture)
        
        self.addPreload(start_stop: true)
        GETReceiptDocument()
    }
    override func viewDidAppear(_ animated: Bool) {
        GETReceiptDocument()
    }
    
//////// Alert on print
    func acceptPrintingReceiptDocument() {
        let alert = UIAlertController(title: "Вы действительно хотите распечатать документ поступления?", message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { action in
            self.PrintReceiptDocument()
            if self.recieptDocument?.the_Date == nil {
                self.CloseReceiptDocument()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: { action in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func acceptPrintingAllGoodsReceipts(receiptDocumentId: String, goodId: String) {
        let alert = UIAlertController(title: "Вы действительно хотите распечатать модель поступления?", message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { action in
            self.PrintAllGoodsReceipts(receiptDocumentId: receiptDocumentId, goodId: goodId)
        }))
        
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: { action in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteReceipts(receipts: [Receipt], indexPath: Int, indexPathRow: IndexPath) {
        let alert = UIAlertController(title: "Вы действительно удалить  модель поступления?", message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { action in
            self.addPreload(start_stop: true)
            let myGroup = DispatchGroup()
            for i in receipts {
                myGroup.enter()
                self.receiptController.DELETEReceipt(token: self.token, id: String(i.id)) { (receipt) in
                    myGroup.leave()
                }
            }
            
            myGroup.notify(queue: .main) {
                DispatchQueue.main.async {
                    self.GroupReceiptsList.remove(at: indexPath)
                    self.tableView.deleteRows(at: [indexPathRow], with: .fade)
                    self.addPreload(start_stop: false)
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: { action in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func closeDocument() {
        let alert = UIAlertController(title: "Вы действительно хотите провести документ поступления?", message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { action in
            self.addPreload(start_stop: true)
            self.CloseReceiptDocument()
        }))
        
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: { action in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
/*    func closingDocument(title : String) {
        self.addPreload(start_stop: false)
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }*/
    
    
    func printingAnswer(title : String) {
        self.addPreload(start_stop: false)
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
}

extension UIToolbar {
    
    func ToolbarPiker(mySelect : Selector, clear : Selector) -> UIToolbar {
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: mySelect)
        let clearButton = UIBarButtonItem(title: "Clear", style: UIBarButtonItem.Style.plain, target: self, action: clear)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ clearButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
}

