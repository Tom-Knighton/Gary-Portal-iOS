//
//  uploadGG.swift
//  Gary Portal
//
//  Created by Tom Knighton on 29/05/2018.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SDWebImage
import AVKit
import AVFoundation
import ChameleonFramework
import YPImagePicker
import Firebase
import FirebaseDatabase
import FirebaseStorage
class uploadGG: UIViewController{

    
    @IBOutlet weak var slider: UISegmentedControl!
    @IBOutlet weak var selectImageView: UIView!
    @IBOutlet weak var selectVideoView: UIView!
    @IBOutlet weak var uploadDesc: UIButton!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var uploadPost: UIButton!
    @IBOutlet weak var uploadVideo: UIButton!
    @IBOutlet weak var uploadImage: UIButton!
    
    
    var hasDesc = false
    var hasImage = false
    var hasVideo = false
    
    func updatePostButton() {
        if currentMode == "image" {
            if hasDesc && hasImage {
                self.postButton.isEnabled = true
                self.postButton.layer.opacity = 1
            }
            else {
                self.postButton.isEnabled = false
                self.postButton.layer.opacity = 0.5
            }
        }
        if currentMode == "video" {
            if hasDesc && hasVideo {
                self.postButton.isEnabled = true
                self.postButton.layer.opacity = 1
            }
            else {
                self.postButton.isEnabled = false
                self.postButton.layer.opacity = 0.5
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentMode = "image"
        self.updatePostButton()
        self.selectVideoView.isHidden = true
        self.selectImageView.isHidden = false
        
        self.headerBG.layer.cornerRadius = 20
        self.descView.layer.cornerRadius = 20
        self.selectImageView.layer.cornerRadius = 20
        self.selectVideoView.layer.cornerRadius = 20
        self.closeButton.layer.cornerRadius = 10
        self.uploadDesc.layer.cornerRadius = 10
        self.postButton.layer.cornerRadius = 20
        
        self.headerBG.layer.masksToBounds = true
        self.descView.layer.masksToBounds = true
        self.selectImageView.layer.masksToBounds = true
        self.selectVideoView.layer.masksToBounds = true
        self.closeButton.layer.masksToBounds = true
        self.uploadDesc.layer.masksToBounds = true
        self.postButton.layer.masksToBounds = true
    }

    @IBAction func uploadImagePressed(_ sender: Any) {
       
        // Build a picker with your configuration
        var config = YPImagePickerConfiguration()
        config.screens = [.photo, .library]
        config.library.mediaType = .photo
        let picker = YPImagePicker(configuration: config)

        picker.didFinishPicking { items, _ in
            if let photo = items.singlePhoto {
                self.imageView.image = photo.image
                self.hasImage = true
                self.updatePostButton()
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    var player : AVPlayer!

    var vURL: URL!
    @IBAction func uploadVideoPressed(_ sender: Any) {
        var config = YPImagePickerConfiguration()
        config.screens = [.video, .library]
        config.library.mediaType = .video
        config.video.fileType = .mov
        
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking(completion: { items, _ in
            if let video = items.singleVideo {
                let videoURL = video.url
                self.player = AVPlayer(url: videoURL)
                let playerLayer = AVPlayerLayer(player: self.player)
                playerLayer.frame = self.selectVideoView.bounds
                self.vURL = video.url
                self.selectVideoView.layer.addSublayer(playerLayer)
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
            self.hasVideo = true
            self.updatePostButton()
            picker.dismiss(animated: true, completion: nil)
        })
        self.present(picker, animated: true, completion: nil)
    }

    @IBOutlet weak var headerBG: UIView!
    @IBOutlet weak var descView: UIView!
    @IBOutlet weak var descButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    
    
    
    
    
    
    @IBAction func postPressed(_ sender: Any) {
        if currentMode == "image" {
            Database.database().reference().child("globalvariables").observeSingleEvent(of: .value, with: {(snapshot) in
                let dict = snapshot.value as? NSDictionary
                let last = dict?["lastPost"] as? Int
                let newN = last! - 1
                let imageRef = Storage.storage().reference().child("feed").child("feed\(newN).jpg")
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yy"
                let dateResult = formatter.string(from: date)
                let data = UIImageJPEGRepresentation(self.imageView.image!, 0.5)
                let uploadTask = imageRef.putData(data!, metadata: nil, completion: {(metadata, error) in
                    if error != nil { print(error!.localizedDescription)}
                    
                    imageRef.downloadURL(completion: { (url, errorThree) in
                        if errorThree != nil {print(errorThree!.localizedDescription)}
                        if let url = url {
                            Database.database().reference().child("feed").child("\(newN)").updateChildValues(["Comments":1, "Likes":0,"desc":self.descLabel.text!,"lastLike": 1,"postNum":newN,"posterName":zeroPage.userStats.userName,"posterID":zeroPage.userStats.sendbird,"posterURL":zeroPage.userStats.url, "posterUID": zeroPage.userStats.userUID,"postURL":url.absoluteString, "type": "Image", "commentList": ["1":["comment":self.descLabel.text!,"commenterurl":zeroPage.userStats.url, "date":dateResult]]])
                        }
                    })
                    
                    Database.database().reference().child("globalvariables").updateChildValues(["lastPost": newN])
                })
                uploadTask.resume()
                self.dismiss(animated: true, completion: nil)
                
            })
        }
        if currentMode == "video" {
            Database.database().reference().child("globalvariables").observeSingleEvent(of: .value, with: {(snapshot) in
                let dict = snapshot.value as? NSDictionary
                let last = dict?["lastPost"] as? Int
                let newN = last! - 1
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yy"
                let dateResult = formatter.string(from: date)
                let storageReference = Storage.storage().reference().child("feed").child("feed\(newN).mov")
                let uploadTask =  storageReference.putFile(from: self.self.vURL, metadata: nil, completion: { (metadata, error) in
                    if error == nil {
                        print("Successful video upload")
                    } else {
                        print(error!.localizedDescription)
                    }
                    storageReference.downloadURL(completion: { (url, errorThree) in
                        if errorThree != nil {print(errorThree!.localizedDescription)}
                        if let url = url {
                            Database.database().reference().child("feed").child("\(newN)").updateChildValues(["Comments":1, "Likes":0,"desc":self.descLabel.text!,"lastLike": 1,"postNum":newN,"posterName":zeroPage.userStats.userName,"posterID":zeroPage.userStats.sendbird,"posterURL":zeroPage.userStats.url, "posterUID": zeroPage.userStats.userUID,"postURL":url.absoluteString, "type": "Video", "commentList": ["1":["comment":self.descLabel.text!,"commenterurl":zeroPage.userStats.url, "date":dateResult]]])
                        }
                    })
                    
                    Database.database().reference().child("globalvariables").updateChildValues(["lastPost": newN])

                })
                    
                uploadTask.resume()
                self.dismiss(animated: true, completion: nil)
            })
        }
        
    }
    @IBAction func descPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add Description", message: "Enter your description below", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(textfield) in
            textfield.autocapitalizationType = .sentences
            textfield.autocorrectionType = .yes
        })
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
            let text = alert.textFields![0]
            if (text.text!.trim().count <= 0) {
                let alert2 = UIAlertController(title: "Error", message: "Please enter a description", preferredStyle: .alert)
                alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert2, animated: true, completion: nil)
            }
            else {
                self.descLabel.text = text.text!.trim()
                self.hasDesc = true
                self.updatePostButton()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    var currentMode = "image"
    @IBAction func sliderChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.selectImageView.isHidden = false
            self.selectVideoView.isHidden = true
            currentMode = "image"
            self.updatePostButton()
        }
        else if sender.selectedSegmentIndex == 1 {
            self.selectImageView.isHidden = true
            self.selectVideoView.isHidden = false
            currentMode = "video"
            self.updatePostButton()
        }
    }
    
    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
