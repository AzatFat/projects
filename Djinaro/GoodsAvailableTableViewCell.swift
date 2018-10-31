//
//  GoodsAvailableTableViewCell.swift
//  Djinaro
//
//  Created by Azat on 31.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class GoodsAvailableTableViewCell: UITableViewCell {

    @IBOutlet var goodSize: UILabel!
    @IBOutlet var goodPrise: UILabel!
    @IBOutlet var goodCount: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
