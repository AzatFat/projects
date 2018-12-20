//
//  UserInfoViewController.swift
//  Djinaro
//
//  Created by Azat on 30.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit


class UserInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GETMainReport  {

    let defaults = UserDefaults.standard
    var userAchivement : userListAchivements?
    
    var userSectionAchivements = ["День", "Неделя", "Месяц"]
    var timer = Timer()
    
    // Тип отчета
    enum ReportType {
        case mainReport, consultReport
    }
    var reportType = ReportType.consultReport
    
    
    // Данные для продаж консультанта
    enum TableSection: Int {
        case day = 0, week, month, total
    }
    var data = [TableSection: [userAchivements]]()
    
    // Данные для отчета для админа
    var mainReport = [mainResults]()
    
    var progressBar = ProgressViewController()
    
    @IBOutlet var chanGeReportTypeOutlet: UISegmentedControl!
    
    @IBAction func changeReportType(_ sender: Any) {
        switch chanGeReportTypeOutlet.selectedSegmentIndex
        {
        case 0:
           reportType = ReportType.consultReport
           progressBar.timeLeft.isHidden = false
           progressBar.Conversion.isHidden = false
           progressBar.moneyEarn.isHidden = false
           progressBar.timeLeftText.isHidden = false
           UIView.animate(withDuration: 1.0) {
                self.timeUIView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 320)
                self.tableView.reloadData()
           }
           progressBar.dateFrom?.isHidden = true
           progressBar.dateTo?.isHidden = true
           
         //  progressBar.
           // self.view.sendSubviewToBack()
            print("First Segment Selected")
        case 1:
            reportType = ReportType.mainReport
            progressBar.timeLeft.isHidden = true
            progressBar.Conversion.isHidden = true
            progressBar.moneyEarn.isHidden = true
            progressBar.timeLeftText.isHidden = true
            progressBar.getDefaultDaysForMaonReport()
            UIView.animate(withDuration: 0.5) {
                 self.timeUIView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
                 self.tableView.reloadData()
            }
            progressBar.dateFrom?.isHidden = false
            progressBar.dateTo?.isHidden = false
            print("Second Segment Selected")
        default:
            break
        }
    }
    
    @IBOutlet var timeUIView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBAction func logOut(_ sender: Any) {
        signOut()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserAchivements()
        scheduledTimerWithTimeInterval()
     
        
        let user_id = self.defaults.object(forKey:"userId") as? String ?? ""
        switch user_id {
        case "5", "7":
            chanGeReportTypeOutlet.isHidden = false
        default:
            chanGeReportTypeOutlet.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getUserAchivements()
        scheduledTimerWithTimeInterval()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    
    func signOut() {
        self.defaults.set(nil, forKey: "userName")
        self.defaults.set(nil, forKey: "password")
        self.defaults.set(nil, forKey: "token")
        
        let initial = ViewController()
        self.defaults.set(initial.prod, forKey: "baseUrl")
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDel.window?.rootViewController = loginVC
    }
    
    
    func scheduledTimerWithTimeInterval(){
        timer.invalidate()
    // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
    timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.getUserAchivements), userInfo: nil, repeats: true)
    }
    
    @objc func getUserAchivements() {
        let receiptController = ReceiptController(useMultiUrl: true)
        let token = self.defaults.object(forKey:"token") as? String ?? ""
        receiptController.GetReportPersonal(token: token) { (userListAchivemnts) in
            
            if let userAchivement = userListAchivemnts {
                //print(userAchivement)
                self.userAchivement = userAchivement[0]
                self.data[.day] = userAchivement[0].day
                self.data[.week] = userAchivement[0].week
                self.data[.month] = userAchivement[0].month
                DispatchQueue.main.async {
                    
                    self.progressBar.getMoneyEarned(moneyEarned: userAchivement[0].day[0].value ?? 0.0)
                    
                }
            }
            DispatchQueue.main.async {
                    self.tableView.reloadData()
            }
        }
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        switch reportType {
        case .consultReport:
            return TableSection.total.rawValue
        case .mainReport:
            return 1
        }
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch reportType {
        case.consultReport:
            if let tableSection = TableSection(rawValue: section), let typeAchivements = data[tableSection] {
                return typeAchivements.count
            }
        case.mainReport:
            return mainReport.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch reportType {
        case.consultReport:
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 25))
            view.backgroundColor = UIColor(red: 253.0/255.0, green: 240.0/255.0, blue: 196.0/255.0, alpha: 1)
            let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: 25))
            label.font = UIFont.boldSystemFont(ofSize: 15)
            label.textColor = UIColor.black
            if let tableSection = TableSection(rawValue: section) {
                switch tableSection {
                    
                case .day:
                    label.text = "Сегодняшние заслуги"
                case .week:
                    label.text = "Как ты выкладываешься за неделю"
                case .month:
                    label.text = "Чего ты добился за месяц"
                default:
                    label.text = ""
                }
            }
            view.addSubview(label)
            return view
        case.mainReport:
            return nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "userAchivement"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UserAchivementsTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GoodsArrivalTableViewCell.")
        }
        switch reportType {
        case .consultReport:
            if let tableSection = TableSection(rawValue: indexPath.section), let achive = data[tableSection]?[indexPath.row] {
                cell.name.text = achive.name
                cell.value.text = achive.value?.formattedAmount
                cell.count.text = ""
            }
        case .mainReport:
            cell.name.text = mainReport[indexPath.row].name
            cell.value.text = mainReport[indexPath.row].sum_c.formattedAmount
            cell.count.text = String(mainReport[indexPath.row].cnt_c)
        }
        
        if cell.value.text == ",00" {
            cell.value.text = "0"
        }

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ProgressViewController, segue.identifier == "timeSegue" {
            self.progressBar = controller
            controller.delegate = self
            //controller.labelString = self.stringToPass
        }
    }
    
    func GETMainResult(dates: datesForMainResult) {
        let receiptController = ReceiptController(useMultiUrl: true)
        let token = self.defaults.object(forKey:"token") as? String ?? ""
        receiptController.POSTMainReport(token: token, post: dates) { (mainResults) in
            if let mainResults = mainResults {
                print(mainResults)
                self.mainReport = mainResults.records
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
