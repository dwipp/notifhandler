//
//  Model.swift
//  notifhandler
//
//  Created by Dwi Permana Putra on 19/08/18.
//  Copyright © 2018 Ropen Indonesia. All rights reserved.
//

import Foundation

struct RegistrationModel: Decodable {
    let code:Int
    let result:RegModel
}

struct RegModel: Decodable {
    let public_id:String
    let session_id:String
}

struct SignalModel: Decodable {
    let code:Int
}
