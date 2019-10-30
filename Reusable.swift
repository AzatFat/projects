//
//  Reusable.swift
//  Djinaro
//
//  Created by azat fatykhov on 07/10/2019.
//  Copyright © 2019 Azat. All rights reserved.
//

import Foundation
import UIKit

protocol Reusable {}

extension Reusable where Self: UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
extension UITableViewCell: Reusable {}

protocol CellConfigurations {
    var completion: () -> () { get }
    var cellHeight: CGFloat { get }
}

extension CellConfigurations {
    var cellHeight : CGFloat {
        return 60
    }
}

extension UITableView {
    func register <T: UITableViewCell>(_ : T.Type) {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not deque cell with identifier")
        }
        
        return cell
    }
}
