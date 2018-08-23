//
//  UserAgent.swift
//  notifhandler
//
//  Created by Dwi Permana Putra on 18/08/18.
//  Copyright © 2018 Ropen Indonesia. All rights reserved.
//

import Foundation

struct Header {
    static private func darwin() -> String {
        var sysinfo = utsname()
        uname(&sysinfo)
        let dv = String(bytes: Data(bytes: &sysinfo.release, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
        return "Darwin/\(dv)"
    }
    
    static private func CFNetwork() -> String {
        let dictionary = Bundle(identifier: "com.apple.CFNetwork")?.infoDictionary!
        let version = dictionary?["CFBundleShortVersionString"] as! String
        return "CFNetwork/\(version)"
    }
    
    static private func deviceVersion() -> String {
        let currentDevice = UIDevice.current
        return "\(currentDevice.systemName)/\(currentDevice.systemVersion)"
    }
    
    static private func deviceName() -> String {
        var sysinfo = utsname()
        uname(&sysinfo)
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    static private func appName() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let name = dictionary["CFBundleName"] as! String
        return "\(name)/\(version)"
    }
    
    static private func userAgent() -> String {
        return "\(appName()) \(deviceName()) \(deviceVersion) \(CFNetwork()) \(darwin())"
    }
    
    static private func clientUTC()->String{
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
    
    static func setup() -> [String:String] {
        let header:[String:String] = [
            "sd-user-agent":self.userAgent(),
            "sd-client-UTC": clientUTC(),
            "sd-app-id":"1808000001",
            "sd-app-secret":"4EB320AA819248AA6F7F9C412A6ADB67D83293B9441D16BB83764E6FDE9F9948",
            "Content-Type":"application/json"]
        return header
    }
}
