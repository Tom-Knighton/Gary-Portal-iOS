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
import TOCropViewController

class SettingsAccountCell: UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {

    @IBOutlet private weak var usernameTextField: UITextField?
    @IBOutlet private weak var emailTextField: UITextField?
    @IBOutlet private weak var fullNameTextField: UITextField?
    @IBOutlet private weak var usernameView: UIView?
    @IBOutlet private weak var emailView: UIView?
    @IBOutlet private weak var fullNameView: UIView!
    
    @IBOutlet private weak var changeUserImageButton: UIButton?
    @IBOutlet private weak var userImageView: UIImageView?
    
    private let imagePicker = UIImagePickerController()
    
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
        
        self.changeUserImageButton?.roundCorners(radius: 40)
        self.userImageView?.roundCorners(radius: 40)
        self.userImageView?.addGradientBorder(colours: [UIColor(hexString: "#3494E6"), UIColor(hexString: "#EC6EAD")])
        if let url = URL(string: user?.userProfileImageUrl ?? "") {
            Nuke.loadImage(with: url, into: self.userImageView ?? UIImageView())
        }
    }
    
    @IBAction func changeUserImagePressed(_ sender: Any) {
        self.imagePicker.delegate = self
        self.delegate?.presentView(viewcontroller: imagePicker)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        picker.dismiss(animated: true) {
            let crop = TOCropViewController(croppingStyle: .circular, image: image)
            crop.delegate = self
            crop.modalPresentationStyle = .currentContext
            self.delegate?.presentView(viewcontroller: crop)
        }
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropToCircularImage image: UIImage, with cropRect: CGRect, angle: Int) {
        self.userImageView?.image = image
        cropViewController.dismiss(animated: true, completion: nil)
        self.delegate?.updateImage(newImage: image)
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
        GaryPortal.shared.logoutUser()
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
