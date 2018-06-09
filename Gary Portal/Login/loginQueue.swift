//
//  loginQueue.swift
//  Gary Portal
//
//  Created by Tom Knighton on 30/03/2018.
//  Copyright © 2018 Tom Knighton. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class loginQueue: UIViewController {

    var userData : DatabaseReference!
    @IBOutlet weak var display: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: "launchedBefore")
        userData = Database.database().reference().child("users")
        display.layer.cornerRadius = 20
        display.layer.masksToBounds = true
        checkForQueue()
        // Do any additional setup after loading the view.
    }

  
    func checkForQueue() {
        userData.child((Auth.auth().currentUser?.uid)!).observe(.value, with: {(snapshot) in
            
            let dict = snapshot.value as! NSDictionary
            if dict["queued"] as! Bool == true {
                print("queue")
            } else {
                self.performSegue(withIdentifier: "queueToMain", sender: self)
            }
            
        })
    }

}
