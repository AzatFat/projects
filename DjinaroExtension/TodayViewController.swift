//
//  TodayViewController.swift
//  DjinaroExtension
//
//  Created by Azat on 04.01.2019.
//  Copyright © 2019 Azat. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var tableView: UITableView!

    
    
    
    var daylySales = [salesDay]()
    let userName = ""
    let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        // Do any additional setup after loading the view from its nib.
        tableView.reloadData()
        
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        let userName = defaults?.value(forKey:"userName") as? String
        let password = defaults?.value(forKey:"password") as? String
        let baseUrl = defaults?.value(forKey:"baseUrl") as? String
        let token = defaults?.value(forKey:"token") as? String
        //let userId = defaults.object(forKey:"userId") as? String
        
        if token != nil {
            loadSalesData(completion: { (res) in
                if res == true {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        //self.widgetTitle.text = userName
                        completionHandler(NCUpdateResult.newData)
                    }
                } else {
                    self.signIn(userName: userName!, password: password!, NeedErrorMessage: (baseUrl != nil)) { (result) in
                        if result == true {
                            self.loadSalesData(completion: { (res) in
                                if res == true {
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                        //self.widgetTitle.text = userName
                                        completionHandler(NCUpdateResult.newData)
                                    }
                                }
                            })
                        }
                    }
                }
            })
        } else if userName != nil && password != nil && baseUrl != nil{
            signIn(userName: userName!, password: password!, NeedErrorMessage: (baseUrl != nil)) { (result) in
                if result == true {
                    self.loadSalesData(completion: { (res) in
                        if res == true {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                //self.widgetTitle.text = userName
                                completionHandler(NCUpdateResult.newData)
                            }
                        }
                    })
                }
            }
        }
      //  widgetTitle.text = "sdsdfsdf"
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            preferredContentSize = CGSize(width: 0, height: daylySales.count * 50)
          
        } else {
            preferredContentSize = maxSize
            
        }
    }
    
    func loadSalesData(completion: @escaping (_ result: Bool) -> Void) {
        let receiptController = ReceiptController(useMultiUrl: true)
        let token = defaults?.value(forKey:"token") as? String ?? ""
        receiptController.GETdaySales(token: token) { (sales) in
            if let sales = sales {
             //   print(sales)
                self.daylySales = sales
                    completion(true)
            }
        }
    }
    
    
    func signIn(userName: String, password: String, NeedErrorMessage: Bool, completion: @escaping (_ result: Bool) -> Void)  {
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                NSLog("\(cookie)")
            }
        }
        
        let storage = HTTPCookieStorage.shared
        for cookie in storage.cookies! {
            storage.deleteCookie(cookie)
        }
        
        URLCache.shared.removeAllCachedResponses()
        
        print("calling signIn function")
        let receiptController = ReceiptController(useMultiUrl: true)
        receiptController.POSTToken(username: userName, password: password) { (token) in
            print("Post Token function")
            if let token = token {
                self.defaults?.setValue(userName, forKey: "userName")
                self.defaults?.setValue(password, forKey: "password")
                self.defaults?.setValue(token.user_id, forKey: "userId")
                self.defaults?.setValue(token.access_token, forKey: "token")
                
                completion(true)
                
                if self.defaults?.value(forKey:"baseUrl") as? String == "http://192.168.88.190" || self.defaults?.value(forKey:"baseUrl") as? String == "http://91.203.195.74:5001" {
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daylySales.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "todayWidgetCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SalesTOdayTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GoodsArrivalTableViewCell.")
        }
        
        cell.name.text = daylySales[indexPath.row].e_nm
        
        if let sls_rtr = daylySales[indexPath.row].sls_rtr {
            cell.lable2.text = String(sls_rtr)
            
        }
        if let ch_p = daylySales[indexPath.row].ch_p {
            cell.lable3.text = ch_p
        }
        if let sum_zp = daylySales[indexPath.row].sum_zp {
            cell.lable4.text  = sum_zp
        }
        return cell
    }
}
