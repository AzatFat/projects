//
//  UserInfoViewController.swift
//  Djinaro
//
//  Created by Azat on 30.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit


 class UserInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GETMainReport  {

    let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
    var userAchivement : userListAchivements?
    
    var userSectionAchivements = ["День", "Неделя", "Месяц"]
    var timer = Timer()
    
    // Тип отчета
    enum ReportType {
        case mainReport, consultReport
    }
    
    //  Номер проваливания
    enum mainReportDrill {
        case drill_1, drill_2, drill_3
    }
    
    var drillType = mainReportDrill.drill_1
    var reportType = ReportType.consultReport
    
    // Данные для продаж консультанта
    enum TableSection: Int {
        case day = 0, week, month, total
    }
    var data = [TableSection: [userAchivements]]()
    
    // Данные для отчета для админа
    var mainReport = [mainResults]()
    var progressBar = ProgressViewController()
    var employees = [Employees]()
    var mainResultParametrs : datesForMainResult?
    var typeGoods = [TypeGoods]()
    var resultText = ""
    var resultText_2 = ""
    
    
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
           progressBar.consultant?.isHidden = true
           
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
                 self.timeUIView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 95)
                 self.tableView.reloadData()
            }
            progressBar.dateFrom?.isHidden = false
            progressBar.dateTo?.isHidden = false
            progressBar.consultant?.isHidden = false
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
        
        let user_id = self.defaults?.value(forKey:"userId") as? String ?? ""
        switch user_id {
        case "5", "7", "3":
            chanGeReportTypeOutlet.isHidden = false
        default:
            chanGeReportTypeOutlet.isHidden = true
        }
        getGoodsType()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getUserAchivements()
        scheduledTimerWithTimeInterval()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    
    func signOut() {
        self.defaults?.setValue(nil, forKey: "userName")
        self.defaults?.setValue(nil, forKey: "password")
        self.defaults?.setValue(nil, forKey: "token")
        
        let initial = ViewController()
        self.defaults?.setValue(initial.prod, forKey: "baseUrl")
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
        let token = self.defaults?.value(forKey:"token") as? String ?? ""
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
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 35))
        view.backgroundColor = UIColor(red: 232.0/255, green: 240.0/227, blue: 220.0/255.0, alpha: 0.7)
        switch reportType {
        case.consultReport:
            let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 35, height: 25))
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
        case.mainReport:
            
            let label = UILabel(frame: CGRect(x: 80, y: 0, width: tableView.bounds.width - 30, height: 25))
          //  label.font = UIFont.boldSystemFont(ofSize: 16)
            label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.thin)
            
            label.textColor = UIColor.black
            
            if drillType != mainReportDrill.drill_1 {
                
                label.text = "\(resultText) \(resultText_2)"
                let button = UIButton(frame: CGRect(x: 5, y: 0, width: 70, height: 25))
                button.setTitleColor(UIColor.blue, for: .normal)
                button.setTitle("Назад", for: .normal)
                button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                
                view.addSubview(label)
                view.addSubview(button)
            }
            
        }
        
        return view
    }
    
    @objc func buttonAction(sender: UIButton!) {
        switch drillType {
            
        case .drill_1:
            drillType = mainReportDrill.drill_1
        case .drill_2:
            mainResultParametrs?.check_type_id = nil
            drillType = mainReportDrill.drill_1
            resultText = ""
        case .drill_3:
            mainResultParametrs?.type_goods_id = nil
            drillType = mainReportDrill.drill_2
            resultText_2 = ""
        }
        GETMainResult()
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
            switch drillType {
                
            case .drill_1:
                cell.name.text = mainReport[indexPath.row].name
                cell.value.text = mainReport[indexPath.row].sum_c?.formattedAmount
                cell.count.text = String(mainReport[indexPath.row].cnt_c ?? 0)
            case .drill_2:
                cell.name.text = mainReport[indexPath.row].tg_nm
                cell.value.text = mainReport[indexPath.row].sum_c?.formattedAmount
                cell.count.text = String(mainReport[indexPath.row].cnt_c ?? 0)
            case .drill_3:
                cell.name.text = mainReport[indexPath.row].g_nm
                cell.value.text = mainReport[indexPath.row].sum_c?.formattedAmount
                cell.count.text = String(mainReport[indexPath.row].cnt_c ?? 0)
            }
        }
        
        if cell.value.text == ",00" {
            cell.value.text = "0"
        }
        if indexPath.row == mainReport.count - 1 {
            cell.value.font = UIFont.boldSystemFont(ofSize: 12.0)
            cell.name.font = UIFont.boldSystemFont(ofSize: 12.0)
            cell.count.font = UIFont.boldSystemFont(ofSize: 12.0)
        } else {
            cell.value.font = UIFont.systemFont(ofSize: 12.0)
            cell.name.font = UIFont.systemFont(ofSize: 12.0)
            cell.count.font = UIFont.systemFont(ofSize: 12.0)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch reportType {
        case .mainReport:
            //let cell = tableView.cellForRow(at: indexPath as IndexPath)
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            if var parametrs = mainResultParametrs, indexPath.row != mainReport.count - 1{
                
                switch drillType {
                case .drill_1:
                    parametrs.check_type_id = mainReport[indexPath.row].check_type_id
                    drillType = mainReportDrill.drill_2
                    resultText = mainReport[indexPath.row].name ?? ""
                case .drill_2:
                    parametrs.type_goods_id = mainReport[indexPath.row].type_goods_id
                    drillType = mainReportDrill.drill_3
                    resultText_2 =   "-> \(mainReport[indexPath.row].tg_nm ?? "")"
                case .drill_3:
                    print("")
                }
                
                mainResultParametrs = parametrs
                GETMainResult()
            }
            
        case .consultReport:
            print("")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ProgressViewController, segue.identifier == "timeSegue" {
            self.progressBar = controller
            controller.delegate = self
            //controller.labelString = self.stringToPass
        }
    }
    
    func updateMainResultParametrs(mainParametrs: datesForMainResult) {
        var parametrs = mainParametrs
        parametrs.check_type_id = mainResultParametrs?.check_type_id
        parametrs.type_goods_id = mainResultParametrs?.type_goods_id
        mainResultParametrs = parametrs
    }
    
    func GETMainResult() {
        let receiptController = ReceiptController(useMultiUrl: true)
        let token = self.defaults?.value(forKey:"token") as? String ?? ""
        if let parametrs = mainResultParametrs {
            receiptController.POSTMainReport(token: token, post: parametrs) { (mainResults) in
                if var mainResults = mainResults {
                    print(mainResults)
                    
                    if self.drillType == mainReportDrill.drill_2 {
                        for (n, result) in mainResults.records.enumerated() {
                            for typeGood in self.typeGoods {
                                if result.tg_nm == typeGood.name {
                                    mainResults.records[n].type_goods_id = typeGood.id
                                    break
                                }
                            }
                        }
                    }
                    self.mainReport = mainResults.records
                    print(self.mainReport)
                    
                }
                DispatchQueue.main.async {
                    self.sumCount()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func sumCount() {
        var sum : Decimal = 0.0
        let name = "Итог"
        var count = 0
        if drillType == .drill_1 {
            sum = mainReport[0].sum_c ?? 0.0
            count = mainReport[0].cnt_c ?? 0
            if mainReport.count > 1 {
                for (n,i) in mainReport.enumerated() {
                    if n > 1 {
                        sum -= i.sum_c ?? 0.0
                        count -= i.cnt_c ?? 0
                    }
                }
            }
        } else {
            for i in mainReport {
                sum += i.sum_c ?? 0.0
                count += i.cnt_c ?? 0
            }
        }
        let result = mainResults.init(check_type_id: nil, type_goods_id: nil, name: name, tg_nm: name, g_nm: name, cnt_c: count, sum_c: sum)
        
        mainReport.append(result)
    }
    
    func getGoodsType() {
        let receiptController = ReceiptController(useMultiUrl: true)
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        let token = defaults?.value(forKey:"token") as? String ?? ""
        receiptController.GETTypeGoods(token: token) { (typeGoods) in
            if let typeGoods = typeGoods {
                self.typeGoods = typeGoods
            }
        }
    }
}
