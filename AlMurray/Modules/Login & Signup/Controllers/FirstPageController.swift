//
//  FirstPageController.swift
//  AlMurray
//
//  Created by Tom Knighton on 17/08/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import UIKit
import FirebaseAuth

class FirstPageController: UIViewController {
    
    @IBOutlet private weak var fieldsView: UIView?
    @IBOutlet private weak var authenticatiorView: UIView?
    @IBOutlet private weak var passView: UIView?
    @IBOutlet private weak var emailInputField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    
    @IBOutlet private weak var loginButton: UIButton?
    @IBOutlet private weak var signupButton: UIButton?
    
    var originalFieldsY: CGFloat?
    
    let authenticationService = AuthenticationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.view.endEditingWhenTappedAround()
        self.originalFieldsY = self.fieldsView?.frame.origin.y
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }

    @objc
    func keyboardWillShow(_ sender: NSNotification) {
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= 100
        }
    }
    
    @objc
    func keyboardWillHide(_ notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        let email = (self.emailInputField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password = (self.passwordField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        if email == "" || password == "" {
            self.displayBasicAlert(title: "Error", message: "Your email or password was unrecognised!")
            return
        }
        
        self.toggleActivityIndicator(enable: true)
        self.authenticationService.authenticateUser(email, password) { (_, user) in
            DispatchQueue.main.async {
                if let user = user {
                    self.toggleActivityIndicator(enable: false)
                    GaryPortal.shared.user = user
                    UserDefaults.standard.set(true, forKey: "hasLoggedIn")
                    UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateInitialViewController()
                } else {
                    self.toggleActivityIndicator(enable: false)
                    self.displayBasicAlert(title: "Error", message: "Your email or password was unrecognised!")
                }
            }
        }
    }
    
    func setupUI() {
        self.authenticatiorView?.roundCorners(radius: 5, masksToBounds: false)
        self.passView?.roundCorners(radius: 5, masksToBounds: false)
        
        self.authenticatiorView?.addShadow(colour: UIColor.black, opacity: 0.5, offset: .zero, radius: 2)
        self.passView?.addShadow(colour: UIColor.black, opacity: 0.5, offset: .zero, radius: 2)
        
        self.loginButton?.roundCorners(radius: 25, masksToBounds: false)
        self.loginButton?.addShadow(opacity: 0.5, radius: 3)
        self.signupButton?.roundCorners(radius: 25, masksToBounds: false)
        self.signupButton?.addShadow(opacity: 0.5, radius: 3)
        self.signupButton?.layer.borderColor = UIColor.systemTeal.cgColor
        self.signupButton?.layer.borderWidth = 2
    }
}
