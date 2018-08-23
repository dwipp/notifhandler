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
    
    public static func configure(){
        let api = Api()
        let idfa = getIDFA()
        let savedIDFA = UserDefaults.standard.string(forKey: api.IDFAkey)
        if savedIDFA != idfa {
            api.register(withIDFA: idfa) { (result, error) in
                if let data = result, data.code == 200 {
                    UserDefaults.standard.set(idfa, forKey: api.IDFAkey)
                    UserDefaults.standard.set(data.result.public_id, forKey: api.publicID)
                    UserDefaults.standard.set(data.result.session_id, forKey: api.sessionID)
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
    
    public static func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        let aps = userInfo["aps"] as? [AnyHashable:Any]
        SwipeConfiguration.notifClicked(withPushID: aps!["push_id"] as! String)
    }
    
    private static func getIDFA()->String {
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        } else {
            return ""
        }
    }
    
}
