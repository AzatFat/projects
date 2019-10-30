//
//  CellEditControllerWithDataPicker.swift
//  Djinaro
//
//  Created by azat fatykhov on 28/10/2019.
//  Copyright © 2019 Azat. All rights reserved.
//

import Foundation
import UIKit

class CellEditCOntrollerWithDataPicker: UIViewController {
    var delegate: changeValue? = nil
    var keyboardType = UIKeyboardType.default
    var bindType: goodChangeBind? = nil
    var textFieldPlaceHolder = "Test"
    var text = ""
    private let pickerView = ToolbarPickerView()
    var pickerData: [TypeGoods] = []
    var clusure :() -> Void = {}
    var typeGoodId = 0
    
    private var textField: UITextFieldPadding?
    
    override func viewDidLoad() {
        super .viewDidLoad()
        self.view.backgroundColor = .lightGray
        textField = setTextField()
        self.view.addSubview(textField!)
        self.view.addSubview(setButtonDone())
        self.view.addSubview(setButtonCancel())
        
        self.textField?.inputView = self.pickerView
        self.textField?.inputAccessoryView = self.pickerView.toolbar
        
        self.pickerView.dataSource = self as UIPickerViewDataSource
        self.pickerView.delegate = self as UIPickerViewDelegate
        self.pickerView.toolbarDelegate = self as ToolbarPickerViewDelegate
        getGoodsType ()
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
            delegate?.changeGoodsValues(newValue: (textField?.text, typeGoodId), bind: bind)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func buttonCancelAction(sender: UIButton!) {
        dismiss(animated: true, completion: nil)
    }
    
    func getGoodsType () {
        DispatchQueue.main.async {
            self.pickerView.reloadAllComponents()
        }
    }
}


extension CellEditCOntrollerWithDataPicker : UITextFieldDelegate {
    
}


extension CellEditCOntrollerWithDataPicker: UIPickerViewDataSource, UIPickerViewDelegate {
    
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

extension CellEditCOntrollerWithDataPicker: ToolbarPickerViewDelegate {
    
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
}
