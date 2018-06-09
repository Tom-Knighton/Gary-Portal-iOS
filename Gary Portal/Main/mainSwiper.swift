//
//  mainSwiper.swift
//  Gary Portal
//
//  Created by Tom Knighton on 31/03/2018.
//  Copyright © 2018 Tom Knighton. All rights reserved.
//

import UIKit
import EZSwipeController
import FirebaseDatabase
import Firebase
import OneSignal

class mainSwiper: EZSwipeController, EZSwipeControllerDataSource {
    func viewControllerData() -> [UIViewController] {
        return [newVC(viewController: "feedHeader"), newVC(viewController: "profileHeader"), newVC(viewController: "chatHeader")]
    }
    
    
    func indexOfStartingPage() -> Int {
        return 1
    }
    
    override func setupView() {
        super.setupView()
        datasource = self
        OneSignal.sendTag("sendbird", value: zeroPage.userStats.sendbird)
        navigationBarShouldNotExist = true
        checkDatabaseAndUserStats()
       
    }
    
    func newVC(viewController: String) -> UIViewController{
        return UIStoryboard(name: "mainScreens", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    
    
    func checkDatabaseAndUserStats() {
        
        if (!UserDefaults.standard.bool(forKey: "hasOnboarded")) {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "mainToTut", sender: nil)
            }
        }
        
        Database.database().reference().child("users").child(zeroPage.userStats.userUID).observe(.value, with: {(snapshot) in
            let dict = snapshot.value as? NSDictionary
            if dict?["banned"] as! Bool  == true {
                self.performSegue(withIdentifier: "mainToBanned", sender: self)
            }
        })
        Database.database().reference().child("globalvariables").observe(.value, with: {(snapshot) in
            let dict = snapshot.value as? NSDictionary
            if dict?["maintenance"] as! Bool == true {
                self.performSegue(withIdentifier: "mainToMaintenance", sender: self)
            }
        })
    }

    

}
