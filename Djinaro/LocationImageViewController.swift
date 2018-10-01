//
//  LocationImageViewController.swift
//  Djinaro
//
//  Created by Azat on 27.09.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class LocationImageViewController: UIViewController {
    
    var locationText: String = ""
    @IBOutlet var GoodImage: UIImageView!
    
    @IBOutlet var GoodSize: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func changeLocation(locationText: String){
        DispatchQueue.main.async {
            self.GoodSize.text = locationText
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
