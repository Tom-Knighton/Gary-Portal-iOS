//
//  settingsView.swift
//  Gary Portal
//
//  Created by Tom Knighton on 01/04/2018.
//  Copyright © 2018 Tom Knighton. All rights reserved.
//

import UIKit
import ChameleonFramework
import FirebaseAuth

class settingsView: UIViewController {

    @IBOutlet weak var compact: UISwitch!
    @IBOutlet weak var largeSwitch: UISwitch!
    @IBOutlet weak var hideButon: UIButton!
    @IBOutlet weak var screen: UIView!
    @IBOutlet weak var logOutButton: UIButton!
    let standards = UserDefaults.standard

    override func viewDidAppear(_ animated: Bool) {
        if standards.bool(forKey: "smallChat") {
            largeSwitch.isOn = true
        } else {
            largeSwitch.isOn = false
        }
        if standards.bool(forKey: "compactGary") {
            compact.isOn = true
        }
        else {
            compact.isOn = false
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.hideButon.layer.isHidden = false
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screen.layer.cornerRadius = 20
        screen.layer.masksToBounds = true
        
        logOutButton.layer.cornerRadius = 20
        logOutButton.layer.masksToBounds = true
        
        logOutButton.backgroundColor = GradientColor(.leftToRight, frame: self.logOutButton.frame, colors: [UIColor(red:0.02, green:0.81, blue:1.00, alpha:1.0), UIColor(red:0.82, green:0.02, blue:1.00, alpha:1.0)])
        
        

    }
    @IBAction func logoutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "logout", sender: self)
        } catch {
            let error = UIAlertController(title: "Error", message: "There was an error signing out!", preferredStyle: .alert)
            error.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
    }
    @IBAction func chatSwitch(_ sender: UISwitch) {
        if largeSwitch.isOn == true {
            standards.set(true, forKey: "smallChat")
        } else {
            standards.set(false, forKey: "smallChat")
        }
    }
    @IBAction func compactSwitch(_ sender: UISwitch) {
        if compact.isOn == true {
            standards.set(true, forKey: "compactGary")
        } else {
            standards.set(false, forKey: "compactGary")
        }
    }
    
    @IBAction func hidePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    @IBAction func swipeGetter(_ sender: UIPanGestureRecognizer) {
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
    
}
