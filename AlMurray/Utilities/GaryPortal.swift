//
//  GaryPortal.swift
//  AlMurray
//
//  Created by Tom Knighton on 19/08/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import Foundation
import UIKit

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
    
    private init(user: User? = nil) {
        self.user = user
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
    
    static let APIBaseUrl = "https://us-central1-garyportal4.cloudfunctions.net/api/"
    
    struct Prayers {
        
        static let SimpleCount = "Your Simple Prayers: "
        static let MeaningfulCount = "Your Meaningful Prayers: "
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
