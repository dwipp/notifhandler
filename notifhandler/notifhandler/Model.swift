//
//  Model.swift
//  notifhandler
//
//  Created by Dwi Permana Putra on 19/08/18.
//  Copyright © 2018 Ropen Indonesia. All rights reserved.
//

import Foundation
import Contacts

struct RegistrationModel: Decodable {
    let code:Int
    let result:RegModel
}

struct RegModel: Decodable {
    let public_id:String
    let session_id:String
    let publisher:String
}

struct DefaultModel: Decodable {
    let code:Int
}

public struct ContactModel {
    public let firstname:String
    public let lastname:String
    public let phone:[CNLabeledValue<CNPhoneNumber>]
}
