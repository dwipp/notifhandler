//
//  AppDelegate.swift
//  Example
//
//  Created by Dwi Permana Putra on 15/08/18.
//  Copyright © 2018 Ropen Indonesia. All rights reserved.
//

import UIKit
import UserNotifications
import notifhandler
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        SwipeDK.configure()
        // onesignal
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "89d58078-9dc7-49db-9008-37d610a59513",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
            if let regid = OneSignal.getPermissionSubscriptionState().subscriptionStatus.pushToken,
                let userid = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId {
                print("regid: \(regid)")
                print("userid: \(userid)")
                SwipeDK.registerToken(regid, andOneSignalID: userid)
            }
            
        })
        
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { (granted, error) in
            if error == nil {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        })
        application.registerForRemoteNotifications()
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
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("token apns: \(token)")
        NotificationCenter.default.post(name: NSNotification.Name("setToken"), object: nil, userInfo: ["token":token])
//        SwipeDK.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("notif di klik: \(userInfo)")
        SwipeDK.userNotificationCenter(center, didReceive: response)
        completionHandler()
    }
}

