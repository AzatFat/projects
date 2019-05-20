//
//  ReportsViewController.swift
//  Djinaro
//
//  Created by Azat on 03.04.2019.
//  Copyright © 2019 Azat. All rights reserved.
//

import UIKit


protocol calendarDate {
    func changeDatesReportInterval(start_day: String, end_day: String)
}


class ReportsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, calendarDate {
    
    
 
    private let tableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    var calendarButton: UIButton = {
        let t = UIButton()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    var backButton = UIButton()
    let report = Reports()
    var reportCode = ""
    var reportsList = [reportDescription]()
    var countLablesDigits = [CGFloat]()
    var sumCountLablesDigits = CGFloat(0)
    
    @objc func backButtonAction(sender: UIButton!) {
        report.goToPreviousLevel()
        if report.currentLevel > 1 {
            getViewContent(reportCode: reportCode)
        } else {
            getReportsList()
        }
        
        
        //performSegue(withIdentifier: "toCalendar", sender: self)
    }
    
    
    @objc func calendarButtonAction(sender: UIButton!) {
        performSegue(withIdentifier: "toCalendar", sender: self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if report.currentLevel == 0 {
            getReportsList()
        } else {
            getViewContent(reportCode: reportCode)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        report.currentLevel = 0
        calendarButtonSetup()
        backButtonSetup()
        tableSetup()
        getReportsList()
        
        // Do any additional setup after loading the view.
    }
    
    func calendarButtonSetup() {
        calendarButton.frame = CGRect(x: self.view.frame.size.width - 205, y: 60, width: 200, height: 50)
        self.view.addSubview(calendarButton)
        calendarButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 68.0).isActive = true
        calendarButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5.0).isActive = true
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        calendarButton.setTitle(formatter.string(from: Date()), for: .normal)
        calendarButton.setTitleColor(UIColor.gray ,for: .normal)
        calendarButton.titleLabel?.adjustsFontSizeToFitWidth = true
        calendarButton.titleLabel?.minimumScaleFactor = 0.5
        calendarButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        calendarButton.addTarget(self, action: #selector(calendarButtonAction), for: .touchUpInside)
        
    }
    
    func backButtonSetup() {
        backButton.frame = CGRect(x:  -10, y: 60, width: 100, height: 50)
        backButton.setTitle("Вверх", for: .normal)
        backButton.setTitleColor(UIColor.gray ,for: .normal)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        self.view.addSubview(backButton)
    }
    
    func tableSetup() {

        self.view.addSubview(tableView)

        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100.0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ReportTableViewCell.self, forCellReuseIdentifier: "MyCell")
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if report.currentLevel == 0 {
            return reportsList.count
        } else {
            return report.content.count
        }
        
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if report.currentLevel == 0 {
            let cell = ReportTableViewCell(frame: CGRect(x: 0,y: 0, width: self.view.frame.width,height: 40), arrayDigits: [], sum: sumCountLablesDigits)
            cell.textLabel!.text = reportsList[indexPath.row].name
            return cell
           // print("cell text \(cell.cellLabel.text)")
        } else {
            let cell = ReportTableViewCell(frame: CGRect(x: 0,y: 0, width: self.view.frame.width,height: 40), arrayDigits: countLablesDigits, sum: sumCountLablesDigits) 
            var ind = 0
            for (key, value) in report.viewedContent[indexPath.row] {
                let k = String(describing: value)
                cell.cellLabel[ind].text = k
                cell.cellSubLable[ind].text = key
                ind += 1
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // let cell = tableView.cellForRow(at: indexPath as IndexPath)
       // print(reportsList[indexPath.row].code)
        
        if report.currentLevel == 0 {
            if let code = reportsList[indexPath.row].code, code != "" {
                reportCode = code
                report.getDefaultDaysForReport(with: reportsList[indexPath.row])
                getViewContent(reportCode: code)
            }
        } else {
            for (key) in report.paramsToNextLevel.keys {
                if let value = report.content[indexPath.row][key] {
                    let k = String(describing: value)
                    report.paramsToNextLevel[key] = k
                }
            }
            getViewContent(reportCode: reportCode)
        }
        //clicked(cell as Any)
    }
    
    @objc func clicked(_ sender: Any) {
        
        let vc = CalendarViewController()
        //vc.view.backgroundColor = UIColor.white
        vc.preferredContentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        vc.modalPresentationStyle = .popover
        let ppc = vc.popoverPresentationController
        ppc?.permittedArrowDirections = .any
        ppc?.delegate = self
        ppc!.sourceView = sender as? UIView
        ppc?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true, completion: nil)
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    
    func getReportsList() {
        report.reportsList() { (reportsList) in
            if let reportsList = reportsList {
                self.reportsList = reportsList
                //print(reportsList)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.backButton.isHidden = true
                    self.calendarButton.isHidden = true
                }
            }
        }
    }
    
    
    
    func getViewContent(reportCode: String ) {
        report.reportContent(code: reportCode) { (content) in
            if content != nil {
                DispatchQueue.main.async {
                    self.countCellLableDigits()
                    self.tableView.reloadData()
                    self.backButton.isHidden = false
                    self.calendarButton.isHidden = false
                }
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChangeNotification), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func deviceOrientationDidChangeNotification(_ notification: Any) {
        tableView.setNeedsLayout()
        backButton.setNeedsLayout()
        calendarButton.setNeedsLayout()
    }
    
    func changeDatesReportInterval(start_day: String, end_day: String) {
        report.paramsToNextLevel["date_from"] = start_day
        report.paramsToNextLevel["date_to"] = end_day
        if start_day == end_day {
            calendarButton.setTitle("\(start_day)", for: .normal)
        } else {
            calendarButton.setTitle("\(start_day) - \(end_day)", for: .normal)
        }
        getViewContent(reportCode: reportCode)
    }
    
    func countCellLableDigits() {
        var array = [CGFloat]()
        var sum = CGFloat(0)
        for indexPath in report.viewedContent {
            for (_, value) in indexPath {
                let k = String(describing: value)
                let countLenght = k.count
                array.append(CGFloat(countLenght))
                sum += CGFloat(countLenght)
            }
            break
        }
        for (i,element) in array.enumerated() {
            if CGFloat(element) > sum / 2 {
                let addNumber = (array[i] -  sum / 3) / CGFloat(array.count)
                array[i] = sum/3
                for j in array.indices {
                    array[j] += addNumber
                    
                }
            }
        }
        sumCountLablesDigits = sum
        countLablesDigits = array

    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? CalendarViewController, segue.identifier == "toCalendar" {
            controller.delegate = self
            //controller.labelString = self.stringToPass
        }
    }
    
    override func viewWillTransition( to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator ) {
        DispatchQueue.main.async() {
            self.tableView.reloadData()
        }
    }
    
    

}
