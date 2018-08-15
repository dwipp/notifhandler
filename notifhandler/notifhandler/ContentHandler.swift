//
//  ContentHandler.swift
//  Notification Content Extension
//
//  Created by Dwi Permana Putra on 15/08/18.
//  Copyright © 2018 Dragon Capital Centre. All rights reserved.
//

import UIKit
import UserNotifications


public class ContentHandler {
    private init(){}
    
    private static var contentHandler: ((UNNotificationContent) -> Void)?
    private static var bestAttemptContent: UNMutableNotificationContent?
    
    public static func getImage(imageUrl:String, completion:@escaping (_ image:UIImage?)->()){
        setImage(imagePath: imageUrl) { (image) in
            completion(image)
        }
    }
    
    private static func setImage(imagePath: String, completion:@escaping (_ image:UIImage?)->()){
        guard let url = URL(string: imagePath) else {
            print("Failed to present attachment due to an invalid url: %@", imagePath)
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if error == nil {
                guard let unwrappedData = data, let image = UIImage(data: unwrappedData) else { return }
                DispatchQueue.main.async {
                    completion(image)
                }
            }else {
                completion(nil)
            }
        })
        task.resume()
    }
    
    public static func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            
            var urlString:String? = nil
            let userInfo = request.content.userInfo
            let aps = userInfo["aps"] as? [AnyHashable:Any]
            if let urlImageString = aps!["image"] as? String {
                urlString = urlImageString
            }
            
            if urlString != nil, let fileUrl = URL(string: urlString!) {
                print("fileUrl: \(fileUrl)")
                
                guard let imageData = NSData(contentsOf: fileUrl) else {
                    contentHandler(bestAttemptContent)
                    return
                }
                guard let attachment = UNNotificationAttachment.saveImageToDisk(fileIdentifier: "image.jpg", data: imageData, options: nil) else {
                    print("error in UNNotificationAttachment.saveImageToDisk()")
                    contentHandler(bestAttemptContent)
                    return
                }
                
                bestAttemptContent.attachments = [ attachment ]
            }
            
            contentHandler(bestAttemptContent)
        }
    }
    
    public static func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
}

@available(iOSApplicationExtension 10.0, *)
extension UNNotificationAttachment {
    
    static func saveImageToDisk(fileIdentifier: String, data: NSData, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: folderURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = folderURL?.appendingPathComponent(fileIdentifier)
            try data.write(to: fileURL!, options: [])
            let attachment = try UNNotificationAttachment(identifier: fileIdentifier, url: fileURL!, options: options)
            return attachment
        } catch let error {
            print("error \(error)")
        }
        
        return nil
    }
}
