//
//  SwipeAppDelegate.swift
//  notifhandler
//
//  Created by Dwi Permana Putra on 23/08/18.
//

import Foundation
import AdSupport
import UserNotifications
import OneSignal

public class SwipeDK {
    private init(){}
    private static var tempToken:String?
    private static var tempOneSignalID:String?
    private static let onesignalAppID = "89d58078-9dc7-49db-9008-37d610a59513"
    
    public static func configure(didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?){
        let api = Api()
        let idfa = getIDFA()
        checkNetwork()
        backgroundTask()
        let savedIDFA = UserDefaults.standard.string(forKey: api.IDFAkey)
        if savedIDFA != idfa {
            api.register(withIDFA: idfa) { (result, error) in
                if let data = result, data.code == 200 {
                    print("publicid: \(data.result.public_id)")
                    print("sessionid: \(data.result.session_id)")
                    print("publisher: \(data.result.publisher)")
                    UserDefaults.standard.set(idfa, forKey: api.IDFAkey)
                    UserDefaults.standard.set(data.result.public_id, forKey: api.publicID)
                    UserDefaults.standard.set(data.result.session_id, forKey: api.sessionID)
                    if let token = tempToken, let onesignal = tempOneSignalID {
                        registerToken(token, andOneSignalID: onesignal)
                        tempToken = nil
                        tempOneSignalID = nil
                    }
                    setupOneSignal(publisher: data.result.publisher, launchOptions: launchOptions)
                }else {
                    if let err = error {
                        print("SwipeDK error: \(err)")
                    }else {
                        print("SwipeDK error with result: \(String(describing: result?.code))")
                    }
                }
            }
        }else{
            print("idfa sama")
        }
    }
    
    public static func registerToken(_ deviceToken:String, andOneSignalID onesignalId:String){
        let api = Api()
        guard let publicId = UserDefaults.standard.string(forKey: api.publicID), let sessionId = UserDefaults.standard.string(forKey: api.sessionID) else {
            tempToken = deviceToken
            tempOneSignalID = onesignalId
            return
        }
        api.registerToken(deviceToken, onesignalId: onesignalId, publicId: publicId, sessionId: sessionId) { (result, error) in
            tempToken = nil
            tempOneSignalID = nil
            if let data = result, data.code == 200 {
                print("token has been registered")
            }else {
                if let err = error {
                    print("SwipeDK error: \(err)")
                }else {
                    print("SwipeDK error with result: \(String(describing: result?.code))")
                }
            }
        }
    }
    
    public static func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        let cust = userInfo["custom"] as? [AnyHashable:Any]
        let a = cust?["a"] as? [AnyHashable:Any]
        if let push_id = a?["push_id"] as? String {
            SwipeConfiguration.notifClicked(withPushID: push_id)
        }else {
            print("SwipeDK error: no push_id found!")
        }
        
    }
    
    private static func getIDFA()->String {
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        } else {
            return ""
        }
    }
    
    private static func checkNetwork(){
        do {
            Network.reachability = try Reachability(hostname: "www.google.com")
            do {
                try Network.reachability?.start()
            } catch let error as Network.Error {
                print(error)
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    private static func backgroundTask(){
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                let runTask = true
                while (runTask){
                    self.bgCollectData()
                    sleep(2)
                }
            }
            
        }
    }
    // konfigurasi data collection in background thread
    @objc private static func bgCollectData(){
        // sample run in background
        let a = SwipeCollect.getNetworkType()
        print("network: \(String(describing: a))")
    }
    
    
    
}

extension SwipeDK {
    private static func setupOneSignal(publisher:String, launchOptions: [UIApplicationLaunchOptionsKey: Any]?){
        DispatchQueue.main.async {
            let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
            OneSignal.initWithLaunchOptions(launchOptions,
                                            appId: onesignalAppID,
                                            handleNotificationAction: nil,
                                            settings: onesignalInitSettings)
            OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
            OneSignal.promptForPushNotifications(userResponse: { accepted in
                print("User accepted notifications: \(accepted)")
                if let regid = OneSignal.getPermissionSubscriptionState().subscriptionStatus.pushToken,
                    let userid = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId {
                    print("regid: \(regid)")
                    print("userid: \(userid)")
                    OneSignal.sendTag("app_id", value: onesignalAppID)
                    OneSignal.sendTag("publisher", value: publisher)
                    SwipeDK.registerToken(regid, andOneSignalID: userid)
                }
                
            })
        }
    }
}
