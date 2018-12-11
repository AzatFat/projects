//
//  ProgressViewController.swift
//  Djinaro
//
//  Created by Azat on 11.12.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit

import MBCircularProgressBar


class ProgressViewController: UIViewController {
    @IBOutlet var timeLeft: MBCircularProgressBarView!
    @IBOutlet var moneyEarn: MBCircularProgressBarView!
    let defaults = UserDefaults.standard
    //var userInfoView = UserInfoViewController()
    var timer = Timer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeLeft.value = 100
        moneyEarn?.value = 0
        moneyEarn?.unitString = ""
        getTimeRemaining()

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        getTimeRemaining()
        scheduledTimerWithTimeInterval()
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.getTimeRemaining), userInfo: nil, repeats: true)
    }

    @objc func getTimeRemaining() {
        let receiptController = ReceiptController(useMultiUrl: true)
        let token = self.defaults.object(forKey:"token") as? String ?? ""
        receiptController.GETtimeRemaning(token: token) { (timeRemaining ) in
            if let timeRemaining = timeRemaining {
                let time = timeRemaining.remaining_time.components(separatedBy: ":")
                let hours = Int(time[0])!
                let minutes = Int(time[1])!
                let allMinutes = hours < 0 ? hours * 60 - minutes : hours * 60 + minutes
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 2.0) {
                        self.timeLeft.value = CGFloat(100 * allMinutes/480)
                        if self.timeLeft.value < CGFloat(truncating: 25) {
                            self.timeLeft.progressColor = UIColor.red
                            self.timeLeft.progressStrokeColor = UIColor.red
                        } else if self.timeLeft.value < CGFloat(truncating: 50) {
                            self.timeLeft.progressColor = UIColor.orange
                            self.timeLeft.progressStrokeColor = UIColor.orange
                        } else if self.timeLeft.value < CGFloat(truncating: 75){
                            self.timeLeft.progressColor = UIColor.cyan
                            self.timeLeft.progressStrokeColor = UIColor.cyan
                        } else {
                            self.timeLeft.progressColor = UIColor.init(red: 215.0/255.0, green: 131.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                            self.timeLeft.progressStrokeColor = UIColor.init(red: 215.0/255.0, green: 131.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                        }
                    }
                }
            }
        }
    }
    
    func getMoneyEarned(moneyEarned : Decimal) {
        print("getMoneyEarned called")
        let money = moneyEarned.formattedAmount
        guard let money_earned = NumberFormatter().number(from: money!) else { return }
        DispatchQueue.main.async {
            UIView.animate(withDuration: 2.0) {
                self.moneyEarn.value = CGFloat(truncating: money_earned)
                if self.moneyEarn.value < CGFloat(truncating: 700) {
                    self.moneyEarn.progressColor = UIColor.red
                    self.moneyEarn.progressStrokeColor = UIColor.red
                } else if self.moneyEarn.value < CGFloat(truncating: 1000) {
                    self.moneyEarn.progressColor = UIColor.orange
                    self.moneyEarn.progressStrokeColor = UIColor.orange
                } else if self.moneyEarn.value < CGFloat(truncating: 1300){
                    self.moneyEarn.progressColor = UIColor.cyan
                    self.moneyEarn.progressStrokeColor = UIColor.cyan
                } else {
                    self.moneyEarn.progressColor = UIColor.init(red: 215.0/255.0, green: 131.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                    self.moneyEarn.progressStrokeColor = UIColor.init(red: 215.0/255.0, green: 131.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                }
            }
        }
    }
}
