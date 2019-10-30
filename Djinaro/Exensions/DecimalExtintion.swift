//
//  DecimalExtintion.swift
//  Djinaro
//
//  Created by azat fatykhov on 09/10/2019.
//  Copyright © 2019 Azat. All rights reserved.
//

import Foundation

extension Decimal {
    var formattedAmount: String? {
        if self == 0 {
            return "0.00"
        } else {
            let formatter = NumberFormatter()
            formatter.generatesDecimalNumbers = true
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            
            return formatter.string(from: self as NSDecimalNumber)
        }
    }
}
