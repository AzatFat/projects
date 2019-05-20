//
//  CalendarViewController.swift
//  Djinaro
//
//  Created by Azat on 04.04.2019.
//  Copyright © 2019 Azat. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController {

    @IBOutlet var calendarView: JTAppleCalendarView!
    @IBOutlet var month: UILabel!
    @IBOutlet var year: UILabel!
    
    
    let formatter = DateFormatter()
    let outsideMonthColor = UIColor.white.withAlphaComponent(0.4)
    let monthColor = UIColor.white
    let selectedMonthColour = UIColor(colorWIthHexValue: 0x3a294b4a66)
    let currentDateSelectedViewColour = UIColor(colorWIthHexValue: 0x584a66)
    var firstDate : Date?
    var lastDate: Date?
    var currentCalendar = Calendar.current
    var delegate: ReportsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCalendarView()
    
        // Do any additional setup after loading the view.
    }

    override func viewDidDisappear(_ animated: Bool) {
        print("view disapear")
        getReportDates()
    }
    
    func setupCalendarView() {
        
        calendarView.allowsMultipleSelection = true
        
        //allow rangeSelection
        // calendarView.allowsMultipleSelection  = true
        calendarView.isRangeSelectionUsed = true
        
      //  calendarView.allowsMultipleSelection = true
        
        //scroll to date
        calendarView.scrollToDate(Date(), animateScroll: false )
        firstDate = Date()
        calendarView.selectDates([Date()])
        
        
        //setup lables
        calendarView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
        
        //setup alendar spacing
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        formatter.dateFormat = "yyyy"
        year.text = formatter.string(from: date)
        formatter.dateFormat = "MMMM"
        month.text = formatter.string(from: date)
    }
    
    func handleCellSelected(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CoustomCell else {return}
     /*   if cellState.isSelected {
            validCell.selectedView.isHidden = false
        } else {
            validCell.selectedView.isHidden = true
        }*/
        switch cellState.selectedPosition() {
        case .full, .left, .right:
            validCell.selectedView.isHidden = false
           // validCell.selectedView.backgroundColor = UIColor.yellow // Or you can put what ever you like for your rounded corners, and your stand-alone selected cell
        case .middle:
            validCell.selectedView.isHidden = false
           // validCell.selectedView.backgroundColor = UIColor.blue // Or what ever you want for your dates that land in the middle
        default:
            validCell.selectedView.isHidden = true
           // validCell.selectedView.backgroundColor = nil // Have no selection when a cell is not selected
        }
    }
    
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CoustomCell else {return}
        if cellState.isSelected {
            validCell.dateLable.textColor = selectedMonthColour
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                validCell.dateLable.textColor = monthColor
            } else {
                validCell.dateLable.textColor = outsideMonthColor
            }
            
        }
    }
    
    func getReportDates() {
        if delegate != nil {
            formatter.dateFormat = "dd.MM.yyyy"
            delegate?.changeDatesReportInterval(start_day: formatter.string(from: firstDate ?? Date()), end_day: formatter.string(from: lastDate ?? Date()))
        } else {
            print("Delegate nil")
        }
    }
    
}



extension CalendarViewController: JTAppleCalendarViewDataSource {

    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale =  Calendar.current.locale
        
        let startDate = formatter.date (from:"2018 01 01" )!
        let endDate = formatter.date (from:"2022 01 01" )!
        let parametrs = ConfigurationParameters(startDate: startDate, endDate: endDate, generateOutDates: .off, firstDayOfWeek: .monday)
        print("configureCalendar")
        return parametrs
    }
    

}
extension CalendarViewController: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CoustomCell", for: indexPath) as! CoustomCell
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        // return cell
    }
 
    
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CoustomCell", for: indexPath) as! CoustomCell
        cell.dateLable.text = cellState.text
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        return cell
        
    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CoustomCell else {return}
    //    validCell.selectedView.layer.cornerRadius = 20
  
       if firstDate != nil {
            if date > firstDate! {
                lastDate = date
            } else {
                if lastDate != nil {
                    firstDate = date
                } else {
                    lastDate = firstDate
                    firstDate = date
                }
                
            }
            calendarView.selectDates(from: firstDate!, to: lastDate!,  triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
        } else {
           firstDate = date
        }

        handleCellSelected(view: validCell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        //print("dates = \(calendarView.selectedDates), firstDate = \(firstDate)")
        //print("firstDate = \(firstDate), lastDate = \(lastDate)")
        calendar.reloadData()
        
    }
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CoustomCell else {return}
        
        if firstDate != nil && lastDate != nil  {
            if date > firstDate! && date < lastDate!{
                calendarView.deselectDates(from: date, to: lastDate, triggerSelectionDelegate: false)
                lastDate = date
                
            } else  if date == firstDate! {
                calendarView.deselectDates(from: firstDate! + 1, to: lastDate, triggerSelectionDelegate: false)
                firstDate = date
                lastDate = date
                
            } else  if date == lastDate! {
                calendarView.deselectDates(from: firstDate!, to: lastDate! - 1, triggerSelectionDelegate: false)
                firstDate = date
                lastDate = date
            }
        } else {
            firstDate = date
        }
        
        
        //    validCell.selectedView.layer.cornerRadius = 20
        handleCellSelected(view: validCell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        calendar.reloadData()
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.setupViewsOfCalendar(from: visibleDates)
        
    }
    
}
