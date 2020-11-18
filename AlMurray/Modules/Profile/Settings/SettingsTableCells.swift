//
//  SettingsTableCells.swift
//  AlMurray
//
//  Created by Tom Knighton on 16/11/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import UIKit
import Nuke

class SettingsAccountCell: UITableViewCell {

    @IBOutlet private weak var usernameTextField: UITextField?
    @IBOutlet private weak var emailTextField: UITextField?
    @IBOutlet private weak var fullNameTextField: UITextField?
    @IBOutlet private weak var usernameView: UIView?
    @IBOutlet private weak var emailView: UIView?
    @IBOutlet private weak var fullNameView: UIView!
    
    @IBOutlet private weak var userImageView: UIImageView?
    
    func setup(for user: User?) {
        self.usernameTextField?.text = user?.userName ?? ""
        self.emailTextField?.text = user?.userEmail ?? ""
        self.fullNameTextField?.text = user?.userFullName ?? ""
        
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

class SettingsSecurityCell: UITableViewCell {
    
    @IBOutlet private weak var logOutButton: UIButton?
    @IBOutlet private weak var resetPasswordButton: UIButton?
    
    @IBAction func logoutButtonPressed(_ sender: UIButton?) {
        // TODO: Log Out
    }
    
    @IBAction func resetPasswordPressed(_ sender: UIButton?) {
        // TODO: RESET API
    }
}

class SettingsAppCell: UITableViewCell {
    
}
