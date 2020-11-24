//
//  GaryPortal.swift
//  AlMurray
//
//  Created by Tom Knighton on 19/08/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import Foundation
import UIKit
import WhatsNewKit

protocol GaryPortalDelegate: class {
    
    func userDidUpdate()
}

class GaryPortal {
    
    ///Shared instance of a GaryPortal object
    public static var shared: GaryPortal = {
        let garyPortal = GaryPortal()
        
        return garyPortal
    }()
    
    var user: User?
    var localAppSettings: AppSettings
    
    /// Logs a user in and presents the main storyboard
    public func loginUser() {
        UserDefaults.standard.set(true, forKey: "hasLoggedIn")
        DispatchQueue.main.async {
            let mainScreens = HostController()
            mainScreens.modalPresentationStyle = .fullScreen
            let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }

            if var topController = keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                
                topController.present(mainScreens, animated: false, completion: nil)
            }
        }
    }
    
    /// Logs a user out and presents the sign-in/up navigation flow
    public func logoutUser() {
        UserDefaults.standard.set(false, forKey: "hasLoggedIn")
        DispatchQueue.main.async {
            let mainScreens = UIStoryboard(name: "LoginSignup", bundle: nil).instantiateViewController(identifier: "LoginSignupNav")
            mainScreens.modalPresentationStyle = .fullScreen
            let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }

            if var topController = keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                
                topController.present(mainScreens, animated: false, completion: nil)
            }
        }
    }
    
    private init(user: User? = nil, settings: AppSettings? = nil) {
        self.user = user
        self.localAppSettings = settings ?? AppSettings()
    }
    
}

extension NSNotification.Name {
    static let UserDidChange = NSNotification.Name("GPUserDidChange")
}

class GaryPortalObserver {
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.userDidChangeNotification), name: .UserDidChange, object: nil)
    }
    
    @objc
    func userDidChangeNotification() {
        if let user = GaryPortal.shared.user {
            self.onUserUpdate(user: user)
        }
    }
    
    func onUserUpdate(user: User) {
        //
    }
    
}

struct GaryPortalConstants {
    
    static let AppName = "Gary Portal"
    static let AppMainVersion = "4.0"
    
    static let EmailRegex = """
                            ^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$
                            """
    static let PasswordRegex = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-_]).{8,}"
    
    static let APIBaseUrl = "https://us-central1-garyportal4.cloudfunctions.net/"
    static let AppReviewUrl = "https://apps.apple.com/app/id1346147876?action=write-review"

    static let LatestWhatsNew = WhatsNew(version: WhatsNew.Version(major: 4, minor: 0, patch: 0), title: "Gary Portal 4.0.0", items: [
        WhatsNew.Item(title: "Version 4.0", subtitle: "The app has generally improved in this update :) Well done us", image: nil),
        WhatsNew.Item(title: "UI Fixes", subtitle: "The app should now look great on all phone sizes ❤️", image: nil),
        WhatsNew.Item(title: "Greater Control", subtitle: "The settings page has been updated, allowing you greater control over your settings and data", image: nil),
        WhatsNew.Item(title: "Updated Feed", subtitle: "The feed has been updated, smushed together and redesigned, so now the entire feed is on one page, in one place.", image: nil),
        WhatsNew.Item(title: "Better (Battery) Life", subtitle: "The app has been made much faster and more lightweight and now offloads a lot of data in order to save your phone some juice ☺️", image: nil)
    ])
    
    struct Prayers {
        
        static let SimpleCount = "Your Simple Prayers: "
        static let MeaningfulCount = "Your Meaningful Prayers: "
    }
    
    // Defaults:
    struct UserDefaults {
        
        static let autoPlayVideos = "appSettingsAutoPlayVideos"
        static let notifications = "appSettingsNotifications"
    }
    
    // Errors:
    struct Errors {
        
        static let Error = "Error"
        static let SignupFieldsNotCompleted = "Please fill out all fields and select a profile image to continue the sign-up process"
        static let PasswordsDoNotMatch = "Your passwords do not match"
        static let InvalidEmail = "Please enter a valid email address"
        static let InvalidPassword = """
            Your password is too weak, your password should contain one upper case character, one lower case character, one number and one special character and should be over 8 characters in length
            """
    }
    
    struct URLs {
        
        static let WebsiteURL = "https://garyportal.tomk.online"
        static let RulesURL = "https://garyportal.tomk.online/rules"
        static let FeedbackURL = "https://form.jotform.com/202855831651356"
        static let ComputerDatingURL = "https://garyportal.tomk.online/computerdating"
    }
    
}
