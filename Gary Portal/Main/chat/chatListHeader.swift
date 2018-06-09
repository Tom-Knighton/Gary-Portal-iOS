//
//  chatListHeader.swift
//  Gary Portal
//
//  Created by Tom Knighton on 08/04/2018.
//  Copyright © 2018 Tom Knighton. All rights reserved.
//

import UIKit
import SendBirdSDK
import SDWebImage
import ChameleonFramework
class chatListHeader: UIViewController{
    
    
    
    @IBOutlet weak var smallScreen: UIView!
    @IBOutlet weak var screen: UIView!
    
    var screenToShow = "small"
    
    var groupChannelListViewController: GroupChannelListViewController?
    
    override func viewDidLoad() {
        if SBDMain.getCurrentUser() == nil {
            SBDMain.connect(withUserId: zeroPage.userStats.sendbird, completionHandler: { (user, error) in
            })
        }
        self.ppImage.sd_setImage(with: URL(string: zeroPage.userStats.url), completed: nil)
        self.ppImage.layer.cornerRadius = 18
        self.ppImage.layer.masksToBounds = true
        
        self.ppImage.layer.borderColor = GradientColor(.leftToRight, frame: self.ppImage.layer.frame, colors: [UIColor(red:0.02, green:0.81, blue:1.00, alpha:1.0), UIColor(red:0.82, green:0.02, blue:1.00, alpha:1.0)]).cgColor
        self.ppImage.layer.borderWidth = 1
        self.createButton.layer.cornerRadius = 20
        self.createButton.layer.masksToBounds = true
        
    }

    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var ppImage: UIImageView!
    
 
    override func viewWillAppear(_ animated: Bool) {
        if SBDMain.getCurrentUser() == nil {
            SBDMain.connect(withUserId: zeroPage.userStats.sendbird, completionHandler: { (user, error) in    
            })
            
        }
        if UserDefaults.standard.bool(forKey: "smallChat") {
            screen.isHidden = true
            smallScreen.isHidden = false
            let path = UIBezierPath(roundedRect: smallScreen.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20))
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            
            smallScreen.layer.mask = maskLayer
        } else {
            smallScreen.isHidden = true
            screen.isHidden = false
            let path = UIBezierPath(roundedRect: screen.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20))
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            
            screen.layer.mask = maskLayer
        }
    }
 

    
}
