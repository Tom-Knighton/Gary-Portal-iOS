//
//  SettingsTableCells.swift
//  AlMurray
//
//  Created by Tom Knighton on 16/11/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import UIKit
import Nuke
import StoreKit
import FirebaseAuth

class SettingsAccountCell: UITableViewCell {

    @IBOutlet private weak var usernameTextField: UITextField?
    @IBOutlet private weak var emailTextField: UITextField?
    @IBOutlet private weak var fullNameTextField: UITextField?
    @IBOutlet private weak var usernameView: UIView?
    @IBOutlet private weak var emailView: UIView?
    @IBOutlet private weak var fullNameView: UIView!
    
    @IBOutlet private weak var userImageView: UIImageView?
    
    weak var delegate: SettingsTableDelegate?
    
    func setup(for user: User?) {
        self.usernameTextField?.text = user?.userName ?? ""
        self.emailTextField?.text = user?.userEmail ?? ""
        self.fullNameTextField?.text = user?.userFullName ?? ""
        self.usernameTextField?.delegate = self
        self.emailTextField?.delegate = self
        self.fullNameTextField?.delegate = self
        
        self.usernameView?.roundCorners(radius: 5, masksToBounds: false)
        self.emailView?.roundCorners(radius: 5, masksToBounds: false)
        self.fullNameView?.roundCorners(radius: 5, masksToBounds: false)

        self.usernameView?.addShadow(colour: UIColor.black, opacity: 0.5, offset: .zero, radius: 2)
        self.emailView?.addShadow(colour: UIColor.black, opacity: 0.5, offset: .zero, radius: 2)
        self.fullNameView?.addShadow(colour: UIColor.black, opacity: 0.5, offset: .zero, radius: 2)
        
        self.userImageView?.roundCorners(radius: 40)
        self.userImageView?.addGradientBorder(colours: [UIColor(hexString: "#3494E6"), UIColor(hexString: "#EC6EAD")])
        if let url = URL(string: user?.userProfileImageUrl ?? "") {
            Nuke.loadImage(with: url, into: self.userImageView ?? UIImageView())
        }
    }
}

extension SettingsAccountCell: UITextFieldDelegate {
    
    func filtered(range: String, text: String) -> Bool {
        let charset = NSCharacterSet(charactersIn: range).inverted
        let filtered = text.components(separatedBy: charset).joined(separator: "")
        return text == filtered
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.emailTextField {
            let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_@-."
            return filtered(range: ACCEPTABLE_CHARACTERS, text: string)
        }
        
        if textField == self.usernameTextField {
            let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_"
            return filtered(range: ACCEPTABLE_CHARACTERS, text: string)
        }
        
        if textField == self.fullNameTextField {
            let ACCEPTABLE_CHARACTERS = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
            return filtered(range: ACCEPTABLE_CHARACTERS, text: string)
        }

        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.updateEmail(email: self.emailTextField?.text ?? "")
        delegate?.updateUsername(username: self.usernameTextField?.text ?? "")
        delegate?.updateFullName(fullName: self.fullNameTextField?.text ?? "")
    }
}

class SettingsSecurityCell: UITableViewCell {
    
    @IBOutlet private weak var logOutButton: UIButton?
    @IBOutlet private weak var resetPasswordButton: UIButton?
    
    weak var delegate: SettingsTableDelegate?
    
    @IBAction func logoutButtonPressed(_ sender: UIButton?) {
        // TODO: Log Out
    }
    
    @IBAction func resetPasswordPressed(_ sender: UIButton?) {
        Auth.auth().sendPasswordReset(withEmail: GaryPortal.shared.user?.userEmail ?? "", completion: nil)
        self.delegate?.displayMessage(title: "Password Reset", message: "Please check your e-mail address for a password reset link")
    }
}

class SettingsAppCell: UITableViewCell {
    
    @IBAction func rateAppPressed(_ sender: UIButton?) {
        if let url = URL(string: GaryPortalConstants.AppReviewUrl) {
            UIApplication.shared.open(url)
        }
    }
}
