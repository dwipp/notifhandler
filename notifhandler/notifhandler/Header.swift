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
    
    static func setup() -> [String:String] {
        let header:[String:String] = [
            "sd-user-agent":self.userAgent(),
            "sd-client-UTC": SwipeCollect.getTimeZone(),
            "sd-app-id":"1808000001",
            "sd-app-secret":"4EB320AA819248AA6F7F9C412A6ADB67D83293B9441D16BB83764E6FDE9F9948",
            "Content-Type":"application/json"]
        return header
    }
}
