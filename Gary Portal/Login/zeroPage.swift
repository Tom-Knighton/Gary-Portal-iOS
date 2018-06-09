//
//  zeroPage.swift
//  Gary Portal
//
//  Created by Tom Knighton on 29/03/2018.
//  Copyright © 2018 Tom Knighton. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseAuth
import SendBirdSDK
class zeroPage: UIViewController {
    
    var userData : DatabaseReference!
    public struct userStats  {
        static var userUID = ""
        static var userName = ""
        static var sName = ""
        static var email = ""
        static var aPoints = 0
        static var aRank = ""
        static var pPoints = 0
        static var pRank = ""
        static var queued = false
        static var staff = false
        static var admin = false
        static var team = ""
        static var url = ""
        static var desc = ""
        static var quote = ""
        static var standing = ""
        static var mainRole = ""
        static var simplePrayers = 0
        static var meaningfulPrayers = 0
        static var sendbird = ""
        static var otherTeams = false
        
        static var protectedChats = [String]()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("reachedDidLoad")
        userData = Database.database().reference().child("users")
        print("set data")
        loadData()
        print("called load")
    }
    
    func loadData() {
        if Auth.auth().currentUser != nil {
            let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
            if launchedBefore == false {
                self.performSegue(withIdentifier: "firstToFirst", sender: self)
            } else {
                Database.database().reference().child("globalvariables").child("protectedChats").queryOrderedByKey().observeSingleEvent(of: .value, with: {(snap) in
                    if (!snap.exists()) {
                        return
                    }
                    
                    for item in snap.children {
                        let item = item as! DataSnapshot
                        let chat = item.value as? String ?? ""
                        if chat != "" {
                            userStats.protectedChats.append(chat)
                        }
                    }
                    
                })
                userData.child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: {(snapshot) in
                    
                    let dict = snapshot.value as! NSDictionary
                    
                    userStats.userUID = dict["uid"] as? String ?? ""
                    userStats.aPoints = dict["aPoints"] as? Int ?? 0
                    userStats.pPoints = dict["pPoints"] as? Int ?? 0
                    userStats.aRank = dict["aRank"] as? String ?? ""
                    userStats.pRank = dict["pRank"] as? String ?? ""
                    userStats.url = dict["urlToImage"] as? String ?? ""
                    userStats.userName = dict["fullName"] as? String ?? ""
                    userStats.sName = dict["sName"] as? String ?? ""
                    userStats.email = dict["email"] as? String ?? ""
                    userStats.queued = dict["queued"] as! Bool
                    userStats.staff = dict["staff"] as? Bool ?? false
                    userStats.admin = dict["admin"] as? Bool ?? false
                    userStats.team = dict["team"] as? String ?? ""
                    userStats.standing = dict["standing"] as? String ?? ""
                    userStats.sendbird = dict["sendbird"] as! String
                    userStats.otherTeams = dict["otherTeams"] as! Bool
                    SBDMain.connect(withUserId: userStats.sendbird, completionHandler: nil)
                    print(dict["uid"] as! String)
                    if userStats.queued == true {
                        self.performSegue(withIdentifier: "firstToQueued", sender: self)
                    } else {
                        print("connecting sendbird")
                        SBDMain.initWithApplicationId("BEC8A4BB-2A29-41A1-B361-1FC0EAA628AD")

                        SBDMain.connect(withUserId: dict["sendbird"] as! String, completionHandler: { (user, error) in
                            if error == nil {
                                print("connected sebdbird")
                                self.performSegue(withIdentifier: "firstToMain", sender: self)
                            }
                            else {
                                print(error?.localizedDescription)
                            }
                        })
                    }
                    
                    
                })
            }
           
        } else {
            print("should be segue")
            self.performSegue(withIdentifier: "firstToFirst", sender: self)
        }
    }



}
