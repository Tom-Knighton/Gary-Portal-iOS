//
//  NotificationService.swift
//  GPNotifcations
//
//  Created by Tom Knighton on 20/03/2021.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let userDefaults = UserDefaults(suiteName: "group.garyportal") {
            let badgeCount = userDefaults.integer(forKey: "appBadgeCount")
            if badgeCount > 0 {
                userDefaults.set(badgeCount + 1, forKey: "appBadgeCount")
                bestAttemptContent?.badge = badgeCount + 1 as NSNumber
            } else {
                userDefaults.set(1, forKey: "appBadgeCount")
                bestAttemptContent?.badge = 1
            }
            
            if let _ = bestAttemptContent?.userInfo["chatUUID"] {
                let chatCount = userDefaults.integer(forKey: "chatBadgeCount")
                userDefaults.setValue(chatCount + 1, forKey: "chatBadgeCount")
            }
            
            if let feedPostId = bestAttemptContent?.userInfo["feedPostId"] as? Int, feedPostId != 0 {
                let chatCount = userDefaults.integer(forKey: "feedBadgeCount")
                userDefaults.setValue(chatCount + 1, forKey: "feedBadgeCount")
            }
        }
        
        if let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
