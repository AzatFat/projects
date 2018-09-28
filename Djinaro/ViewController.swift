//
//  ViewController.swift
//  Djinaro
//
//  Created by Azat on 21.09.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let goodsController = GoodsController()

    
    
    @IBOutlet var UserName: UITextField!
    
    @IBOutlet var Password: UITextField!
    
    @IBAction func LogIn(_ sender: Any) {
        
        performSegue(withIdentifier: "LogIn", sender: nil)
        
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
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func touchesBegan(_: Set<UITouch>, with: UIEvent?){
        UserName.resignFirstResponder()
        Password.resignFirstResponder()
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
