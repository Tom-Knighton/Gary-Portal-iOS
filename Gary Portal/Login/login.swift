//
//  login.swift
//  Gary Portal
//
//  Created by Tom Knighton on 29/03/2018.
//  Copyright © 2018 Tom Knighton. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import TextFieldEffects
import FirebaseAuth

class login: UIViewController {
    var userData : DatabaseReference!
    @IBOutlet weak var dismissTop: UIButton!
    @IBOutlet weak var screen: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailField: KaedeTextField!
    @IBOutlet weak var passField: KaedeTextField!
    
    @IBAction func loginPressed(_ sender: Any) {
        var canWrite : Bool = true
        if emailField.text == "" || emailField.text == " " {
            let alert = UIAlertController(title: "Error", message: "Please enter an e-mail address", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            canWrite = false
        }
        
        else if passField.text == "" || passField.text == " " {
            let alert = UIAlertController(title: "Error", message: "Please enter a password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            canWrite = false
        }
        
        if canWrite == true {
            Auth.auth().signIn(withEmail: emailField.text!, password: passField.text!, completion: { (user, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
                else {
                    UserDefaults.standard.set(true, forKey: "launchedBefore")
                    self.userData = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
                    self.userData.observe(.value, with: {(snapshot) in
                        
                        let dict = snapshot.value as! NSDictionary
                        if dict["queued"] as! Bool == true {
                            self.performSegue(withIdentifier: "logToQueue", sender: self)
                        } else {
                            self.performSegue(withIdentifier: "selfToRestart", sender: self)
                        }
                        
                    })
                }
            })
        }
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 20
        loginButton.layer.masksToBounds = true
        
        emailField.layer.cornerRadius = 20
        emailField.layer.masksToBounds = true
        passField.layer.cornerRadius = 20
        passField.layer.masksToBounds = true
        
        let path = UIBezierPath(roundedRect: screen.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        
        screen.layer.mask = maskLayer

    }
    
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)

    @IBAction func swipeGet(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)
        
        if sender.state == UIGestureRecognizerState.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizerState.changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                self.view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            }
        } else if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
            if touchPoint.y - initialTouchPoint.y > 100 {
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        }
    }
    @IBAction func topPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
