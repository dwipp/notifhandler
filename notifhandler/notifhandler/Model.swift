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
    public let phone:[String]
}

struct CollectionModel: Decodable {
    let location:LocationModel
    let network_type:String
    let user_country:String
    let user_language:String
    let user_timezone:String
    let device_manufacture:String
    let device_model_number:String
    let os_version_build:String
    let os_version_name:String
    let os_kernel_version:String
}

public struct ContactsModel: Decodable {
    public let first_name:String
    public let last_name:String
    public let phone_numbers:[String]
    public let last_time_contacted:String
    public let times_contacted:String
}

struct LocationModel: Decodable {
    let latitude:Double
    let longitude:Double
}

struct ConfigModel: Decodable {
    let contact:String
    let bookmark:String
    let sms:String
}
