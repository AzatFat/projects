//
//  CheckListTableViewCell.swift
//  Djinaro
//
//  Created by Azat on 05.11.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

class CheckListTableViewCell: UITableViewCell {

    @IBOutlet var Cost: UILabel!
    @IBOutlet var Time: UILabel!
    @IBOutlet var CheckId: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
