//
//  CellEditForGroups.swift
//  Djinaro
//
//  Created by azat fatykhov on 30/10/2019.
//  Copyright © 2019 Azat. All rights reserved.
//

import Foundation
import UIKit

class CellEditForGroups: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    var delegate: changeValue? = nil
    var keyboardType = UIKeyboardType.default
    var bindType: goodChangeBind? = nil
    var textFieldPlaceHolder = "Поиск"
    var text = ""
  //  private let pickerView = ToolbarPickerView()
    var pickerData: [GroupGoods] = []
    var searchedData: [GroupGoods] = []
    var clusure :() -> Void = {}
    var typeGoodId = 0
    var tableView = UITableView()
    private var group = ("", 0)
    
    private var textField: UITextFieldPadding?
    
    override func viewDidLoad() {
        super .viewDidLoad()
        self.view.backgroundColor = .lightGray
        textField = setTextField()
        self.view.addSubview(textField!)
        self.view.addSubview(setButtonDone())
        self.view.addSubview(setButtonCancel())
  /*
        self.textField?.inputView = self.pickerView
        self.textField?.inputAccessoryView = self.pickerView.toolbar
        
        self.pickerView.dataSource = self as UIPickerViewDataSource
        self.pickerView.delegate = self as UIPickerViewDelegate
        self.pickerView.toolbarDelegate = self as ToolbarPickerViewDelegate
  */
        getGroupGoods()
        
        tableView = UITableView(frame: CGRect(x: 0,y: 100, width: self.view.bounds.size.width, height: self.view.bounds.size.height-100), style: UITableView.Style.plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(self.tableView)

        // print("In View \(aa)")
    }
    
    func setTextField() -> UITextFieldPadding {
        //let textField = UITextField(frame: CGRect(x:  0, y: (self.navigationController?.navigationBar.frame.height ?? 40) + 5, width: self.view.frame.width, height: 60))
        let textField = UITextFieldPadding(frame: CGRect(x:  0, y: (self.navigationController?.navigationBar.frame.height ?? 40) + 5, width: self.view.frame.width, height: 60))
        textField.placeholder = textFieldPlaceHolder
        textField.text = text == "" ? nil : text
        textField.font = UIFont.systemFont(ofSize: 20)
        textField.keyboardType = keyboardType
        textField.textAlignment = .left
        textField.textColor = .black
        textField.backgroundColor = .white
        textField.delegate = self
        
        return textField
    }
    
    func setButtonDone () -> UIButton {
        let button = UIButton(frame: CGRect(x:  self.view.frame.width - 115, y: 0, width: self.view.frame.width/4, height: 40))
        button.setTitle("Сохранить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.addTarget(self, action: #selector(buttonDoneAction), for: .touchUpInside)
        return button
    }
    
    func setButtonCancel () -> UIButton {
           let button = UIButton(frame: CGRect(x:  10, y: 0, width: self.view.frame.width/5, height: 40))
           button.setTitle("Отмена", for: .normal)
           button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
           button.addTarget(self, action: #selector(buttonCancelAction), for: .touchUpInside)
           return button
       }
    
    @objc func buttonDoneAction(sender: UIButton!) {
        if let bind = bindType {
            delegate?.changeGoodsValues(newValue: group, bind: bind)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func buttonCancelAction(sender: UIButton!) {
        dismiss(animated: true, completion: nil)
    }
    
    func getGroupGoods () {
        let receiptController = ReceiptController(useMultiUrl: true)
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        receiptController.GETGroupGoods(token: token) { (groupGoods) in
            if let groupGoods = groupGoods {
                DispatchQueue.main.async {
                    self.searchedData = groupGoods
                    self.pickerData = groupGoods
                    self.tableView.reloadData()
                    
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           pickerData.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let myNewCell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as UITableViewCell

           myNewCell.textLabel?.text = self.pickerData[indexPath.row].name

           return myNewCell
       }
       
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.textField?.text = self.pickerData[indexPath.row].name
            self.group.0 = self.pickerData[indexPath.row].name ?? ""
            self.group.1 = self.pickerData[indexPath.row].id
        }
       }
    
}


extension CellEditForGroups : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
           // return NO to disallow editing.
           print("TextField should begin editing method called")
           return true
       }

       func textFieldDidBeginEditing(_ textField: UITextField) {
           // became first responder
           print("TextField did begin editing method called")
       }

       func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
           // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
           print("TextField should end editing method called")
           return true
       }

       func textFieldDidEndEditing(_ textField: UITextField) {
           // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
           print("TextField did end editing method called")
       }

       func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
           // if implemented, called in place of textFieldDidEndEditing:
           print("TextField did end editing with reason method called")
       }

       func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           // return NO to not change text
           
          self.pickerData = searchedData.filter{$0.name!.lowercased().contains(textField.text!.lowercased())}
           DispatchQueue.main.async {
                        self.tableView.reloadData()
               
           }
           print("While entering the characters this method gets called")
           return true
       }

       func textFieldShouldClear(_ textField: UITextField) -> Bool {
           // called when clear button pressed. return NO to ignore (no notifications)
           print("TextField should clear method called")
           return true
       }

       func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           // called when 'return' key pressed. return NO to ignore.
           print("TextField should return method called")
           // may be useful: textField.resignFirstResponder()
           return true
       }
}

/*
extension CellEditForGroups: UIPickerViewDataSource, UIPickerViewDelegate {
    
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
        self.textField?.text = self.pickerData[row].name
        self.typeGoodId = self.pickerData[row].id
    }
}


extension CellEditForGroups: ToolbarPickerViewDelegate {
    
    func didTapDone() {
        let row = self.pickerView.selectedRow(inComponent: 0)
        self.pickerView.selectRow(row, inComponent: 0, animated: false)
        self.textField?.text = self.pickerData[row].name
        self.typeGoodId = self.pickerData[row].id
        self.textField?.resignFirstResponder()
    }
    
    func didTapCancel() {
        self.textField?.text = nil
        self.textField?.resignFirstResponder()
    }
}*/
