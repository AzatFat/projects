//
//  ViewController.swift
//  Djinaro
//
//  Created by Azat on 21.09.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITextFieldDelegate {

    let goodsController = GoodsController()
    let receiptController = ReceiptController()
    let defaults = UserDefaults.standard
    
    
    @IBOutlet var UserName: UITextField!
    @IBOutlet var Password: UITextField!
    @IBAction func LogIn(_ sender: Any) {
        if UserName.text != "" && Password.text != "" {
            signIn(userName: UserName.text!, password: Password.text!, NeedErrorMessage: true)
        } else {
            signError()
        }
    }
    override func viewDidLoad() {
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                NSLog("\(cookie)")
            }
        }
        
        let storage = HTTPCookieStorage.shared
        for cookie in storage.cookies! {
            storage.deleteCookie(cookie)
        }
        
        URLCache.shared.removeAllCachedResponses()
        
        super.viewDidLoad()
        
        let userName = defaults.object(forKey:"userName") as? String
        let password = defaults.object(forKey:"password") as? String
        //let userId = defaults.object(forKey:"userId") as? String

        if userName != nil && password != nil {
            signIn(userName: userName ?? "", password: password ?? "", NeedErrorMessage: false)
        }
        self.UserName.delegate = self
        self.Password.delegate = self
        
        hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func touchesBegan(_: Set<UITouch>, with: UIEvent?){
        UserName.resignFirstResponder()
        Password.resignFirstResponder()
    }
    
    func signError() {
        let alert = UIAlertController(title: "Введен неверно логин или пароль", message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func signIn(userName: String, password: String, NeedErrorMessage: Bool)  {
        print("caling signIn function")
        receiptController.POSTToken(username: userName, password: password) { (token) in
            print("Post Token function")
            if let token = token {
                self.defaults.set(userName, forKey: "userName")
                self.defaults.set(password, forKey: "password")
                self.defaults.set(token.user_id, forKey: "userId")
                self.defaults.set(token.access_token, forKey: "token")
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "LogIn", sender: nil)
                }
            } else {
                if NeedErrorMessage {
                    DispatchQueue.main.async {
                        self.signError()
                    }
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension UIImageView
{
    func addBlurEffect()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
}
