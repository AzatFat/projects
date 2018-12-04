//
//  GoodInfoViewController.swift
//  Djinaro
//
//  Created by Azat on 31.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit



class GoodInfoViewController: UIViewController {
    
    @IBOutlet var GoodName: UILabel!
    @IBOutlet var GoodLocation: UILabel!
    var goodImageUrl = ""
    var goodName = ""
    var goodLocation = ""
    @IBOutlet var goodname: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func changeLocation(goodName: String, goodLocation: String, goodImageUrl: String){
        DispatchQueue.main.async {
            self.GoodName.text = "   " + goodName
            self.GoodLocation.text = "   " + goodLocation
            if goodImageUrl != "" {
                print("trying to get image")
                 self.getGoodMainImage(imageUrl: goodImageUrl)
            }
        }
    }
    
    func getGoodMainImage(imageUrl: String) {
        let receiptController = ReceiptController(useMultiUrl: true)
        receiptController.getGoodImage(url: imageUrl) { (image) in
            if let image = image {
                print("full success get image")
                DispatchQueue.main.async {
                    self.goodname.image = image
                    
                }
            }else {
            }
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
