//
//  GaryPortal.swift
//  GaryPortal
//
//  Created by Tom Knighton on 14/01/2021.
//

import Foundation
import UIKit
import SwiftKeychainWrapper
import SwiftUI

public enum NotificationSheetDisplayMode: Identifiable {
    case none
    case chat
    case feedComments
    case whatsNew
    public var id: NotificationSheetDisplayMode { self }
}

class GaryPortal: NSObject, ObservableObject {
    
    @Published var currentUser: User?
    @Published var notificationSheetDisplayMode: NotificationSheetDisplayMode?
    @Published var viewingNotificationChat: Chat?
    @Published var viewingNotificationPost: FeedPost?
    @Published var notificationFeedID = 0
    
    @Published var currentNotificationData: GPNotificationData?
    @Published var showNotification = false
    
    @Published var currentPageIndex = 1

    var chatConnection: ChatConnection?
    var hubConnection: GaryPortalHub?

    static let shared = GaryPortal()
    
    func loginUser(uuid: String, salt: String) {
        UserDefaults(suiteName: GaryPortalConstants.UserDefaults.suiteName)?.set(true, forKey: "hasLoggedIn")
        KeychainWrapper.standard.set(uuid, forKey: "UUID")
        
        let oldSalt = KeychainWrapper.standard.string(forKey: "salt")
        if let oldSalt = oldSalt, oldSalt.isEmptyOrWhitespace() == false && salt != oldSalt {
            self.logoutUser()
            return
        }
        KeychainWrapper.standard.set(salt, forKey: "salt")
        DispatchQueue.main.async {
            let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
            if var topController = keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                let vc = UIHostingController(rootView: ContentView())
                vc.modalPresentationStyle = .fullScreen
                topController.present(vc, animated: false, completion: nil)
            }
            UIApplication.shared.registerForRemoteNotifications()
            
            self.chatConnection = ChatConnection()
            self.hubConnection = GaryPortalHub()
            
            if UserDefaults.standard.bool(forKey: GaryPortalConstants.hasSeenWhatsNew) == false {
                self.notificationSheetDisplayMode = .whatsNew
            }
        }
        
    }
    
    func logoutUser() {
        UserDefaults(suiteName: GaryPortalConstants.UserDefaults.suiteName)?.set(false, forKey: "hasLoggedIn")
        KeychainWrapper.standard.set("", forKey: "salt")
        KeychainWrapper.standard.set("", forKey: "UUID")
        updateTokens(tokens: UserAuthenticationTokens(authenticationToken: "", refreshToken: ""))
        
        DispatchQueue.main.async {
            UIApplication.shared.unregisterForRemoteNotifications()
            let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }

            if var topController = keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                let vc = UIHostingController(rootView: SignInNavigationHost())
                vc.modalPresentationStyle = .fullScreen
                topController.present(vc, animated: false, completion: nil)
            }
        }
    }
    
    func updateBlocks() {
        UserService.getBlockedUsers(userUUID: self.currentUser?.userUUID ?? "") { (blocks, error) in
            if let blocks = blocks {
                self.currentUser?.blockedUsers = blocks
            }
        }
    }
    
    func updateTokens(tokens: UserAuthenticationTokens) {
        KeychainWrapper.standard.set(tokens.authenticationToken ?? "", forKey: "JWT")
        KeychainWrapper.standard.set(tokens.refreshToken ?? "", forKey: "JWTREFRESH")
    }
    
    func getTokens() -> UserAuthenticationTokens {
        return UserAuthenticationTokens(authenticationToken: KeychainWrapper.standard.string(forKey: "JWT"), refreshToken: KeychainWrapper.standard.string(forKey: "JWTREFRESH"))
    }
    
    func goToChatFromNotification(chatUUID: String) {
        ChatService.getChat(by: chatUUID) { (chat, error) in
            if let chat = chat {
                DispatchQueue.main.async {
                    self.viewingNotificationChat = chat
                    self.notificationSheetDisplayMode = .chat
                }
            }
        }
    }
    
    func goToCommentsFromNotification(feedPostId: Int) {
        FeedService.getPost(by: feedPostId) { (post, error) in
            if let post = post {
                DispatchQueue.main.async {
                    self.viewingNotificationPost = post
                    self.notificationSheetDisplayMode = .feedComments
                }
            }
        }
    }
    
    private var notificationTimer: Timer?
    func showNotification(data: GPNotificationData) {
        self.currentNotificationData = data
        self.showNotification = true
        self.notificationTimer?.invalidate()
        self.notificationTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: false, block: { _ in
            self.hideNotification()
        })
    }
    
    func hideNotification() {
        self.showNotification = false
    }
}

struct GaryPortalConstants {
    
    static let AppName = "Gary Portal"
    static let AppMainVersion = "4.1"
    
    #if DEBUG
        static let AppIsDev = true
    #else
        static let AppIsDev = false
    #endif
    
    static let EmailRegex = """
                            ^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$
                            """
    static let PasswordRegex = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-_]).{8,}"
    
    static let APIBaseUrl = AppIsDev ? "https://api-dev-v5.garyportal.tomk.online/api/" : "https://api.garyportal.tomk.online/api/"
    static let APIChatHub = AppIsDev ? "https://api-dev-v5.garyportal.tomk.online/chathub/" : "https://api.garyportal.tomk.online/chathub/"
    static let APIMiscHub = AppIsDev ? "https://api-dev-v5.garyportal.tomk.online/apphub/" : "https://api.garyportal.tomk.online/apphub/"
    static let AppReviewUrl = "https://apps.apple.com/app/id1346147876?action=write-review"
    
    static let hasSeenWhatsNew = "hasSeenv4_1Changelog"
    
    struct Errors {
        
        static let Error = "Error"
        static let SignupFieldsNotCompleted = "Please fill out all fields to continue the sign-up process"
        static let SignupNoImage = "Please select a profile image to finish the sign-up process"
        static let PasswordsDoNotMatch = "Your passwords do not match"
        static let InvalidEmail = "Please enter a valid email address"
        static let InvalidPassword = """
            Your password is too weak, your password should contain one upper case character, one lower case character, one number and one special character and should be over 8 characters in length
            """
        static let UsernameTaken = "That username has already been taken"
        static let EmailTaken = "That email address is already in use"
    }
    
    struct URLs {
        
        static let WebsiteURL = "https://garyportal.tomk.online"
        static let RulesURL = "https://garyportal.tomk.online/rules"
        static let FeedbackURL = "https://form.jotform.com/202855831651356"
        static let ComputerDatingURL = "https://garyportal.tomk.online/computerdating"
        static let DinoGameURL = "https://tomk.online/amdinogame"
    }
    
    struct UserDefaults {
        static let suiteName = "group.garyportal"
    }
    
    struct Messages {
        static let thankYou = "Thank You"
        static let messageReported = "This message has been reported, an admin will review it and possibly contact you for further information if necessary"
        static let postReported = "This post has been reported, an admin will review it and possibly contact you for further information if necessary"
    }

}
