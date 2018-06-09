//
//  maintenanceView.swift
//  Gary Portal
//
//  Created by Tom Knighton on 10/05/2018.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class maintenanceView: UIViewController {

    @IBOutlet weak var whiteSquare: UIView!
    @IBOutlet weak var maintenanceText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.whiteSquare.layer.cornerRadius = 30
        self.whiteSquare.layer.masksToBounds = true
        Database.database().reference().child("globalvariables").observe(.value, with: {(snapshot) in
            let dict = snapshot.value as? NSDictionary
            if dict?["maintenance"] as! Bool == false {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.maintenanceText.attributedText = NSAttributedString(string: "This app is under maintenance \n" + (dict?["mainR"] as? String ?? ""))
            }
        })
    }


}
