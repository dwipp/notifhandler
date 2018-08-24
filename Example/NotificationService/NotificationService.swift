//
//  NotificationService.swift
//  Notification Service
//
//  Created by Dwi Permana Putra on 24/08/18.
//  Copyright © 2018 Ropen Indonesia. All rights reserved.
//

import UserNotifications
import notifhandler

class NotificationService: UNNotificationServiceExtension {
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        SwipeNotification.didReceive(request) { (content) in
            contentHandler(content)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        SwipeNotification.serviceExtensionTimeWillExpire()
    }

}
