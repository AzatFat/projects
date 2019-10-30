//
//  BaseTableViewCell.swift
//  Djinaro
//
//  Created by azat fatykhov on 07/10/2019.
//  Copyright © 2019 Azat. All rights reserved.
//

import UIKit
import Foundation

class BaseTableViewCell <V : CellConfigurations> : UITableViewCell {
    var item: V!
}


