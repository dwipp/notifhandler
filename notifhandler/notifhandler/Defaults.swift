//
//  Defaults.swift
//  FirebaseCore
//
//  Created by Dwi Permana Putra on 18/10/18.
//

import Foundation
import FirebaseRemoteConfig

struct Key {
    let value:String
    static let IDFAkey = Key(value: "swipedk-idfa")
    static let publicID = Key(value: "swipedk-public-id")
    static let sessionID = Key(value: "swipedk-session-id")
    static let silentDateFirst = Key(value: "swipedk-silent-first")
    static let silentDateCurrent = Key(value: "swipedk-silent-current")
    static let configContact = Key(value: "swipedk-config-contact")
    static let configContactCurrent = Key(value: "swipedk-config-contact-current")
    static let configBookmark = Key(value: "swipedk-config-bookmark")
    static let configBookmarkCurrent = Key(value: "swipedk-config-bookmark-current")
    static let configSms = Key(value: "swipedk-config-sms")
    static let configSmsCurrent = Key(value: "swipedk-config-sms-current")
    
}

class Defaults {
    private init(){}
    
    private static var config:RemoteConfig!
    private static let configKey = "schedule_data_sync"//_ios"
    
    static func string(forKey key:Key) -> String? {
        return UserDefaults.standard.string(forKey: key.value)
    }
    
    static func double(forKey key:Key) -> Double? {
        return UserDefaults.standard.double(forKey: key.value)
    }
    
    static func set(_ value:Any, forKey key:Key) {
        UserDefaults.standard.set(value, forKey: key.value)
    }
    
    static func getConfig(){
        config = RemoteConfig.remoteConfig()
//        config.setDefaults(fromPlist: "remoteConfigDefaults")
        config.fetch(withExpirationDuration: TimeInterval(600)) { (status, error) in
            guard status == RemoteConfigFetchStatus.success else {
                return
            }
            self.config.activateFetched()
            
            do{
                let data =  self.config[self.configKey].dataValue
                let conf = try JSONDecoder().decode(ConfigModel.self, from: data)
                
                var contact = conf.contact
                if let timeContact = contact.popLast() {
                    let time = buildTimeSchedule(forValue: contact, timeElement: timeContact)
                    set(time, forKey: .configContactCurrent)
                }
                var bookmark = conf.bookmark
                if let timeBookmark = bookmark.popLast() {
                    let time = buildTimeSchedule(forValue: bookmark, timeElement: timeBookmark)
                    set(time, forKey: .configBookmarkCurrent)
                }
                var sms = conf.sms
                if let timeSMS = sms.popLast() {
                    let time = buildTimeSchedule(forValue: sms, timeElement: timeSMS)
                    set(time, forKey: .configSmsCurrent)
                }
                
                print("contact: \(self.double(forKey: .configContact))")
                
            }catch let err {
                print("SwipeDK error: \(err)")
            }
            
            
        }
    }
    
    static private func buildTimeSchedule(forValue value:String, timeElement element:String.Element)->Double{
        let val = Double(value) ?? 0
        if element == "m" {
            return val * 60
        }else if element == "h" {
            return val * 3600
        }else if element == "d" {
            return val * 86400
        }else {
            //undefined
            return 0.0
        }
    }
}
