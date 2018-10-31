//
//  UserInfoViewController.swift
//  Djinaro
//
//  Created by Azat on 30.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class UserInfoViewController: UIViewController {

    let defaults = UserDefaults.standard
    
    
    @IBAction func logOut(_ sender: Any) {
        signOut()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // defaults.set(nil, forKey: "token")
        // Do any additional setup after loading the view.
    }
    
    
    func signOut() {
        self.defaults.set(nil, forKey: "userName")
        self.defaults.set(nil, forKey: "password")
        self.defaults.set(nil, forKey: "token")
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDel.window?.rootViewController = loginVC
    }

}
