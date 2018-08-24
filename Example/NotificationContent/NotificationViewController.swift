//
//  NotificationViewController.swift
//  NotificationContent
//
//  Created by Dwi Permana Putra on 24/08/18.
//  Copyright © 2018 Ropen Indonesia. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import notifhandler

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        let aps = userInfo["att"] as! [AnyHashable:Any]
        let imgUrl = aps["id"] as! String
        
        SwipeNotification.getImage(imageUrl: imgUrl) { (image) in
            self.imageView.image = image
        }
    }

}
