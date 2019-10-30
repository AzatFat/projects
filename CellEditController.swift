//
//  CellEditController.swift
//  Djinaro
//
//  Created by azat fatykhov on 20/10/2019.
//  Copyright © 2019 Azat. All rights reserved.
//

import Foundation
import UIKit


class CellEditController: UIViewController {
    
    var delegate: changeValue? = nil
    var keyboardType = UIKeyboardType.default
    var bindType: goodChangeBind? = nil
    var textFieldPlaceHolder = "Test"
    var text = ""
    var clusure :() -> Void = {}
    
    private var textField: UITextFieldPadding?
    
    override func viewDidLoad() {
        super .viewDidLoad()
        self.view.backgroundColor = .lightGray
        textField = setTextField()
        self.view.addSubview(textField!)
        self.view.addSubview(setButtonDone())
        self.view.addSubview(setButtonCancel())
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
            print("setTextField().text is \(textField?.text)")
            delegate?.changeGoodsValues(newValue: textField?.text, bind: bind)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func buttonCancelAction(sender: UIButton!) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension CellEditController : UITextFieldDelegate {
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

class UITextFieldPadding : UITextField {

   let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 5)
     override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
     }
     override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
     }
     override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
     }
}


