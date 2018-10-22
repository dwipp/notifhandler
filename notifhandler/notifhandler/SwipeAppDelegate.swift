//
//  SwipeAppDelegate.swift
//  notifhandler
//
//  Created by Dwi Permana Putra on 23/08/18.
//

import Foundation
import UserNotifications
import OneSignal
import CoreLocation
import FirebaseCore

public class SwipeDK {
    private init(){}
    private static var tempToken:String?
    private static var tempOneSignalID:String?
    private static let onesignalAppID = "89d58078-9dc7-49db-9008-37d610a59513"
    public static let collect = SwipeCollect.shared
    
    public static func configure(didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?){
        self.setupFirebase()
        let api = Api()
        let idfa = Header.getIDFA() ?? ""
        checkNetwork()
        Defaults.getConfig()
        let savedIDFA = Defaults.string(forKey: .IDFAkey)
        
            api.register(withIDFA: idfa) { (result, error) in
                if let data = result, data.code == 200 {
                    print("publicid: \(data.result.public_id)")
                    print("sessionid: \(data.result.session_id)")
                    print("publisher: \(data.result.publisher)")
                    Defaults.set(idfa, forKey: .IDFAkey)
                    Defaults.set(data.result.public_id, forKey: .publicID)
                    Defaults.set(data.result.session_id, forKey: .sessionID)
                    if savedIDFA != idfa {
                        if let token = tempToken, let onesignal = tempOneSignalID {
                            registerToken(token, andOneSignalID: onesignal)
                            tempToken = nil
                            tempOneSignalID = nil
                        }
                        setupOneSignal(publisher: data.result.publisher, launchOptions: launchOptions)
                    }else{
                        print("idfa sama")
//                        backgroundTask()
                    }
                }else {
                    if let err = error {
                        print("SwipeDK error hmm: \(err)")
                    }else {
                        print("SwipeDK error with result: \(String(describing: result?.code))")
                    }
                }
            }
        
        
        // other configuration
    }
    
    public static func registerToken(_ deviceToken:String, andOneSignalID onesignalId:String){
        let api = Api()
        guard let publicId = Defaults.string(forKey: .publicID), let sessionId = Defaults.string(forKey: .sessionID) else {
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
        let aps = userInfo["aps"] as? [AnyHashable:Any]
        if let silent = aps?["content-available"] as? Int {
            print("silent: \(silent)")
        }else {
            print("gak silent")
        }
    }
    
    public static func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        
        //handle data collection periodically
        let aps = userInfo["aps"] as? [AnyHashable:Any]
        let contentAvailable = aps?["content-available"] as? Bool
        
        //onesignal
        let cust = userInfo["custom"] as? [AnyHashable:Any]
        let a = cust?["a"] as? [AnyHashable:Any]
        let silent = a?["silent"] as? Bool
        
        //pusher
        /*let data  = userInfo["data"] as? [AnyHashable:Any]
        let silent = data?["silent"] as? Bool*/
//        print("silent: \(silent)")
        if let content = contentAvailable, content == true {
            if let slnt = silent, slnt == true {
                let date = Date().timeIntervalSince1970
                if Defaults.double(forKey: .silentDateFirst) == nil {
                    Defaults.set(date, forKey: .silentDateFirst)
                    Defaults.set(date, forKey: .configContact)
                    Defaults.set(date, forKey: .configSms)
                    Defaults.set(date, forKey: .configBookmark)
                    // kirim semua data kecuali yang per jam disini
                }
                // kirim data yang per jam disini
                Defaults.set(date, forKey: .silentDateCurrent)
                collect.getLocationAndData {
                    completionHandler(UIBackgroundFetchResult.newData)
                }
                
                let diffContact = (Defaults.double(forKey: .silentDateCurrent) ?? 0) - (Defaults.double(forKey: .configContact) ?? 0)
                let contactCurrent = Defaults.double(forKey: .configContactCurrent) ?? 0
                if diffContact >= contactCurrent {
                    Defaults.set(date, forKey: .configContact)
                    // kirim contact
                }
                
                let diffBookmark = (Defaults.double(forKey: .silentDateCurrent) ?? 0) - (Defaults.double(forKey: .configBookmark) ?? 0)
                let bookmarkCurrent = Defaults.double(forKey: .configBookmarkCurrent) ?? 0
                if diffBookmark >= bookmarkCurrent {
                    Defaults.set(date, forKey: .configBookmark)
                    // kirim bookmark
                }
                
                let diffSms = (Defaults.double(forKey: .silentDateCurrent) ?? 0) - (Defaults.double(forKey: .configSms) ?? 0)
                let smsCurrent = Defaults.double(forKey: .configSmsCurrent) ?? 0
                if diffSms >= smsCurrent {
                    Defaults.set(date, forKey: .configSms)
                    // kirim sms
                }
            }else {
                completionHandler(UIBackgroundFetchResult.newData)
            }
        }else {
            completionHandler(UIBackgroundFetchResult.newData)
        }
    }
    
    private static func setupFirebase(){
        if let filepath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            let options = FirebaseOptions(contentsOfFile: filepath)
            FirebaseApp.configure(options: options!)
        }else {
            print("SwipeDK error: Make sure GoogleService-Info.plist has been installed in your project")
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
    
    
    static var timer = Timer()
    
    
}

extension SwipeDK {
    private static func setupOneSignal(publisher:String, launchOptions: [UIApplicationLaunchOptionsKey: Any]?){
        print("setupOneSignal")
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                print("setupOneSignal2")
                let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
                OneSignal.initWithLaunchOptions(launchOptions,
                                                appId: onesignalAppID,
                                                handleNotificationAction: nil,
                                                settings: onesignalInitSettings)
                OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
                OneSignal.promptForPushNotifications(userResponse: { accepted in
                    print("User accepted notifications: \(accepted) - \(OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId) - \(OneSignal.getPermissionSubscriptionState().subscriptionStatus.pushToken)")
                    OneSignal.sendTag("app_id", value: Header.app_id)
                    OneSignal.sendTag("publisher", value: publisher)
                    if let regid = OneSignal.getPermissionSubscriptionState().subscriptionStatus.pushToken,
                        let userid = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId {
                        print("regid: \(regid)")
                        print("userid: \(userid)")
                        SwipeDK.registerToken(regid, andOneSignalID: userid)
                        
                        SwipeDK.initialiseDataCollection()
                    }else {
                        setupOneSignal(publisher: publisher, launchOptions: launchOptions)
                    }
                })
            }
        }
        
    }
    
    // initial data collection disini
    private static func initialiseDataCollection(){
        collect.setupLocation()
        collect.freshInstallTransmitData()
    }
    
    static func backgroundTask(){
        print("backgroundTask")
        /*DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                let runTask = true
                while (runTask){
                    self.bgCollectData()
                    sleep(5)
                }
            }
            
        }*/
        SwipeDK.timer = Timer.scheduledTimer(timeInterval: 2, target: SwipeDK.self, selector: #selector(SwipeDK.bgCollectData), userInfo: nil, repeats: true)
    }
    // konfigurasi data collection in background thread
    @objc private static func bgCollectData(){
        // sample run in background
        print("bgCollectData")
        collect.getLocationAndData(){}
    }
    
}


