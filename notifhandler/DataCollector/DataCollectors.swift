//
//  DataCollectors.swift
//  notifhandler
//
//  Created by Dwi Permana Putra on 03/09/18.
//

import Foundation


struct SwipeCollect {
    static func getTimeZone()->String{
        var utcInSecond = TimeZone.current.secondsFromGMT()
        var frontPrefix = "+"
        if utcInSecond < 0 {
            frontPrefix = "-"
            utcInSecond = utcInSecond * -1
        }
        
        let hourInt = utcInSecond/3600
        var hour = "\(hourInt)"
        if hourInt < 10 {
            hour = "0\(hourInt)"
        }
        
        let minuteInt = (utcInSecond%3600)/60
        var minute = "\(minuteInt)"
        if minuteInt < 10 {
            minute = "0\(minuteInt)"
        }
        
        return frontPrefix + "\(hour):\(minute)"
    }
    
    static func getLanguage() -> String?{
        return Locale.current.languageCode
    }
    
    static func getCountry() -> String?{
        return Locale.current.regionCode
    }
    
    static func getNetworkType() -> String{
        guard let status = Network.reachability?.status else {return "run in simulator"}
        switch status {
        case .unreachable:
            return status.rawValue
        case .wifi:
            return "\(status.rawValue) \(Network.reachability?.getWiFiSsid() ?? "")"
        case .wwan:
            return "\(status.rawValue) \(Network.reachability?.getTelephonyNetwork() ?? "")"
        }
    }
    
    static func getLocation(){
        
    }
}
