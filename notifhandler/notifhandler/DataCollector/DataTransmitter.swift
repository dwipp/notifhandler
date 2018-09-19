//
//  DataTransmitter.swift
//  notifhandler
//
//  Created by Dwi Permana Putra on 12/09/18.
//

import Foundation

class DataTransmitter {
    private init(){}
    fileprivate static let api = Api()
    static func sendLocation(sessionId:String, publicId:String, latitude:Double, longitude:Double, completion:@escaping (_ result:DefaultModel?, _ error:Error?)->()){
        let path = "account/set_location_user"
        let params:[String:Any] = ["session_id":sessionId,
                      "public_id":publicId,
                      "latitude":latitude,
                      "longitude":longitude]
        
        api.request(withURL: api.endpoint()+path, method: .post, params: params) { (data, error) in
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
    
    static func sendDataType(data:[[String:String]], sessionId:String, publicId:String, completion:@escaping (_ result:DefaultModel?, _ error:Error?)->()){
        let path = "account/set_data_type"
        let params:[String:Any] = ["session_id":sessionId,
                                   "public_id":publicId,
                                   "data":data]
        
        api.request(withURL: api.endpoint()+path, method: .post, params: params) { (data, error) in
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
    
    
}
