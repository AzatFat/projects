//
//  CustomerTableViewCell.swift
//  Djinaro
//
//  Created by Azat on 06.11.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class CustomerTableViewCell: UITableViewCell {
    @IBOutlet var customerName: UILabel!
    @IBOutlet var customerPhone: UILabel!
    @IBOutlet var customerEmail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
