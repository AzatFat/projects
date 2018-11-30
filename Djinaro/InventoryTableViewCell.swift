//
//  InventoryTableViewCell.swift
//  Djinaro
//
//  Created by Azat on 27.11.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class InventoryTableViewCell: UITableViewCell {
    @IBOutlet var inventoryGoodName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       // cell.layer.opacity = 0.3
       // view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
