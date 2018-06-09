//
//  bannedView.swift
//  Gary Portal
//
//  Created by Tom Knighton on 10/05/2018.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class bannedView: UIViewController {

    @IBOutlet weak var redSquare: UIView!
    @IBOutlet weak var bannedR: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.redSquare.layer.cornerRadius = 30
        self.redSquare.layer.masksToBounds = true
    Database.database().reference().child("users").child(zeroPage.userStats.userUID).observe(.value, with: {(snapshot) in
            
            let dict = snapshot.value as? NSDictionary
            if dict?["banned"] as! Bool == false {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.bannedR.text = dict?["bannedR"] as? String ?? "Please contact a staff member if this is a mistake."
        }
        })
        
    }

    

   

}
