//
//  agreementView.swift
//  Gary Portal
//
//  Created by Tom Knighton on 25/05/2018.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import WebKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
class agreementView: UIViewController, WKUIDelegate {

    
    
    @IBOutlet weak var webView: UIWebView!
    var email : String!
    var pass : String!
    var school : String!
    var name : String!
    var image : UIImage!
    var userData : DatabaseReference!
    var userStorage : StorageReference!
    @IBOutlet weak var navBar: UINavigationBar!
    override func loadView() {
        super.loadView()
       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.agreeB.isEnabled = true
        self.disagreeB.isEnabled = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        userStorage = Storage.storage().reference(forURL: "gs://gary-portal.appspot.com").child("users")
        userData = Database.database().reference()
        let request = URLRequest(url: URL(string: "https://garyportal.xyz/terms")!)
        webView.loadRequest(request)
    }
    
    func create() {
        Auth.auth().createUser(withEmail: email!, password: pass!, completion: {(user, error) in
            
            if error != nil {
                let eA = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                eA.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action) in
                    
                    self.dismiss(animated: true, completion: nil)
                    
                }))
                self.present(eA, animated: true, completion: nil)
            }
            else {
                let imageRef = self.userStorage.child("\(user?.uid).jpg")
                let data = UIImageJPEGRepresentation(self.image!, 0.5)
                
                let uploadTask = imageRef.putData(data!, metadata: nil, completion: {(metadata, error) in
                    imageRef.downloadURL(completion: {(url, error) in
                        if let url = url {
                            let info : [String:Any] = ["email": self.email!,
                                                       "pass": self.pass!,
                                                       "aPoints": 0,
                                                       "aRank": "TBA",
                                                       "banned": false,
                                                       "bammedR": "",
                                                       "chatBan": false,
                                                       "fullName": self.name!,
                                                       "pPoints": 0,
                                                       "pRank": "TBA",
                                                       "queued": true,
                                                       "sName": "TBA",
                                                       "staff": false,
                                                       "admin": false,
                                                       "team": "TBA",
                                                       "uid": user!.uid,
                                                       "urlToImage": url.absoluteString,
                                                       "id": "TBA",
                                                       "desc": "",
                                                       "quote": "",
                                                       "standing": "Okay",
                                                       "teamRank": "TBA",
                                                       "mainRole": "TBA",
                                                       "prayersSimple": 0,
                                                       "prayersMeaningful": 0,
                                                       "sendbird": "demoa",
                                                       "hidden": false,
                                                       "otherTeams": false]
                            self.userData.child("users").child(user!.uid).setValue(info)
                            self.performSegue(withIdentifier: "createToQ", sender: self)
                        }
                        
                    })
                    
                })
                uploadTask.resume()
                
            }
            
        })
        
        
    }
    @IBOutlet weak var agreeB: UIBarButtonItem!
    @IBOutlet weak var disagreeB: UIBarButtonItem!
    
    @IBAction func disagree(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func agree(_ sender: Any) {
        self.agreeB.isEnabled = false
        self.disagreeB.isEnabled = false
        create()
    }
    
}
