//
//  ProgressViewController.swift
//  Djinaro
//
//  Created by Azat on 11.12.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

import MBCircularProgressBar


protocol GETMainReport {
    func GETMainResult()
    func updateMainResultParametrs(mainParametrs: datesForMainResult)
}

class ProgressViewController: UIViewController {
    @IBOutlet var timeLeft: MBCircularProgressBarView!
    @IBOutlet var moneyEarn: MBCircularProgressBarView!
    @IBOutlet var timeLeftText: UILabel!
    @IBOutlet var Conversion: MBCircularProgressBarView!
    
    private var dateFromPicer: UIDatePicker!
    private var dateToPicker: UIDatePicker!
    
    
    var delegate: UserInfoViewController?
    
    var dateFrom: UITextField?
    var dateTo: UITextField?
    var consultant: UITextField?
    var consultantId : Int? = nil
    private let pickerView = ToolbarPickerView()
    var pickerData: [Employees] = []
    
    let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
    //var userInfoView = UserInfoViewController()
    var timer = Timer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeLeft.value = 100
        timeLeft.showValueString = false
        moneyEarn?.value = 0
        moneyEarn?.unitString = ""
        Conversion?.value = 0
        
        getTimeRemaining()
        
        dateFrom = createDateText(position: CGRect(x: 5, y: 5, width: 100, height: 40))
        dateTo = createDateText(position: CGRect(x: 120, y: 5, width: 100, height: 40))
        consultant = createDateText(position: CGRect(x: 5, y: 50, width: 100, height: 40))
        
        dateTo?.isHidden = true
        dateFrom?.isHidden = true
        consultant?.isHidden = true
       // getDefaultDaysForMaonReport()
       
        let theDateFromBar = UIToolbar().ToolbarPiker(mySelect: #selector(ProgressViewController.dateFromChangeDismissPicker), clear: #selector(ProgressViewController.clearDateFromDismissPicker))
        
        let theDateToBar = UIToolbar().ToolbarPiker(mySelect: #selector(ProgressViewController.dateToChangeDismissPicker), clear: #selector(ProgressViewController.clearDateToDismissPicker))
        
        dateFrom?.inputAccessoryView = theDateFromBar
        dateTo?.inputAccessoryView = theDateToBar
        
        dateFromPicer = UIDatePicker()
        dateToPicker = UIDatePicker()
        dateFromPicer?.datePickerMode = .date
        dateToPicker?.datePickerMode = .date
        dateFrom?.inputView = dateFromPicer
        dateTo?.inputView = dateToPicker
        
        dateFromPicer?.addTarget(self, action: #selector(ProgressViewController.dateFromChange(dateChanged:)), for: .valueChanged)
        dateToPicker?.addTarget(self, action: #selector(ProgressViewController.dateToChange(dateChanged:)), for: .valueChanged)
        
        
        self.consultant?.inputView = self.pickerView
        self.consultant?.inputAccessoryView = self.pickerView.toolbar
        
        self.pickerView.dataSource = self as UIPickerViewDataSource
        self.pickerView.delegate = self as UIPickerViewDelegate
        self.pickerView.toolbarDelegate = self as ToolbarPickerViewDelegate
        
        GETActiveEmployees()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getTimeRemaining()
        scheduledTimerWithTimeInterval()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.getTimeRemaining), userInfo: nil, repeats: true)
    }

    @objc func getTimeRemaining() {
        let receiptController = ReceiptController(useMultiUrl: true)
        let token = self.defaults?.value(forKey:"token") as? String ?? ""
        receiptController.GETtimeRemaning(token: token) { (timeRemaining ) in
            if let timeRemaining = timeRemaining {
                let time = timeRemaining.remaining_time.components(separatedBy: ":")
                let hours = Int(time[0])!
                let minutes = Int(time[1])!
                let cnt_c = timeRemaining.cnt_c
                let cnt_p = timeRemaining.cnt_p
                
                var allMinutes = hours < 0 ? 480 : hours * 60 + minutes
                
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 2.0) {
                        if allMinutes >= 480 {
                            allMinutes = 480
                            self.timeLeftText.text = "8ч 0м"
                        } else {
                            self.timeLeftText.text = "\(time[0])ч \(time[1])м"
                        }
                        self.timeLeft.value = CGFloat(100 * allMinutes/480)
                        
                        switch self.timeLeft.value {
                        case  0 ..< CGFloat(truncating: 25):
                            self.timeLeft.progressColor = UIColor.red
                            self.timeLeft.progressStrokeColor = UIColor.red
                        case CGFloat(truncating: 25) ..< CGFloat(truncating: 50):
                            self.timeLeft.progressColor = UIColor.orange
                            self.timeLeft.progressStrokeColor = UIColor.orange
                        case CGFloat(truncating: 50) ..< CGFloat(truncating: 75):
                            self.timeLeft.progressColor = UIColor.cyan
                            self.timeLeft.progressStrokeColor = UIColor.cyan
                        default:
                            self.timeLeft.progressColor = UIColor.init(red: 215.0/255.0, green: 131.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                            self.timeLeft.progressStrokeColor = UIColor.init(red: 215.0/255.0, green: 131.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                        }

                        let conversion = cnt_p == 0 ? 0 : 100 * cnt_c / cnt_p
                        self.Conversion.value = CGFloat(conversion)
                        switch self.Conversion.value {
                        case  0 ..< CGFloat(truncating: 25):
                            self.Conversion.progressColor = UIColor.red
                            self.Conversion.progressStrokeColor = UIColor.red
                        case CGFloat(truncating: 25) ..< CGFloat(truncating: 35):
                            self.Conversion.progressColor = UIColor.orange
                            self.Conversion.progressStrokeColor = UIColor.orange
                        case CGFloat(truncating: 35) ..< CGFloat(truncating: 50):
                            self.Conversion.progressColor = UIColor.cyan
                            self.Conversion.progressStrokeColor = UIColor.cyan
                        default:
                            self.Conversion.progressColor = UIColor.init(red: 215.0/255.0, green: 131.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                            self.Conversion.progressStrokeColor = UIColor.init(red: 215.0/255.0, green: 131.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                        }
                    }
                }
            }
        }
    }
    
    func getMoneyEarned(moneyEarned : Decimal) {
        let money = moneyEarned.formattedAmount
        guard let money_earned = NumberFormatter().number(from: money ?? "0") else { return }
        DispatchQueue.main.async {
            UIView.animate(withDuration: 2.0) {
                self.moneyEarn.value = CGFloat(truncating: money_earned)
                switch self.moneyEarn.value {
                case 0 ..< CGFloat(truncating: 700):
                    self.moneyEarn.progressColor = UIColor.red
                    self.moneyEarn.progressStrokeColor = UIColor.red
                case CGFloat(truncating: 700) ..< CGFloat(truncating: 1000):
                    self.moneyEarn.progressColor = UIColor.orange
                    self.moneyEarn.progressStrokeColor = UIColor.orange
                case CGFloat(truncating: 1000) ..< CGFloat(truncating: 1300):
                    self.moneyEarn.progressColor = UIColor.cyan
                    self.moneyEarn.progressStrokeColor = UIColor.cyan
                default:
                    self.moneyEarn.progressColor = UIColor.init(red: 215.0/255.0, green: 131.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                    self.moneyEarn.progressStrokeColor = UIColor.init(red: 215.0/255.0, green: 131.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                }
            }
        }
    }
    
    func createDateText(position: CGRect) -> UITextField {
        let sampleTextField =  UITextField(frame: position)
        sampleTextField.placeholder = "Enter text here"
        sampleTextField.font = UIFont.systemFont(ofSize: 15)
        sampleTextField.borderStyle = UITextField.BorderStyle.roundedRect
        sampleTextField.autocorrectionType = UITextAutocorrectionType.no
        sampleTextField.keyboardType = UIKeyboardType.default
        sampleTextField.returnKeyType = UIReturnKeyType.done
        sampleTextField.clearButtonMode = UITextField.ViewMode.whileEditing
        sampleTextField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        sampleTextField.delegate = self as? UITextFieldDelegate
        self.view.addSubview(sampleTextField)
        return sampleTextField
    }
    
    @objc func dateFromChange(dateChanged: UIDatePicker) {
        let dateFormatted = DateFormatter()
        dateFormatted.dateFormat = "dd.MM.yyyy"
        dateFrom?.text = dateFormatted.string(from: dateFromPicer.date)
    }

    @objc func dateFromChangeDismissPicker() {
        let dateFormatted = DateFormatter()
        dateFormatted.dateFormat = "dd.MM.yyyy"
        dateFrom?.text = dateFormatted.string(from: dateFromPicer.date)
        getRemainReport()
        view.endEditing(true)
    }
    
    @objc func clearDateFromDismissPicker() {
       // receiptDate.text = ""
       // recieptDocument?.receipt_Date = nil
       // PUTReceiptDocument()
        view.endEditing(true)
    }
    
    
    @objc func dateToChange(dateChanged: UIDatePicker) {
        let dateFormatted = DateFormatter()
        dateFormatted.dateFormat = "dd.MM.yyyy"
        dateTo?.text = dateFormatted.string(from: dateToPicker.date)
    }
    
    @objc func dateToChangeDismissPicker() {
        let dateFormatted = DateFormatter()
        dateFormatted.dateFormat = "dd.MM.yyyy"
        dateTo?.text = dateFormatted.string(from: dateToPicker.date)
        getRemainReport()
        view.endEditing(true)
    }
    
    @objc func clearDateToDismissPicker() {
        // receiptDate.text = ""
        // recieptDocument?.receipt_Date = nil
        // PUTReceiptDocument()
        view.endEditing(true)
    }
    
    
    func getDefaultDaysForMaonReport() {
        let dateEnd = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        if let dateStart = Calendar.current.date(byAdding: .day, value: -7, to: Date()) {
            let dateStartText = formatter.string(from: dateStart)
            dateFrom?.text = dateStartText
        }
        let dateEndText = formatter.string(from: dateEnd)
        dateTo?.text = dateEndText
        getRemainReport()
    }
    
    func getRemainReport() {
        if delegate != nil,  dateFrom?.text != "" , dateTo?.text != "" {
            let dateF = dateFrom!.text!.components(separatedBy: ".")
            let dateFromForPost = "\(dateF[1]).\(dateF[0]).\(dateF[2])"
            let dateT = dateTo!.text!.components(separatedBy: ".")
            let dateToForPost = "\(dateT[1]).\(dateT[0]).\(dateT[2])"
            let dates = datesForMainResult.init(date_from: dateFromForPost, date_to: dateToForPost, employees_id: consultantId, check_type_id: nil, type_goods_id: nil)
            delegate?.updateMainResultParametrs(mainParametrs: dates)
            delegate?.GETMainResult()
        } else {
            print("Delegate nil")
        }
    }
    
    func GETActiveEmployees() {
        let receiptController = ReceiptController(useMultiUrl: true)
        let token = self.defaults?.value(forKey:"token") as? String ?? ""
        receiptController.GETEmployees(token: token) { (employees) in
            if let employees = employees {
                for employ in employees {
                    if employ.is_Active == true {
                        self.pickerData.append(employ)
                    }
                }
                print(self.pickerData)
                DispatchQueue.main.async {
                    self.pickerView.reloadAllComponents()
                }
            }
        }
    }
}


extension ProgressViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
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
        self.consultant?.text = self.pickerData[row].name
        self.consultantId = self.pickerData[row].id
    }
}

extension ProgressViewController: ToolbarPickerViewDelegate {
    
    func didTapDone() {
        let row = self.pickerView.selectedRow(inComponent: 0)
        self.pickerView.selectRow(row, inComponent: 0, animated: false)
        self.consultant?.text = self.pickerData[row].name
        self.consultantId = self.pickerData[row].id
        self.consultant?.resignFirstResponder()
        self.getRemainReport()
    }
    
    func didTapCancel() {
        self.consultant?.text = nil
        self.consultantId = nil
        self.consultant?.resignFirstResponder()
        self.getRemainReport()
    }
}
