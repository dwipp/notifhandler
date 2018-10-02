//
//  DataStorages.swift
//  notifhandler
//
//  Created by Dwi Permana Putra on 22/09/18.
//

import Foundation

class DataStorages {
    static let shared = DataStorages()
    private let fileManager = FileManager.default
    private let mainDir = "SwipeDK"
    private let filename = "SwipeDK_DataCollection.json"
    
    func directoryBuilder()->URL{
        let docURL = self.fileManager.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let directoryUrl:URL = docURL.appendingPathComponent(mainDir)
        print("directory url: \(directoryUrl.path)")
        if !self.fileManager.fileExists(atPath: directoryUrl.path){
            do{
                try self.fileManager.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
            }catch _ {}
        }
        return directoryUrl
    }
    
    func update(){
        let sc = SwipeCollect.shared
        let location = ["latitude":sc.getLocation().0 ?? 0,
                        "longitude":sc.getLocation().1 ?? 0]
        let dicts:[String:Any] = ["location":location,
                     "network_type":sc.getNetworkType() ?? "",
                     "user_country":sc.getCountry() ?? "",
                     "user_language":sc.getLanguage() ?? "",
                     "user_timezone":sc.getTimeZone() ?? "",
                     "device_manufacture":"Apple",
                     "device_model_number":sc.getDeviceName() ?? "",
                     "os_version_build":sc.getSystemVersion() ?? "",
                     "os_version_name":sc.getSystemName() ?? "",
                     "os_kernel_version":sc.getKernel() ?? ""]
        do {
            let rawJson = try JSONSerialization.data(withJSONObject: dicts, options:JSONSerialization.WritingOptions(rawValue: 0))
            let path = directoryBuilder()
            let url = path.appendingPathComponent(filename)
            try rawJson.write(to: url)
        }catch let err {
            print("SwipeDK error: \(err)")
        }
        
    }
    
    func pull(completion:(_ result:CollectionModel?)->()){
        do {
            let path = directoryBuilder()
            let url = path.appendingPathComponent(filename)
            let data = try Data(contentsOf: url)
            let json = try JSONDecoder().decode(CollectionModel.self, from: data)
            completion(json)
        }catch let err {
            print("error: \(err)")
            completion(nil)
        }
    }
    
}
