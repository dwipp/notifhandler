//
//  DataCompiler.swift
//  notifhandler
//
//  Created by Dwi Permana Putra on 18/08/18.
//  Copyright © 2018 Ropen Indonesia. All rights reserved.
//

import Foundation

class Api {
    private let host = "http://demoaj.swipedk.com"
    private let version = "v1"
    
    let IDFAkey = "swipedk-idfa"
    let publicID = "swipedk-public-id"
    let sessionID = "swipedk-session-id"
    
    func endpoint()->String{
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
    
    func request(withURL url:String, method:HttpMethod, params:[String:Any], completion:@escaping (_ data:Data?, _ error:Error?)->()) {
        let realUrl = URL(string: url)!
        var request = URLRequest(url: realUrl, cachePolicy: .reloadIgnoringLocalCacheData)
        request.allHTTPHeaderFields = Header.setup()
        request.httpMethod = method.rawValue
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
            request.httpBody = jsonData
        }catch let err {
            print("JSONSerialization error: \(err)")
        }
        URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            completion(data, error)
        }.resume()
    }
    
    func register(withIDFA idfa:String, completion:@escaping (_ result:RegistrationModel?, _ error:Error?)->()){
        let path = "register/account"
        let params = ["advertising_id":idfa]
        request(withURL: endpoint()+path, method: .post, params: params) { (data, error) in
            guard let data = data else {
                print("SwipeDK error: \(String(describing: error))")
                completion(nil, error)
                return
            }
            
            do {
                let reg = try JSONDecoder().decode(RegistrationModel.self, from: data)
                completion(reg, nil)
                
            }catch let err {
                print("SwipeDK error: \(String(describing: error))")
                completion(nil, err)
            }
        }
    }
    
    func notif(withSignal signal:Signal, pushId:String, publicId:String, sessionId:String, completion:@escaping (_ result:DefaultModel?, _ error:Error?)->()){
        let path = "push/set_signal"
        let params = ["signal":signal.rawValue,
                      "push_id":pushId,
                      "public_id":publicId,
                      "session_id":sessionId]
        
        request(withURL: endpoint()+path, method: .post, params: params) { (data, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            do{
                let signal = try JSONDecoder().decode(DefaultModel.self, from: data)
                completion(signal, nil)
            }catch let err {
                completion(nil, err)
            }
        }
    }
    
    func registerToken(_ token:String, onesignalId:String, publicId:String, sessionId:String, completion:@escaping (_ result:DefaultModel?, _ error:Error?)->()) {
        let path = "push/register_token"
        let params = ["public_id":publicId,
                      "session_id":sessionId,
                      "registration_id":token,
                      "one_signal_id":onesignalId]
        
        request(withURL: endpoint()+path, method: .post, params: params) { (data, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            do{
                let reg = try JSONDecoder().decode(DefaultModel.self, from: data)
                completion(reg, nil)
            }catch let err {
                completion(nil, err)
            }
            
            
        }
        
    }
    
    
    
}

public class SwipeConfiguration {
    private init(){}
    
    public static func notifReceived(withPushID pushID:String){
        notif(withSignal: .received, andPushID: pushID)
    }
    
    public static func notifClicked(withPushID pushID:String){
        notif(withSignal: .clicked, andPushID: pushID)
    }
    
    private static func notif(withSignal signal:Api.Signal, andPushID pushID:String){
        let api = Api.init()
        guard let publicId = Defaults.string(forKey: .publicID), let sessionId = Defaults.string(forKey: .sessionID) else {
            return
        }
        
        api.notif(withSignal: signal, pushId: pushID, publicId: publicId, sessionId: sessionId) { (result, error) in
            if let data = result, data.code == 200 {
                // succeed
                print("signaling to server that the notif has been: \(signal.rawValue)")
            }else {
                // error
                print("SwipeDK notif error: \(String(describing: error))")
            }
        }
    }
}
