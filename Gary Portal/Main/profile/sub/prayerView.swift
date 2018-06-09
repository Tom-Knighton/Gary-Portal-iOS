//
//  prayerView.swift
//  Gary Portal
//
//  Created by Tom Knighton on 02/04/2018.
//  Copyright © 2018 Tom Knighton. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import ChameleonFramework

class prayerView: UIViewController {

    @IBOutlet weak var screen: UIView!
    @IBOutlet weak var meaningfulPrayer: UIButton!
    @IBOutlet weak var currentPrayers: UILabel!
    @IBOutlet weak var simplePrayer: UIButton!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var clearPrayer: UIButton!
    
    
    @IBAction func hideTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            self.hideButton.layer.isHidden = false
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        self.simplePrayer.layer.cornerRadius = 20
        self.simplePrayer.layer.masksToBounds = true
        
        self.meaningfulPrayer.layer.cornerRadius = 20
        self.meaningfulPrayer.layer.masksToBounds = true

        self.clearPrayer.layer.cornerRadius = 20
        self.clearPrayer.layer.masksToBounds = true

        self.screen.layer.cornerRadius = 20
        self.screen.layer.masksToBounds = true
        
        self.clearPrayer.backgroundColor = GradientColor(.leftToRight, frame: self.clearPrayer.frame, colors: [UIColor(red:0.02, green:0.81, blue:1.00, alpha:1.0), UIColor(red:0.82, green:0.02, blue:1.00, alpha:1.0)])

    }
    
    func loadData() {
        Database.database().reference().child("users").child(zeroPage.userStats.userUID).observe(.value, with: {(snapshot) in
            
            let dict = snapshot.value as! NSDictionary
            let simps = dict["prayersSimple"] as! Int
            let mean = dict["prayersMeaningful"] as! Int
            let admin = dict["admin"] as! Bool
            if admin == true {
                self.clearPrayer.isHidden = false
            } else {
                self.clearPrayer.isHidden = true
            }
            let totalPrayers = simps + mean
            self.currentPrayers.text = "Current Prayers: \(totalPrayers)"
        })
    }
    
    @IBAction func simplePressed(_ sender: Any) {
        Database.database().reference().child("users").child(zeroPage.userStats.userUID).observeSingleEvent(of: .value, with: {(snapshot) in
            
            let dict = snapshot.value as! NSDictionary
            let current = dict["prayersSimple"] as! Int
            let new = current + 1
            Database.database().reference().child("users").child(zeroPage.userStats.userUID).child("prayersSimple").setValue(new)
        })
        
    }
    
    @IBAction func meaningfulPressed(_ sender: Any) {
        Database.database().reference().child("users").child(zeroPage.userStats.userUID).observeSingleEvent(of: .value, with: {(snapshot) in
            
            let dict = snapshot.value as! NSDictionary
            let current = dict["prayersMeaningful"] as! Int
            let new = current + 1
            Database.database().reference().child("users").child(zeroPage.userStats.userUID).child("prayersMeaningful").setValue(new)
        })
    }
    
    @IBAction func clearPressed(_ sender: Any) {
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: {(snapshot) in
            
            
            let array:NSArray = snapshot.children.allObjects as NSArray
            for child in array {
                let snap = child as! DataSnapshot
                snap.ref.child("prayersSimple").setValue(0)
                snap.ref.child("prayersMeaningful").setValue(0)

            }
           
        })
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
