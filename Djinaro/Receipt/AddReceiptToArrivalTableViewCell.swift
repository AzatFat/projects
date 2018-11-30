//
//  AddReceiptToArrivalTableViewCell.swift
//  Djinaro
//
//  Created by Azat on 29.11.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class AddReceiptToArrivalTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet var goodCost: UITextField!
    @IBOutlet var goodCount: UITextField!
    @IBOutlet var goodSize: UILabel!
    
    var returnValueForCost: ((_ value: String)->())?
    var returnValueForCount: ((_ value: String)->())?
    //var returnValueForSize: ((_ value: String)->())?
    override func awakeFromNib() {
        super.awakeFromNib()
        goodCount.delegate = self
        goodCost.delegate = self

        // Initialization code
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        print("end")
        returnValueForCost?(goodCost.text ?? "")
        returnValueForCount?(goodCount.text ?? "")
       // returnValueForSize?(goodSize.text ?? "") // Use callback to return data
       // returnValue?(goodCost.text ?? "")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("end")
        returnValueForCost?(goodCost.text ?? "")
        returnValueForCount?(goodCount.text ?? "")
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
