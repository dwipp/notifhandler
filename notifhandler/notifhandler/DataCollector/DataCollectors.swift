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
    private var count_freshInstallPost = 0
    
    public func getUDID()->String?{
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    public func getIDFA()->String?{
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        } else {
            return nil
        }
    }
    
    public func getDeviceName() -> String {
        var sysinfo = utsname()
        uname(&sysinfo)
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    public func getSystemName() -> String {
        return UIDevice.current.systemName
    }
    
    public func getSystemVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    public func getKernel() -> String {
        var sysinfo = utsname()
        uname(&sysinfo)
        let dv = String(bytes: Data(bytes: &sysinfo.release, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
        return "Darwin/\(dv)"
    }
    
    public func getTimeZone()->String{
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
    
    public func getLanguage() -> String?{
        return Locale.current.languageCode
    }
    
    public func getCountry() -> String?{
        return Locale.current.regionCode
    }
    
    public func getNetworkType() -> String?{
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
    
    public func getLocation() -> (Double?, Double?){
        return (loc.location?.coordinate.latitude, loc.location?.coordinate.longitude)
    }
}

extension SwipeCollect {
    public func getContacts(completion:@escaping (_ result:[ContactModel], _ error:Error?)->()){
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
                        model.append(ContactModel(firstname: contact.givenName, lastname: contact.familyName, phone: contact.phoneNumbers))
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
        loc.requestWhenInUseAuthorization()
    }
}

// MARK: Transmit data collection
extension SwipeCollect {
    func freshInstallTransmitLocation(){
        let loc = getLocation()
        let api = Api()
        if let session = UserDefaults.standard.string(forKey: api.sessionID), let publicId = UserDefaults.standard.string(forKey: api.publicID), let lat = loc.0, let lon = loc.1 {
            DataTransmitter.sendLocation(sessionId: session, publicId: publicId, latitude: lat, longitude: lon) { (result, error) in
                if let data = result, data.code == 200 {
                    // succeed
                    print("sukses lokasi")
                }else {
                    // error
                    print("gagal lokasi")
                }
                self.saveFreshInstallDataCollects()
            }
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
        valuedData.append(buildData(withKey: "user_timezone", andValue: getTimeZone()))
        valuedData.append(buildData(withKey: "device_manufacture", andValue: "Apple"))
        valuedData.append(buildData(withKey: "device_model_number", andValue: getDeviceName()))
        valuedData.append(buildData(withKey: "os_version_build", andValue: getSystemVersion()))
        valuedData.append(buildData(withKey: "os_version_name", andValue: getSystemName()))
        valuedData.append(buildData(withKey: "os_kernel_version", andValue: getKernel()))
        print("valuedData: \(valuedData)")
        let api = Api()
        if let session = UserDefaults.standard.string(forKey: api.sessionID), let publicId = UserDefaults.standard.string(forKey: api.publicID) {
            DataTransmitter.sendDataType(data: valuedData, sessionId: session, publicId: publicId) { (result, error) in
                if let data = result, data.code == 200 {
                    // succeed
                    print("set data succeed")
                }else {
                    // error
                    print("set data failed")
                }
                self.saveFreshInstallDataCollects()
            }
        }
        
    }
    
    private func buildData(withKey key:String, andValue value:String)->[String:String]{
        let data = ["key":key,
                    "value":value]
        return data
    }
    
    private func saveFreshInstallDataCollects(){
        count_freshInstallPost += 1
        if count_freshInstallPost == 2 {
            count_freshInstallPost = 0
            DataStorages.shared.update()
            SwipeDK.backgroundTask()
        }
    }
    
}




