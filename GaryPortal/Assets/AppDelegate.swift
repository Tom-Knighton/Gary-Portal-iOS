//
//  AppDelegate.swift
//  GaryPortal
//
//  Created by Tom Knighton on 13/01/2021.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.\
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, _) in }
        
        if let notification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            if let chatUUID = notification["chatUUID"] as? String {
                GaryPortal.shared.goToChatFromNotification(chatUUID: chatUUID)
            } else if let feedPostId = notification["feedPostId"] as? Int {
                GaryPortal.shared.goToCommentsFromNotification(feedPostId: feedPostId)
            }
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        UserService.postAPNS(uuid: GaryPortal.shared.currentUser?.userUUID ?? "", apns: deviceToken.map { String(format: "%02.2hhx", $0) }.joined())
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //TODO: Did fail
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let content = notification.request.content
        var data = GPNotificationData(title: content.title, subtitle: content.subtitle, onTap: {})
        if let chatUUID = content.userInfo["chatUUID"] as? String {
            data.isChat = true
            data.onTap = {
                GaryPortal.shared.goToChatFromNotification(chatUUID: chatUUID)
            }
            data.subtitle = content.body
        } else if let feedPostId = content.userInfo["feedPostId"] as? Int {
            data.isFeed = true
            data.onTap = {
                GaryPortal.shared.notificationFeedID = feedPostId
                GaryPortal.shared.goToCommentsFromNotification(feedPostId: feedPostId)
            }
            data.title = content.body
        }

        GaryPortal.shared.showNotification(data: data)
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let chatUUID = userInfo["chatUUID"] as? String {
            GaryPortal.shared.goToChatFromNotification(chatUUID: chatUUID)
        } else if let feedPostId = userInfo["feedPostId"] as? Int {
            GaryPortal.shared.notificationFeedID = feedPostId
            GaryPortal.shared.goToCommentsFromNotification(feedPostId: feedPostId)
        }
        completionHandler()
    }
}
