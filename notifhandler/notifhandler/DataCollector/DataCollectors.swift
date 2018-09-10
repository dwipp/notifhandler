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

public struct SwipeCollect {
    public static let loc = CLLocationManager()
    
    public static func getUDID()->String?{
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    public static func getIDFA()->String?{
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        } else {
            return nil
        }
    }
    
    public static func getDeviceName() -> String {
        var sysinfo = utsname()
        uname(&sysinfo)
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    public static func getSystemName() -> String {
        return UIDevice.current.systemName
    }
    
    public static func getSystemVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    public static func getKernel() -> String {
        var sysinfo = utsname()
        uname(&sysinfo)
        let dv = String(bytes: Data(bytes: &sysinfo.release, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
        return "Darwin/\(dv)"
    }
    
    public static func getTimeZone()->String{
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
    
    public static func getLanguage() -> String?{
        return Locale.current.languageCode
    }
    
    public static func getCountry() -> String?{
        return Locale.current.regionCode
    }
    
    public static func getNetworkType() -> String?{
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
    
    public static func getLocation() -> (Double?, Double?){
        return (loc.location?.coordinate.latitude, loc.location?.coordinate.longitude)
    }
}

extension SwipeCollect {
    public static func getContacts(completion:@escaping (_ result:[ContactModel], _ error:Error?)->()){
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






