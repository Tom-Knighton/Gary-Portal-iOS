//
//  SignupEmailUsernameController.swift
//  AlMurray
//
//  Created by Tom Knighton on 20/08/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import UIKit
import CropViewController

class SignupController: UIViewController {

    @IBOutlet private weak var emailInputView: UIView?
    @IBOutlet private weak var usernameInputView: UIView?
    @IBOutlet private weak var fullNameInputView: UIView?
    @IBOutlet private weak var newPasswordInputView: UIView?
    @IBOutlet private weak var passwordConfirmInputView: UIView?
    @IBOutlet private weak var schoolInputView: UIView?
    @IBOutlet private weak var dobInputView: UIView?
    @IBOutlet private weak var genderInputView: UIView!
    @IBOutlet private weak var fieldsScrollView: UIScrollView!
    
    @IBOutlet private weak var emailTextField: UITextField?
    @IBOutlet private weak var usernameTextField: UITextField?
    @IBOutlet private weak var fullnameTextField: UITextField?
    @IBOutlet private weak var passwordTextField: UITextField?
    @IBOutlet private weak var confirmPasswordTextField: UITextField?
    @IBOutlet private weak var schoolTextField: UITextField?
    @IBOutlet private weak var dobTextField: UITextField?
    @IBOutlet private weak var genderTextField: UITextField?

    @IBOutlet private weak var profileImageView: UIImageView?
    
    let authService = AuthenticationService()
    let genderPickerView = UIPickerView()
    let dobPickerView = UIDatePicker()
    let genderData = ["Female", "Male", "Other"]
    let imagePicker = UIImagePickerController()
    
    var hasChosenImage = false
    var chosenProfilePicture: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.endEditingWhenTappedAround()
        self.setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func chooseImageButtonPressed(_ sender: Any) {
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        guard var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset: UIEdgeInsets = self.fieldsScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.fieldsScrollView.contentInset = contentInset
    }

    @objc
    func keyboardWillHide(notification: NSNotification) {

        let contentInset = UIEdgeInsets.zero
        self.fieldsScrollView.contentInset = contentInset
    }
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        let email = self.emailTextField?.text?.trim() ?? ""
        let username = self.usernameTextField?.text?.trim() ?? ""
        let fullName = self.fullnameTextField?.text?.trim() ?? ""
        let password = self.passwordTextField?.text?.trim() ?? ""
        let confirmPassword = self.confirmPasswordTextField?.text?.trim() ?? ""
        let school = self.schoolTextField?.text?.trim() ?? ""
        let dateOfBirth = self.dobTextField?.text?.trim() ?? ""
        let gender = self.genderTextField?.text?.trim() ?? ""
        let allFields = [email, username, fullName, password, confirmPassword, school, dateOfBirth, gender]
        
        if allFields.contains(where: { $0.isEmptyOrWhitespace() }) || !hasChosenImage {
            self.displayBasicAlert(title: GaryPortalConstants.Errors.Error, message: GaryPortalConstants.Errors.SignupFieldsNotCompleted)
            return
        }
        
        if password != confirmPassword {
            self.displayBasicAlert(title: GaryPortalConstants.Errors.Error, message: GaryPortalConstants.Errors.PasswordsDoNotMatch)
            return
        }
        
        if !email.isValidEmail {
            self.displayBasicAlert(title: GaryPortalConstants.Errors.Error, message: GaryPortalConstants.Errors.InvalidEmail)
            return
        }
        
        if !password.isValidPassword {
            self.displayBasicAlert(title: GaryPortalConstants.Errors.Error, message: GaryPortalConstants.Errors.InvalidPassword)
            return
        }
        
/* let newUser = User(UserId: "", UserEmail: email, UserFullName: fullName, UserSpanishName: "TBA", UserName: username, UserProfileImageUrl: "TBA", UserPassword: password, UserQuote: "TBA", UserBio: "TBA", UserIsStaff: false, UserIsAdmin: false, UserStanding: "Good", IsQueued: true, UserTeam: UserTeam(TeamName: "TBA", TeamRank: "Good"), UserRanks: UserRanks(AmigoRank: "TBA", PositivityRank: "TBA"), UserPoints: UserPoints(AmigoPoints: 0, PositivityPoints: 0, BowelsRelieved: 0, Prayers: 0, MeaningfulPrayers: 0), UserBans: UserBans(IsBanned: false, IsChatBanned: false, IsFeedBanned: false, BanReason: ""))
        self.authService.CreateNewUser(user: newUser) { (finalUser, error) in
            DispatchQueue.main.async {
                if let error = error {
                    if error == .EmailInUse {
                        self.displayBasicAlert(title: "Error", message: "That email address is already in use!")
                        return
                    }
                    self.displayBasicAlert(title: "Error", message: "An error occurred creating your account")
                    return
                }
                self.displayBasicAlert(title: "Success", message: finalUser?.UserName ?? "" )
            }
            
        }
*/
    }

    func setupUI() {
        
        self.emailInputView?.roundCorners(radius: 20, masksToBounds: false)
        self.usernameInputView?.roundCorners(radius: 20, masksToBounds: false)
        self.fullNameInputView?.roundCorners(radius: 20, masksToBounds: false)
        self.newPasswordInputView?.roundCorners(radius: 20, masksToBounds: false)
        self.passwordConfirmInputView?.roundCorners(radius: 20, masksToBounds: false)
        self.schoolInputView?.roundCorners(radius: 20, masksToBounds: false)
        self.dobInputView?.roundCorners(radius: 20, masksToBounds: false)
        self.genderInputView.roundCorners(radius: 20, masksToBounds: false)
        
        self.profileImageView?.roundCorners(radius: (self.profileImageView?.frame.width ?? 180) / 2, masksToBounds: false)
        self.profileImageView?.layer.borderColor = UIColor.white.cgColor
        self.profileImageView?.layer.borderWidth = 2
        
        self.emailInputView?.addShadow(opacity: 0.5, radius: 3)
        self.usernameInputView?.addShadow(opacity: 0.5, radius: 3)
        self.fullNameInputView?.addShadow(opacity: 0.5, radius: 3)
        self.newPasswordInputView?.addShadow(opacity: 0.5, radius: 3)
        self.passwordConfirmInputView?.addShadow(opacity: 0.5, radius: 3)
        self.schoolInputView?.addShadow(opacity: 0.5, radius: 3)
        self.dobInputView?.addShadow(opacity: 0.5, radius: 3)
        self.profileImageView?.addShadow(opacity: 0.5, radius: 3)
        self.genderInputView.addShadow(opacity: 0.5, radius: 3)
        
        self.emailTextField?.delegate = self
        self.usernameTextField?.delegate = self
        self.fullnameTextField?.delegate = self
        self.passwordTextField?.delegate = self
        self.confirmPasswordTextField?.delegate = self
        self.schoolTextField?.delegate = self
        self.dobTextField?.delegate = self
        self.genderTextField?.delegate = self
        
        self.emailTextField?.maxLength = 240
        self.usernameTextField?.maxLength = 32
        self.fullnameTextField?.maxLength = 32
        self.passwordTextField?.maxLength = 40
        self.confirmPasswordTextField?.maxLength = 40
        self.schoolTextField?.maxLength = 100
        
        self.genderPickerView.delegate = self
        self.genderPickerView.dataSource = self
        self.genderTextField?.inputView = self.genderPickerView
        
        self.dobPickerView.datePickerMode = .date
        self.dobPickerView.maximumDate = Calendar.current.date(byAdding: .year, value: -13, to: Date())
        self.dobPickerView.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        self.dobTextField?.inputView = self.dobPickerView
        
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = false
    }

    @objc
    func datePickerChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        self.dobTextField?.text = String(describing: dateFormatter.string(from: sender.date))
    }
}

extension SignupController: UITextFieldDelegate {
    
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
        
        if textField == self.fullnameTextField {
            let ACCEPTABLE_CHARACTERS = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
            return filtered(range: ACCEPTABLE_CHARACTERS, text: string)
        }
        
        if textField == self.passwordTextField || textField == self.confirmPasswordTextField {
            let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-.&!%$£*"
            return filtered(range: ACCEPTABLE_CHARACTERS, text: string)
        }
        
        if textField == self.schoolTextField {
            let ACCEPTABLE_CHARACTERS = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-"
            return filtered(range: ACCEPTABLE_CHARACTERS, text: string)
        }

        return true
    }
    
}

extension SignupController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.genderData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.genderData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.genderTextField?.text = self.genderData[row]
    }
    
}

extension SignupController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        self.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            self.displayBasicAlert(title: "Error", message: "There was an error picking your profile picture, please try again.")
            return
        }
        let cropViewController = CropViewController(croppingStyle: .circular, image: image)
        cropViewController.delegate = self
        self.present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.chosenProfilePicture = image
        self.profileImageView?.image = image
        self.hasChosenImage = true
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
}
