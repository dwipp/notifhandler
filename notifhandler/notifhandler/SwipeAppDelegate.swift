//
//  SwipeAppDelegate.swift
//  notifhandler
//
//  Created by Dwi Permana Putra on 23/08/18.
//

import Foundation
import AdSupport
import UserNotifications


public class SwipeDK {
    private init(){}
    private static var tempToken:String?
    private static var tempOneSignalID:String?
    
    public static func configure(){
        let api = Api()
        let idfa = getIDFA()
        let savedIDFA = UserDefaults.standard.string(forKey: api.IDFAkey)
        if savedIDFA != idfa {
            api.register(withIDFA: idfa) { (result, error) in
                if let data = result, data.code == 200 {
                    print("publicid: \(data.result.public_id)")
                    print("sessionid: \(data.result.session_id)")
                    UserDefaults.standard.set(idfa, forKey: api.IDFAkey)
                    UserDefaults.standard.set(data.result.public_id, forKey: api.publicID)
                    UserDefaults.standard.set(data.result.session_id, forKey: api.sessionID)
                    if let token = tempToken, let onesignal = tempOneSignalID {
//                        application(UIApplication(), didRegisterForRemoteNotificationsWithDeviceToken: token)
                        registerToken(token, andOneSignalID: onesignal)
                        tempToken = nil
                        tempOneSignalID = nil
                    }
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
    
    /*public static func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let api = Api()
        guard let publicId = UserDefaults.standard.string(forKey: api.publicID), let sessionId = UserDefaults.standard.string(forKey: api.sessionID) else {
            tempToken = deviceToken
            return
        }
        let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        api.registerToken(token, onesignalId: "", publicId: publicId, sessionId: sessionId) { (result, error) in
            tempToken = nil
            if let data = result, data.code == 200 {
            }else {
                if let err = error {
                    print("SwipeDK error: \(err)")
                }else {
                    print("SwipeDK error with result: \(String(describing: result?.code))")
                }
            }
        }
    }*/
    
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
    
}
