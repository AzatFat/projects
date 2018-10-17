//
//  ArrivalInfoTableViewCell.swift
//  Djinaro
//
//  Created by Azat on 16.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class ArrivalInfoTableViewCell: UITableViewCell {

    @IBOutlet var arrivalGood: UILabel!
    
    @IBOutlet var arrivalCost: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
