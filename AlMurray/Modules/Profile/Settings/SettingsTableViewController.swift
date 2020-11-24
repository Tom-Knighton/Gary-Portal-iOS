//
//  SettingsTableViewController.swift
//  AlMurray
//
//  Created by Tom Knighton on 16/11/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import UIKit

protocol SettingsTableDelegate: class {
    
    func updateEmail(email: String)
    func updateUsername(username: String)
    func updateFullName(fullName: String)
    func updateImage(newImage: UIImage)
    func presentView(viewcontroller: UIViewController)
    func displayMessage(title: String, message: String)
}

class SettingsTableViewController: UIViewController, SettingsTableDelegate {

    @IBOutlet private weak var settingsTable: SettingsTableView?
    @IBOutlet private weak var closeButton: UIButton?
    @IBOutlet private weak var saveButton: UIButton?
    
    internal var newEmail: String?
    internal var newUsername: String?
    internal var newFullName: String?
    internal var newProfileImage: UIImage?
    internal var hasUserChosenNewImage: Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.endEditingWhenTappedAround()
        self.settingsTable?.endEditingWhenTappedAround()
        
        self.settingsTable?.settingsDelegate = self
        
        self.settingsTable?.delegate = self.settingsTable
        self.settingsTable?.dataSource = self.settingsTable
        self.settingsTable?.rowHeight = UITableView.automaticDimension
        self.settingsTable?.estimatedRowHeight = 270
        self.settingsTable?.reloadData()
        
        self.closeButton?.roundCorners(radius: 5)
        self.saveButton?.roundCorners(radius: 5)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let email = self.newEmail ?? GaryPortal.shared.user?.userEmail ?? ""
        let username = self.newUsername ?? GaryPortal.shared.user?.userName ?? ""
        let fullName = self.newFullName ?? GaryPortal.shared.user?.userFullName ?? ""
        
        self.toggleActivityIndicator(enable: true)
        AuthenticationService().isEmailFree(email) { (isEmailFree) in
            if !isEmailFree && email != GaryPortal.shared.user?.userEmail ?? "" {
                self.displayBasicAlert(title: "Error", message: "That email address is already in use, please try another one")
                self.toggleActivityIndicator(enable: false)
                return
            }
            
            AuthenticationService().isUsernameFree(username) { (isUsernameFree) in
                if !isUsernameFree && username != GaryPortal.shared.user?.userName ?? "" {
                    self.toggleActivityIndicator(enable: false)
                    self.displayBasicAlert(title: "Error", message: "That username is already in use, please try another one")
                    return
                }
                
                var newUserDetails = UserDetails(username: username, email: email, fullName: fullName, profilePictureUrl: GaryPortal.shared.user?.userProfileImageUrl ?? "")
                
                if self.hasUserChosenNewImage ?? false {
                    UserService().updateUserProfileImage(userId: GaryPortal.shared.user?.userId ?? "", newImage: self.newProfileImage ?? UIImage()) { (newImageUrl) in
                        newUserDetails.profilePictureUrl = newImageUrl
                        self.updateSettings(with: newUserDetails)
                    }
                } else {
                    self.updateSettings(with: newUserDetails)
                }
            }
        }
    }
    
    func updateSettings(with userDetails: UserDetails) {
        UserService().updateUserSettings(userId: GaryPortal.shared.user?.userId ?? "", userDetails: userDetails) { (newUser) in
            self.toggleActivityIndicator(enable: false)
            GaryPortal.shared.user = newUser
            print(newUser?.userEmail ?? "email blank")
            self.displayBasicAlert(title: "Success", message: "Settings saved successfully")
        }
    }
    
    func updateEmail(email: String) {
        self.newEmail = email
    }
    
    func updateUsername(username: String) {
        self.newUsername = username
    }
    
    func updateFullName(fullName: String) {
        self.newFullName = fullName
    }
    
    func updateImage(newImage: UIImage) {
        self.newProfileImage = newImage
        self.hasUserChosenNewImage = true
    }
    
    func presentView(viewcontroller: UIViewController) {
        self.present(viewcontroller, animated: true, completion: nil)
    }
    
    func displayMessage(title: String, message: String) {
        self.displayBasicAlert(title: title, message: message)
    }
    
}
