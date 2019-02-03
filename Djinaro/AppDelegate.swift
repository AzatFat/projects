//
//  AppDelegate.swift
//  Djinaro
//
//  Created by Azat on 21.09.2018.
//  Copyright © 2018 Azat. All rights reserved.
//

import UIKit
import UserNotifications

enum Identifiers {
    static let viewAction = "VIEW_IDENTIFIER"
    static let coustomNotification = "reportsURL"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        registerForPushNotifications()
        
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
/// Регистрация токена для пуш уведомлений
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
        ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        let defaults = UserDefaults.init(suiteName: "group.djinaroWidget")
        defaults?.setValue(token, forKey: "deviceToken")
        let tokenApp = defaults?.value(forKey:"token") as? String ?? ""
        let receiptController = ReceiptController(useMultiUrl: true)
        let addedDeviceToken = DeviceToken.init(device_token: token)
        receiptController.POSTDeviceSize(token: tokenApp, deviceToken: addedDeviceToken) { (answer) in
            if let answer = answer {
                print("token sent")
            }
        }
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }

    func registerForPushNotifications() {
        UNUserNotificationCenter.current() // 1
            .requestAuthorization(options: [.alert, .sound, .badge]) { // 2
                [weak self] granted, error in
                
                print("Permission granted: \(granted)")
                guard granted else { return }
                // 1
                let viewAction = UNNotificationAction(
                    identifier: Identifiers.viewAction, title: "View",
                    options: [.foreground])
                
                // 2
                let newsCategory = UNNotificationCategory(
                    identifier: Identifiers.coustomNotification, actions: [viewAction],
                    intentIdentifiers: [], options: [])
                
                // 3
                UNUserNotificationCenter.current().setNotificationCategories([newsCategory])
                self?.getNotificationSettings()
                
        }
    }
    
   
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // 1
        let userInfo = response.notification.request.content.userInfo
        
        // 2
        if let aps = userInfo["aps"] as? [String: AnyObject] {
            print(aps)
            
           // (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
            let url = aps["link_url"] as? String
            let category = aps["category"] as? String
            if category == Identifiers.coustomNotification,
                let url = URL(string: url ?? "http://192.168.88.190/rmk/new#") {
                let safari = WenderSafariViewController(url: url)
                
                window?.topViewController()?.present(safari, animated: true, completion: nil)
                
            }
        }
        
        // 4
        completionHandler()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}

extension UIWindow {
    func topViewController() -> UIViewController? {
        var top = self.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }
}
