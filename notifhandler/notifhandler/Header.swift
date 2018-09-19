//
//  UserAgent.swift
//  notifhandler
//
//  Created by Dwi Permana Putra on 18/08/18.
//  Copyright © 2018 Ropen Indonesia. All rights reserved.
//

import Foundation

struct Header {
    static public let app_id = "1808000001"
    
    
    static private func CFNetwork() -> String {
        let dictionary = Bundle(identifier: "com.apple.CFNetwork")?.infoDictionary!
        let version = dictionary?["CFBundleShortVersionString"] as! String
        return "CFNetwork/\(version)"
    }
    
    static private func deviceVersion() -> String {
        let currentDevice = UIDevice.current
        return "\(currentDevice.systemName)/\(currentDevice.systemVersion)"
    }
    
    
    
    static private func appName() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let name = dictionary["CFBundleName"] as! String
        return "\(name)/\(version)"
    }
    
    static private func userAgent() -> String {
        return "\(appName()) \(SwipeCollect.shared.getDeviceName()) \(deviceVersion()) \(CFNetwork()) \(SwipeCollect.shared.getKernel())"
    }
    
    static func setup() -> [String:String] {
        let header:[String:String] = [
            "sd-user-agent":self.userAgent(),
            "sd-client-UTC": SwipeCollect.shared.getTimeZone(),
            "sd-app-id":app_id,
            "sd-app-secret":"4EB320AA819248AA6F7F9C412A6ADB67D83293B9441D16BB83764E6FDE9F9948",
            "Content-Type":"application/json"]
        return header
    }
}
