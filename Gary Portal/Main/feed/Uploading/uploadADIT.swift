//
//  uploadADIT.swift
//  Gary Portal
//
//  Created by Tom Knighton on 30/05/2018.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import YPImagePicker
import Firebase
import FirebaseDatabase
import FirebaseStorage
import AVKit
import AVFoundation
class uploadADIT: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var headerBG: UIView!
    @IBOutlet weak var postBG: UIView!
    @IBOutlet weak var captionBG: UIView!
    @IBOutlet weak var setCaption: UIButton!
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var uploadBG: UIView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var imageV: UIImageView!
    
    
    var hasPost = false
    var hasCapt = false
    var scaption = ""
    var currentMode = "image"
    var vURL : URL!
    var player : AVPlayer!
    var hasChosen = false
    var thumbnail : UIImage!
   
    func updatePostButton() {
        if hasPost {
            self.uploadButton.isEnabled = true
            self.uploadButton.layer.opacity = 1
        }
        else {
            self.uploadButton.isEnabled = false
            self.uploadButton.layer.opacity = 0.5
        }
    }
    @IBAction func addCaptPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add Caption", message: "Enter your caption", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(textfield) in
            textfield.autocapitalizationType = .sentences
            textfield.autocorrectionType = .yes
            textfield.maxLength = 140
        })
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
            let text = alert.textFields![0]
            if (text.text!.trim().count <= 0) {
                let alert2 = UIAlertController(title: "Error", message: "Please enter a caption", preferredStyle: .alert)
                alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert2, animated: true, completion: nil)
            }
            else {
                self.caption.text = text.text!.trim()
                self.hasCapt = true
                self.scaption = text.text!.trim()
                self.updatePostButton()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.closeButton.layer.cornerRadius = 10
        self.headerBG.layer.cornerRadius = 20
        self.postBG.layer.cornerRadius = 20
        self.captionBG.layer.cornerRadius = 20
        self.setCaption.layer.cornerRadius = 10
        self.uploadBG.layer.cornerRadius = 20
        self.uploadButton.layer.cornerRadius = 10
        
        
        self.closeButton.layer.masksToBounds = true
        self.headerBG.layer.masksToBounds = true
        self.postBG.layer.masksToBounds = true
        self.captionBG.layer.masksToBounds = true
        self.setCaption.layer.masksToBounds = true
        self.uploadButton.layer.masksToBounds = true
        self.uploadBG.layer.masksToBounds = true

    }

    @IBAction func pickerPressed(_ sender: Any) {
        var config = YPImagePickerConfiguration()
        config.screens = [.video, .photo]
        config.library.mediaType = .video
        config.video.fileType = .mov
        config.showsFilters = true
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking(completion: { items, _ in
            if let video = items.singleVideo {
                self.currentMode = "video"
                self.imageV.isHidden = true
                let videoURL = video.url
                self.thumbnail = video.thumbnail
                self.player = AVPlayer(url: videoURL)
                let playerLayer = AVPlayerLayer(player: self.player)
                playerLayer.frame = self.postBG.bounds
                self.vURL = video.url
                self.postBG.layer.addSublayer(playerLayer)
                do{
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [.mixWithOthers])
                    try AVAudioSession.sharedInstance().setActive(true)
                }catch{
                    print("ERROR")
                }
                self.player.play()
                
                NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: nil) { notification in
                    
                    self.player.seek(to: kCMTimeZero)
                    self.player.play()
                }
                
            }
            if let image = items.singlePhoto {
                self.imageV.isHidden = false
                self.imageV.image = image.image
                self.currentMode = "image"
            }
            self.hasPost = true
            self.updatePostButton()
            picker.dismiss(animated: true, completion: nil)
        })
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func postPressed(_ sender: Any) {
        if currentMode == "image" {
            Database.database().reference().child("globalvariables").observeSingleEvent(of: .value, with: {(snap) in
                let dict = snap.value as? NSDictionary
                let old = dict?["lastAdit"] as? Int
                let newN = old! - 1
                let imageRef = Storage.storage().reference().child("adit").child("adit\(newN).jpg")
                //let imageRef = Storage.storage().reference().child("adit").child("adit\(newN)_thumbnail.jpg")
                let data = UIImageJPEGRepresentation(self.imageV.image!, 0.5)
                //let dataThumb = UIImageJPEGRepresentation(self.thumnail, 0.7)
                let uploadTask = imageRef.putData(data!, metadata: nil, completion: { (meta, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return;
                    }
                    imageRef.downloadURL(completion: {(url, error2) in
                        if error2 != nil {
                            print(error2!.localizedDescription)
                        }
                        if let url = url {
                            let stamp = Date().millisecondsSince1970
                            Database.database().reference().child("aditlog").child("\(newN)").updateChildValues(["aditNum":newN, "postCaption": self.scaption, "postURL": url.absoluteString, "posterID": zeroPage.userStats.sendbird, "posterName":zeroPage.userStats.userName,"posterUID":zeroPage.userStats.userUID, "timestamp": stamp, "type":"Image","views": 0])
                            
                            Database.database().reference().child("globalvariables").updateChildValues(["lastAdit": newN])
                        }
                    })
                })
                uploadTask.resume()
                self.dismiss(animated: true, completion: nil)
            })
        }
        if currentMode == "video" {
           print("video")
            Database.database().reference().child("globalvariables").observeSingleEvent(of: .value, with: {(snap) in
                let dict = snap.value as? NSDictionary
                let old = dict?["lastAdit"] as? Int
                let newN = old! - 1
                let imageRef = Storage.storage().reference().child("adit").child("adit\(newN).mov")
                let thumbRef = Storage.storage().reference().child("adit").child("adit\(newN)_thumbnail.jpg")
                let dataThumb = UIImageJPEGRepresentation(self.thumbnail, 0.7)
                let uploadThumb = thumbRef.putData(dataThumb!, metadata: nil, completion: {(meta, error) in
                    
                    if error == nil {
                        print("vid2")
                        thumbRef.downloadURL(completion: {(urlT, errorT) in
                            if let urlT = urlT {
                                let uploadTask = imageRef.putFile(from: self.vURL, metadata: nil, completion: { (meta, error) in
                                    if error != nil {
                                        print(error!.localizedDescription)
                                        return;
                                    }
                                    imageRef.downloadURL(completion: {(url, error2) in
                                        if error2 != nil {
                                            print(error2!.localizedDescription)
                                        }
                                        if let url = url {
                                            let stamp = Date().millisecondsSince1970
                                            Database.database().reference().child("aditlog").child("\(newN)").updateChildValues(["aditNum":newN, "postCaption": self.scaption, "postURL": url.absoluteString, "posterID": zeroPage.userStats.sendbird, "posterName":zeroPage.userStats.userName,"posterUID":zeroPage.userStats.userUID, "timestamp": stamp, "type":"Video","views": 0, "thumbnail": urlT.absoluteString])
                                            
                                            Database.database().reference().child("globalvariables").updateChildValues(["lastAdit": newN])
                                        }
                                    })
                                })
                                uploadTask.resume()
                            }
                        })
                        
                    }
                    
                })
                uploadThumb.resume()
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
}
