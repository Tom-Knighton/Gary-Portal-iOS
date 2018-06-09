//
//  signUpView.swift
//  Gary Portal
//
//  Created by Tom Knighton on 29/03/2018.
//  Copyright © 2018 Tom Knighton. All rights reserved.
//

import UIKit
import TextFieldEffects
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import AAPhotoCircleCrop

class signUpView: UITableViewController, UIImagePickerControllerDelegate, AACircleCropViewControllerDelegate, UINavigationControllerDelegate {
    
    var userData : DatabaseReference!
    var userStorage : StorageReference!
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var emailField: KaedeTextField!
    @IBOutlet weak var passField: KaedeTextField!
    @IBOutlet weak var confField: KaedeTextField!
    @IBOutlet weak var schoolField: KaedeTextField!
    @IBOutlet weak var nameField: KaedeTextField!
    @IBOutlet weak var profileDisplay: UIImageView!
    @IBOutlet weak var profileSelect: UIButton!
    
    @IBOutlet weak var signUp: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        emailField.layer.cornerRadius = 20
        emailField.layer.masksToBounds = true
        passField.layer.cornerRadius = 20
        passField.layer.masksToBounds = true
        confField.layer.cornerRadius = 20
        confField.layer.masksToBounds = true
        nameField.layer.cornerRadius = 20
        nameField.layer.masksToBounds = true
        schoolField.layer.cornerRadius = 20
        schoolField.layer.masksToBounds = true
        
        profileDisplay.layer.cornerRadius = 180 / 2
        profileDisplay.layer.masksToBounds = true
        
        profileSelect.layer.cornerRadius = 180 / 2
        profileSelect.layer.masksToBounds = true
        
        profileDisplay.layer.borderColor = UIColor.gray.cgColor
        profileDisplay.layer.borderWidth = 2.0
        
        signUp.layer.cornerRadius = 20
        signUp.layer.masksToBounds = true
        
        userStorage = Storage.storage().reference(forURL: "gs://gary-portal.appspot.com").child("users")
        userData = Database.database().reference()
        
        imagePicker.delegate = self
        

    }
    @IBAction func signUpPressed(_ sender: Any) {
        if (emailField.hasText != true || passField.hasText != true || confField.hasText != true || nameField.hasText != true || schoolField.hasText != true) {
            let alert = UIAlertController(title: "Error", message: "Please fill out all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if confField.text != passField.text {
            let alert = UIAlertController(title: "Error", message: "Your passwords do not match!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if passField.text!.count < 6 {
            let alert = UIAlertController(title: "Error", message: "Your password must be greater than 6 characters.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if profileDisplay.image == nil {
            let alert = UIAlertController(title: "Error", message: "Please select a profile image", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            
            self.performSegue(withIdentifier: "createToAgree", sender: self)
            
            
            
            
            
           /* let tc = UIAlertController(title: "Terms and Conditions", message: "By tapping 'agree' you agree to our terms and conditions", preferredStyle: .alert)
            tc.addAction(UIAlertAction(title: "View", style: .default, handler: {(action) in
                UIApplication.shared.open(URL(string: "https://www.garyportal.xyz/terms")!, options: [:], completionHandler: nil)
            }));
            tc.addAction(UIAlertAction(title: "Disagree", style: .destructive, handler: {(action) in
                self.dismiss(animated: true)
                return;
            }));
            tc.addAction(UIAlertAction(title: "Agree", style: .default, handler: {(action) in
                Auth.auth().createUser(withEmail: self.emailField.text!, password: self.passField.text!, completion: { (user, error) in
                    if error != nil {
                        let eA = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        eA.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(eA, animated: true, completion: nil)
                    } else {
                        let imageRef = self.userStorage.child("\(user!.uid).jpg")
                        let data = UIImageJPEGRepresentation(self.profileDisplay.image!, 0.5)
                        
                        let uploadTask = imageRef.putData(data!, metadata: nil, completion: {(metadata, error) in
                            
                            imageRef.downloadURL(completion: { (url, error) in
                                if let url = url {
                                    let info : [String:Any] = ["email": self.emailField.text!,
                                                               "pass": self.passField.text!,
                                                               "aPoints": 0,
                                                               "aRank": "TBA",
                                                               "banned": false,
                                                               "bannedR": "",
                                                               "chatBan": false,
                                                               "fullName": self.nameField.text!,
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
                                                               "desc": "Your description here",
                                                               "quote": "Set a featured quote",
                                                               "standing": "Good",
                                                               "teamRank": "TBA",
                                                               "mainRole": "TBA",
                                                               "prayersSimple": 0,
                                                               "prayersMeaningful": 0,
                                                               "sendbird": false]
                                    self.userData.child("users").child(user!.uid).setValue(info)
                                    self.performSegue(withIdentifier: "signToQueue", sender: self)
                                }
                            })
                            
                            
                        })
                        
                        uploadTask.resume()
                        
                        
                        
                    }
                })
            }));
            self.present(tc, animated: true, completion: nil)*/
           
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var chosenImage = UIImage()
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.dismiss(animated: true, completion: {
            let circleCropper = AACircleCropViewController()
            circleCropper.delegate = self
            circleCropper.image = chosenImage
            self.present(circleCropper, animated: true, completion: nil)
        })
    }

    @IBAction func selectPic(_ sender: Any) {
        let option = UIAlertController(title: "Profile Picture", message: "Select where to take your profile picture from", preferredStyle: .alert)
        
        option.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            self.camera()
        }))
        option.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (action) in
            self.gallery()
        }))
        option.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(option, animated: true, completion: nil)
    }
    
    func camera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func gallery() {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func circleCropDidCropImage(_ image: UIImage) {
        profileDisplay.image = image
        profileSelect.backgroundColor = UIColor.clear
    }
    
    func circleCropDidCancel() {
        print("canceled")
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createToAgree" {
            let dest = segue.destination as! agreementView
            dest.email = self.emailField.text!
            dest.pass = self.passField.text!
            dest.school = self.schoolField.text!
            dest.name = self.nameField.text!
            dest.image = self.profileDisplay.image!
        }
    }

}
