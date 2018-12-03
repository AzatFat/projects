//
//  UserInfoViewController.swift
//  Djinaro
//
//  Created by Azat on 30.10.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit




class UserInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    

    let defaults = UserDefaults.standard
    var userAchivement : userListAchivements?
    var userSectionAchivements = ["День", "Неделя", "Месяц"]
    var timer = Timer()
    enum TableSection: Int {
        case day = 0, week, month, total
    }
    
    var data = [TableSection: [userAchivements]]()
    
    @IBOutlet var tableView: UITableView!
    @IBAction func logOut(_ sender: Any) {
        signOut()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserAchivements()
        scheduledTimerWithTimeInterval()
        
        // defaults.set(nil, forKey: "token")
        // Do any additional setup after loading the view.
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
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDel.window?.rootViewController = loginVC
    }
    
    
    func scheduledTimerWithTimeInterval(){
    // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
    timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.getUserAchivements), userInfo: nil, repeats: true)
    }
    
    @objc func getUserAchivements() {
        let receiptController =  ReceiptController()
        let token = self.defaults.object(forKey:"token") as? String ?? ""
        receiptController.GetReportPersonal(token: token) { (userListAchivemnts) in
            
            if let userAchivement = userListAchivemnts {
                //print(userAchivement)
                self.userAchivement = userAchivement[0]
                self.data[.day] = userAchivement[0].day
                self.data[.week] = userAchivement[0].week
                self.data[.month] = userAchivement[0].month
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return TableSection.total.rawValue
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let tableSection = TableSection(rawValue: section), let typeAchivements = data[tableSection] {
            return typeAchivements.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    }
    
    
    /*
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return userSectionAchivements[section]
    }*/
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "userAchivement"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UserAchivementsTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GoodsArrivalTableViewCell.")
        }
        if let tableSection = TableSection(rawValue: indexPath.section), let achive = data[tableSection]?[indexPath.row] {
            cell.name.text = achive.name
            cell.value.text = achive.value?.formattedAmount
            if cell.value.text == ",00" {
                cell.value.text = "0"
            }
        }
        // print(CostEachreceipt.inn(forKey: indexPath.row))
        return cell
    }

}
