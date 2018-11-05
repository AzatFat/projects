//
//  CheckRecordsTableViewCell.swift
//  Djinaro
//
//  Created by Azat on 05.11.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class CheckRecordsTableViewCell: UITableViewCell {

    @IBOutlet var CheckRecordCountOutlet: UITextField!
    @IBOutlet var checkRecordTotalCost: UILabel!
    @IBAction func CheckRecordCount(_ sender: Any) {
    }
    @IBOutlet var goodName: UILabel!
    @IBOutlet var size: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
