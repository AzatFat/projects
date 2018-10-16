//
//  GoodsArrivalTableViewCell.swift
//  Djinaro
//
//  Created by Azat on 13.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class GoodsArrivalTableViewCell: UITableViewCell {

    @IBOutlet var arrivalName: UILabel!
    @IBOutlet var arrivalPrise: UILabel!
    @IBOutlet var arrivalDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
