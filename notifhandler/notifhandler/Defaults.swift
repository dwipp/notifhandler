//
//  Defaults.swift
//  FirebaseCore
//
//  Created by Dwi Permana Putra on 18/10/18.
//

import Foundation

struct Key {
    let value:String
    static let IDFAkey = Key(value: "swipedk-idfa")
    static let publicID = Key(value: "swipedk-public-id")
    static let sessionID = Key(value: "swipedk-session-id")
    static let pushSilentFirst = Key(value: "swipedk-silent-first")
    static let pushSilentCurrent = Key(value: "swipedk-silent-current")
}

class Defaults {
    private init(){}
    static func string(forKey key:Key) -> String? {
        return UserDefaults.standard.string(forKey: key.value)
    }
    
    static func double(forKey key:Key) -> Double? {
        return UserDefaults.standard.double(forKey: key.value)
    }
    
    static func set(_ value:Any, forKey key:Key) {
        UserDefaults.standard.set(value, forKey: key.value)
    }
}
