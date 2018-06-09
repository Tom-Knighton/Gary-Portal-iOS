//
//  firstPage.swift
//  Gary Portal
//
//  Created by Tom Knighton on 29/03/2018.
//  Copyright © 2018 Tom Knighton. All rights reserved.
//

import UIKit
import SafariServices
class firstPage: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var webText: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 20
        loginButton.layer.masksToBounds = true
        signUpButton.layer.cornerRadius = 20
        signUpButton.layer.masksToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(goToWeb))
        webText.isUserInteractionEnabled = true
        webText.addGestureRecognizer(tap)

    }

  
    @objc func goToWeb(sender:UITapGestureRecognizer) {
        let safariVC = SFSafariViewController(url: URL(string: "https://www.garyportal.xyz")!)
        self.present(safariVC, animated: true, completion: nil)
    }
}
