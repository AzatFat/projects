//
//  GoodsInfoTableViewCell.swift
//  Djinaro
//
//  Created by Azat on 27.09.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class GoodsInfoTableViewCell: UITableViewCell {

    @IBOutlet var size: UILabel!
    @IBOutlet var count: UILabel!
    @IBOutlet var prise: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
