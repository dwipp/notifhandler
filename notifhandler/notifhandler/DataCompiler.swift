//
//  DataCompiler.swift
//  notifhandler
//
//  Created by Dwi Permana Putra on 18/08/18.
//  Copyright © 2018 Ropen Indonesia. All rights reserved.
//

import Foundation
import AdSupport

fileprivate class Api {
    private static let host = "http://demoaj.swipedk.com"
    private static let version = "v1"
    
    static func endpoint()->String{
        return "\(host)/sdk/api/\(version)/"
    }
    
    enum Signal:String {
        case received="2"
        case clicked="3"
        case dismiss="4"
    }
    
    enum HttpMethod:String {
        case get = "GET"
        case post = "POST"
    }
    
    static func request(withURL url:String, method:HttpMethod, params:[String:Any], completion:@escaping (_ data:Data?, _ error:Error?)->()) {
        let realUrl = URL(string: url)!
        var request = URLRequest(url: realUrl, cachePolicy: .reloadIgnoringLocalCacheData)
        request.allHTTPHeaderFields = Header.setup()
        request.httpMethod = method.rawValue
        
        var paramsData = ""
        for (key, value) in params {
            paramsData = paramsData + key + "=" + "\(value)" + "&"
        }
        paramsData.removeLast()
        request.httpBody = paramsData.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            completion(data, error)
        }
    }
    
    static func register(withIDFA idfa:String, completion:@escaping (_ result:RegistrationModel?, _ error:Error?)->()){
        let path = "register/account"
        let params = ["advertising_id":idfa]

        request(withURL: endpoint()+path, method: .post, params: params) { (data, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            do {
                let reg = try JSONDecoder().decode(RegistrationModel.self, from: data)
                completion(reg, nil)
                
            }catch let err {
                completion(nil, err)
            }
        }
    }
    
    static func notif(withSignal signal:Signal, pushId:String, publicId:String, sessionId:String, completion:@escaping (_ result:Data?, _ error:Error?)->()){
        let path = "push/set_signal"
        let params = ["signal":signal.rawValue,
                      "push_id":pushId,
                      "public_id":publicId,
                      "session_id":sessionId]
        
        request(withURL: endpoint()+path, method: .post, params: params) { (data, error) in
            completion(data, error)
        }
    }
    
}

public class SwipeDK {
    private init(){}
    private static let IDFAkey = "swipedk-idfa"
    private static let publicID = "swipedk-public-id"
    private static let sessionID = "swipedk-session-id"
    
    static func configure(){
        let idfa = getIDFA()
        let savedIDFA = UserDefaults.standard.string(forKey: IDFAkey)
        if savedIDFA != idfa {
            Api.register(withIDFA: idfa) { (result, error) in
                if let data = result {
                    UserDefaults.standard.set(idfa, forKey: IDFAkey)
                    UserDefaults.standard.set(data.public_id, forKey: publicID)
                    UserDefaults.standard.set(data.session_id, forKey: sessionID)
                }else {
                    
                }
            }
        }
        
    }
    
    static func notifReceived(){
        notif(withSignal: .received)
    }
    
    static func notifClicked(){
        notif(withSignal: .clicked)
    }
    
    private static func notif(withSignal signal:Api.Signal){
        guard let publicId = UserDefaults.standard.string(forKey: publicID), let sessionId = UserDefaults.standard.string(forKey: sessionID) else {
            return
        }
        
        Api.notif(withSignal: signal, pushId: "", publicId: publicId, sessionId: sessionId) { (result, error) in
            if let data = result {
                
            }else {
                
            }
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
