//
//  UIColourExtension.swift
//  Djinaro
//
//  Created by Azat on 06.04.2019.
//  Copyright © 2019 Azat. All rights reserved.
//
import UIKit
import Foundation
extension UIColor {
    convenience init(colorWIthHexValue value: Int, alpha: CGFloat = 1.0 ) {
        self.init(
            red: CGFloat ((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat ((value & 0x00FF00) >> 16) / 255.0,
            blue: CGFloat ((value & 0x0000FF) >> 16) / 255.0,
            alpha: alpha
        )
    }
}
