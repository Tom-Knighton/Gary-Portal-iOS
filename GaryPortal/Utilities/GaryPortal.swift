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

class GaryPortal: NSObject, ObservableObject {
    
    @Published var currentUser: User?
    @Published var localAppSettings: AppSettings = AppSettings()
    
    var chatConnection: ChatConnection?

    static let shared = GaryPortal()
    
    func loginUser(uuid: String) {
        UserDefaults.standard.set(true, forKey: "hasLoggedIn")
        KeychainWrapper.standard.set(uuid, forKey: "UUID")
        DispatchQueue.main.async {
            let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
            if var topController = keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                //let vc = HostController()
                let vc = UIHostingController(rootView: ContentView().environmentObject(GaryPortal.shared))
                vc.modalPresentationStyle = .fullScreen
                topController.present(vc, animated: false, completion: nil)
            }
        }
        self.chatConnection = ChatConnection()
    }
    
    func logoutUser() {
        KeychainWrapper.standard.set("", forKey: "UUID")
        updateTokens(tokens: UserAuthenticationTokens(authenticationToken: "", refreshToken: ""))
        
        DispatchQueue.main.async {
            let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }

            if var topController = keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                let vc = UIHostingController(rootView: SignInNavigationHost().environmentObject(GaryPortal.shared))
                vc.modalPresentationStyle = .fullScreen
                topController.present(vc, animated: false, completion: nil)
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
}

struct GaryPortalConstants {
    
    static let AppName = "Gary Portal"
    static let AppMainVersion = "4.0"
    
    static let EmailRegex = """
                            ^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$
                            """
    static let PasswordRegex = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-_]).{8,}"
    
    static let APIBaseUrl = "https://api.garyportal.tomk.online/api/"
    static let APIChatHub = "https://api.garyportal.tomk.online/chathub"
    static let AppReviewUrl = "https://apps.apple.com/app/id1346147876?action=write-review"
    
    
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
        
        static let autoPlayVideos = "appSettingsAutoPlayVideos"
        static let notifications = "appSettingsNotifications"
    }
    
    struct Messages {
        static let thankYou = "Thank You"
        static let messageReported = "This message has been reported, an admin will review it and possibly contact you for further information if necessary"
    }

}
