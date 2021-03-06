//
//  DataCollectors.swift
//  notifhandler
//
//  Created by Dwi Permana Putra on 03/09/18.
//

import Foundation
import AdSupport
import CoreLocation
import Contacts

public class SwipeCollect:NSObject {
    public static let shared = SwipeCollect()
    private let loc = CLLocationManager()
    private var count_post = 0
    private var count_freshPost = 0
    
    public var userLocation = true
    public var udid = true
    public var systemName = true
    public var systemVersion = true
    public var language = true
    public var country = true
    public var network = true
    public var contact = true
    public var idfa = true
    public var deviceName = true
    public var kernel = true
    public var timezone = true
    
    
    //MARK: developer permission
    public func getUDID()->String?{
        if udid {
            return UIDevice.current.identifierForVendor?.uuidString
        }
        return nil
    }
    
    public func getSystemName() -> String? {
        if systemName {
            return UIDevice.current.systemName
        }
        return nil
    }
    
    public func getSystemVersion() -> String? {
        if systemVersion {
            return UIDevice.current.systemVersion
        }
        return nil
    }
    
    public func getLanguage() -> String?{
        if language {
            return Locale.current.languageCode
        }
        return nil
    }
    
    public func getCountry() -> String?{
        if country {
            return Locale.current.regionCode
        }
        return nil
    }
    
    public func getNetworkType() -> String?{
        if network {
            guard let status = Network.reachability?.status else {return nil}
            switch status {
            case .unreachable:
                return status.rawValue
            case .wifi:
                return "\(status.rawValue) \(Network.reachability?.getWiFiSsid() ?? "")"
            case .wwan:
                return "\(status.rawValue) \(Network.reachability?.getTelephonyNetwork().0 ?? "") \(Network.reachability?.getTelephonyNetwork().1 ?? "")"
            }
        }
        return nil
    }
    
    public func getLocation() -> (Double?, Double?){
        if userLocation {
            return (loc.location?.coordinate.latitude, loc.location?.coordinate.longitude)
        }
        return (nil, nil)
    }
    
    public func getIDFA()->String?{
        if idfa {
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                return ASIdentifierManager.shared().advertisingIdentifier.uuidString
            } else {
                return nil
            }
        }
        return nil
    }
    
    public func getDeviceName() -> String? {
        if deviceName {
            var sysinfo = utsname()
            uname(&sysinfo)
            return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
        }
        return nil
    }
    
    public func getKernel() -> String? {
        if kernel {
            var sysinfo = utsname()
            uname(&sysinfo)
            let dv = String(bytes: Data(bytes: &sysinfo.release, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
            return "Darwin/\(dv)"
        }
        return nil
    }
    
    public func getTimeZone()->String?{
        if timezone {
            var utcInSecond = TimeZone.current.secondsFromGMT()
            var frontPrefix = "+"
            if utcInSecond < 0 {
                frontPrefix = "-"
                utcInSecond = utcInSecond * -1
            }
            
            let hourInt = utcInSecond/3600
            var hour = "\(hourInt)"
            if hourInt < 10 {
                hour = "0\(hourInt)"
            }
            
            let minuteInt = (utcInSecond%3600)/60
            var minute = "\(minuteInt)"
            if minuteInt < 10 {
                minute = "0\(minuteInt)"
            }
            
            return frontPrefix + "\(hour):\(minute)"
        }
        return nil
    }
    
}

extension SwipeCollect {
    public func getContacts(completion:@escaping (_ result:[ContactModel]?, _ error:Error?)->()){
        if contact {
            let store = CNContactStore()
            var totalContacts = 0
            
            store.requestAccess(for: .contacts) { (granted, error) in
                if let err = error {
                    print("failed to request access: ", err)
                    completion([], err)
                    return
                }
                
                if granted {
                    print("access granted")
                    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                    //                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
                    
                    // The container means
                    // that the source the contacts from, such as Exchange and iCloud
                    var allContainers: [CNContainer] = []
                    do {
                        allContainers = try store.containers(matching: nil)
                    } catch {
                        print("Error fetching containers")
                    }
                    print ("total kontak: ", allContainers.count)
                    
                    var contacts: [CNContact] = []
                    for container in allContainers {
                        let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
                        
                        do {
                            let containerResults = try store.unifiedContacts(matching: fetchPredicate, keysToFetch: keys as [CNKeyDescriptor])
                            // Put them into "contacts"
                            contacts.append(contentsOf: containerResults)
                            print ("total kntak2: ", containerResults.count)
                            totalContacts = containerResults.count
                        } catch {
                            print("Error fetching results for container")
                        }
                    }
                    
                    var model:[ContactModel] = [ContactModel]()
                    
                    let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                    do {
                        try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                            var phoneNumbers = [String]()

                            for number in contact.phoneNumbers {
                                phoneNumbers.append(number.value.stringValue.replacingOccurrences(of: " ", with: ""))
                            }
                            
                            model.append(ContactModel(firstname: contact.givenName, lastname: contact.familyName, phone: phoneNumbers))
                            if totalContacts == model.count {
                                completion(model, nil)
                            }
                        })
                    }catch let error {
                        completion([], error)
                        print("failed to enumetare contacts: ", error)
                    }
                    
                }else {
                    print("access denied")
                    completion([], error)
                }
            }
        }else{
            completion(nil, nil)
        }
    }
}

extension SwipeCollect: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("not determined")
            manager.requestLocation()
        case .authorizedAlways, .authorizedWhenInUse:
            print("location granted")
            // kirim lokasi saat pertama kali user granted permission
            freshInstallTransmitLocation()
        default:
            print("ditolak")
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func setupLocation(){
        loc.delegate = self
        loc.desiredAccuracy = kCLLocationAccuracyBest
        loc.requestAlwaysAuthorization()
    }
}

// MARK: Transmit data collection
extension SwipeCollect {
    // MARK: Fresh Install Data Transmission
    func freshInstallTransmitLocation(){
        let loc = getLocation()
        if let lat = loc.0, let lon = loc.1 {
            transmitLocation(withLatitude: lat, andLongitude: lon, fresh: true) {}
        }
    }
    
    func freshInstallTransmitData(){
        var valuedData = [[String:String]]()
        if let network = getNetworkType() {
            valuedData.append(buildData(withKey: "network_type", andValue: network))
        }
        if let country = getCountry() {
            valuedData.append(buildData(withKey: "user_country", andValue: country))
        }
        if let lang = getLanguage() {
            valuedData.append(buildData(withKey: "user_language", andValue: lang))
        }
        if let time = getTimeZone() {
            valuedData.append(buildData(withKey: "user_timezone", andValue: time))
        }
        valuedData.append(buildData(withKey: "device_manufacture", andValue: "Apple"))
        if let dname = getDeviceName() {
            valuedData.append(buildData(withKey: "device_model_number", andValue: dname))
        }
        if let sversion = getSystemVersion() {
            valuedData.append(buildData(withKey: "os_version_build", andValue: sversion))
        }
        if let sname = getSystemName() {
            valuedData.append(buildData(withKey: "os_version_name", andValue: sname))
        }
        if let darwin = getKernel() {
            valuedData.append(buildData(withKey: "os_kernel_version", andValue: darwin))
        }
        print("valuedData: \(valuedData)")
        transmitData(withData: valuedData, fresh: true) {}
    }
    
    private func transmitContacts(completion:@escaping ()->()){
        getContacts { (model, err) in
            
        }
    }
    
    private func transmitLocation(withLatitude lat:Double, andLongitude lon:Double, fresh:Bool = false, completion:@escaping ()->()){
        if let publicId = Defaults.string(forKey: .publicID), let sessionId = Defaults.string(forKey: .sessionID) {
            DataTransmitter.sendLocation(sessionId: sessionId, publicId: publicId, latitude: lat, longitude: lon) { (result, error) in
                if let data = result, data.code == 200 {
                    // succeed
                    print("sukses lokasi")
                }else {
                    // error
                    print("gagal lokasi")
                }
                self.saveLocationAndData(forFreshInstall: fresh)
                completion()
            }
        }
    }
    
    private func transmitData(withData data:[[String:String]], fresh:Bool = false, completion:@escaping ()->()) {
        if let publicId = Defaults.string(forKey: .publicID), let sessionId = Defaults.string(forKey: .sessionID) {
            DataTransmitter.sendDataType(data: data, sessionId: sessionId, publicId: publicId) { (result, error) in
                if let data = result, data.code == 200 {
                    // succeed
                    print("set data succeed")
                }else {
                    // error
                    print("set data failed")
                }
                self.saveLocationAndData(forFreshInstall: fresh)
                completion()
            }
        }
    }
    
    private func buildData(withKey key:String, andValue value:String)->[String:String]{
        let data = ["key":key,
                    "value":value]
        return data
    }
    
    private func saveLocationAndData(forFreshInstall fresh:Bool = false){
        if fresh {
            count_freshPost += 1
            if count_freshPost == 2 {
                count_freshPost = 0
                DataStorages.shared.update()
                print("saveDataBaru")
                print("fresh")
//                SwipeDK.backgroundTask()
            }
        }else {
            count_post += 1
            if count_post == 2 {
                count_post = 0
                DataStorages.shared.updateDataBundle()
                print("saveDataBaru")
                print("old")
            }
        }
        
    }
    
    public func getLocationAndData(completion:@escaping ()->()){
        var countTransmit = 0
        DataStorages.shared.pullDataBundle { (model) in
            if let current = model {
                if let lat = getLocation().0, let lon = getLocation().1 {
                    if current.location.latitude != lat || current.location.longitude != lon {
                        transmitLocation(withLatitude: lat, andLongitude: lon, completion: {
                            countTransmit += 1
                            if countTransmit == 2 {
                                print("completion di location")
                                completion()
                            }
                        })
                    }else {
                        saveLocationAndData()
                        countTransmit += 1
                        if countTransmit == 2 {
                            print("completion di else saveLocationAndData pertama")
                            completion()
                        }
                    }
                }else {
                    saveLocationAndData()
                    countTransmit += 1
                    if countTransmit == 2 {
                        print("completion di else saveLocationAndData kedua")
                        completion()
                    }
                }
                
                var valuedData = [[String:String]]()
                if let network = getNetworkType(), network != current.network_type {
                    valuedData.append(buildData(withKey: "network_type", andValue: network))
                }
                if let country = getCountry(), country != current.user_country {
                    valuedData.append(buildData(withKey: "user_country", andValue: country))
                }
                if let lang = getLanguage(), lang != current.user_language {
                    valuedData.append(buildData(withKey: "user_language", andValue: lang))
                }
                if let time = getTimeZone(), time != current.user_timezone {
                    valuedData.append(buildData(withKey: "user_timezone", andValue: time))
                }
                if let dname = getDeviceName(), getDeviceName() != current.device_model_number {
                    valuedData.append(buildData(withKey: "device_model_number", andValue: dname))
                }
                if let sversion = getSystemVersion(), getSystemVersion() != current.os_version_build {
                    valuedData.append(buildData(withKey: "os_version_build", andValue: sversion))
                }
                if let sname = getSystemName(), getSystemName() != current.os_version_name {
                    valuedData.append(buildData(withKey: "os_version_name", andValue: sname))
                }
                if let darwin = getKernel(), getKernel() != current.os_kernel_version {
                    valuedData.append(buildData(withKey: "os_kernel_version", andValue: darwin))
                }
//                valuedData.append(buildData(withKey: "device_manufacture", andValue: "Apple"))// test only
                if valuedData.count > 0 {
                    transmitData(withData: valuedData, completion: {
                        countTransmit += 1
                        if countTransmit == 2 {
                            print("completion di transmitdata")
                            completion()
                        }
                    })
                }else {
                    saveLocationAndData()
                    countTransmit += 1
                    if countTransmit == 2 {
                        print("completion di saveLocationAndData data")
                        completion()
                    }
                }
            }else {
                print("masuk else paling luar")
                completion()
            }
        }
    }
    
}




