//
//  UserAchivementsTableViewCell.swift
//  Djinaro
//
//  Created by Azat on 30.11.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class UserAchivementsTableViewCell: UITableViewCell {

    @IBOutlet var name: UILabel!
    @IBOutlet var value: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
