//
//  ReportTableViewCell.swift
//  Djinaro
//
//  Created by Azat on 17.04.2019.
//  Copyright © 2019 Azat. All rights reserved.
//

import UIKit

class ReportTableViewCell: UITableViewCell {

    
    var cellLabel: [UILabel] = []
    var cellSubLable : [UILabel] = []
    
    init(frame: CGRect, arrayDigits: [CGFloat], sum: CGFloat) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
        let numberOfcoulumns = arrayDigits.count
        
        var sumCounted = CGFloat(10)
        for i in 0 ..< numberOfcoulumns {
            let x_pos = sumCounted
            let x_width = (frame.width - 20) * arrayDigits[i]/sum
            
            cellLabel.append(UILabel(frame: CGRect(x: x_pos, y: 0, width: x_width * 0.9, height: 40)))
            cellSubLable.append(UILabel(frame: CGRect(x: x_pos, y: 20, width: x_width * 0.9, height: 40)))
            
            sumCounted += x_width
            
          // cellLabel[i].translatesAutoresizingMaskIntoConstraints = false

            
            cellLabel[i].textColor = UIColor.black
            cellLabel[i].textAlignment = .left
            cellLabel[i].font = cellLabel[i].font.withSize(11)
            cellLabel[i].numberOfLines = 2
            
            cellSubLable[i].textColor = UIColor.gray
            cellSubLable[i].textAlignment = .left
            cellSubLable[i].font = cellLabel[i].font.withSize(9)
            cellSubLable[i].numberOfLines = 1
            
            addSubview(cellLabel[i])
            addSubview(cellSubLable[i])
          /*  NSLayoutConstraint.activate([
                // label width is 70% width of cell
                cellLabel[i].leftAnchor.constraint(equalTo: leftAnchor, constant: frame.width * CGFloat(i)/CGFloat(numberOfcoulumns)),
                cellLabel[i].widthAnchor.constraint(equalTo: widthAnchor, multiplier: frame.width / CGFloat(numberOfcoulumns))
                ])*/
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
   //     cellLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100.0, height: 40))
//        cellLabel.textColor = UIColor.red
 //       addSubview(cellLabel)
    }
    


}
