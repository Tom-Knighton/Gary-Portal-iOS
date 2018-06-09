//
//  aditFullScreen.swift
//  Gary Portal
//
//  Created by Tom Knighton on 29/05/2018.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SDWebImage
import AVKit
import AVFoundation
import Firebase
import FirebaseDatabase

class aditFullScreen: UIViewController {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionView: UITextView!
    
    @IBOutlet weak var nav: UINavigationBar!
    @IBOutlet weak var navT: UINavigationItem!
    
    public var caption : String!
    public var postURL : String!
    public var postNum: Int!
    public var posterName : String!
    public var type: String!
    public var exisitingViews : Int!
    
    var player : AVPlayer!
    

    override func viewWillAppear(_ animated: Bool) {
        if type == "Image" {
            imageView.isHidden = false
            videoView.isHidden = true
            imageView.sd_setImage(with: URL(string: postURL!), completed: nil)
        }
        else if type == "Video" {
            imageView.isHidden = true
            videoView.isHidden = false
            let videoURL = URL(string: self.postURL!)
            self.player = AVPlayer(url: videoURL!)
            let playerLayer = AVPlayerLayer(player: self.player)
            playerLayer.frame = self.videoView.bounds
            
            self.videoView.layer.addSublayer(playerLayer)
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
        
        if caption != "" && caption != " " {
            self.captionView.centerVerticallyT()
            self.captionView.layer.cornerRadius = 20
            self.captionView.layer.masksToBounds = true
            self.captionView.isHidden = false
            self.captionView.text = self.caption
        } else {
            self.captionView.isHidden = true
        }
        
    
        self.navT.title = self.posterName+"'s ADIT LOG"
        Database.database().reference().child("aditlog").child("\(postNum!)").updateChildValues(["views":exisitingViews + 1])
    }


    @IBAction func dismissView(_ sender: Any) {
        
        if type == "Video" {
            do{
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
                try AVAudioSession.sharedInstance().setActive(true)
            }catch{
                print("ERROR")
            }
            self.player.pause()
            self.player.replaceCurrentItem(with: nil)
        }

        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}
