//
//  garyCell.swift
//  Mappr
//
//  Created by Tom Knighton on 28/01/2018.
//  Copyright © 2018 AroundMe. All rights reserved.
//

import UIKit
import Firebase
import PinchToZoomImageView
import AVKit
import AVFoundation
class ggCell: UITableViewCell {
    
    //    @IBOutlet weak var posterImage: UIImageView!
    //    @IBOutlet weak var posterName: UILabel!
    //    @IBOutlet weak var postOptions: roundedCusButton!
    //    @IBOutlet weak var post: UIImageView!
    //    @IBOutlet weak var heart: UILabel!
    //    @IBOutlet weak var likes: UILabel!
    //    @IBOutlet weak var desc: UILabel!
    //    @IBOutlet weak var comments: roundedCusButton!
    
    @IBOutlet weak var posterImage: UIImageView!
    
    @IBOutlet weak var posterName: UILabel!
    @IBOutlet weak var postOptions: UIButton!
    @IBOutlet weak var post: PinchToZoomImageView!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var comments: UILabel!
    @IBOutlet weak var postComment: UIButton!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var heart: UIButton!
    @IBOutlet weak var hearFilled: UIButton!
    @IBOutlet weak var videoPost: UIView!
    
    
    @IBOutlet weak var postBG: UIView!
    @IBOutlet weak var postBar: UIView!
    
    var ref : DatabaseReference!
    
    var canLike : Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        hearFilled.isHidden = true
        heart.isHidden = true
        postBG.layer.cornerRadius = 10
        postBG.layer.masksToBounds = true
        ref = Database.database().reference().child("feed")
        canLike = true
    }
    
    
    
    
    func viewFull(postNum : Int) {
        
    }
    
    func delete(postNum : Int) {
        
    }
    
    
    @IBAction func filledTouched(_ sender: UIButton) {
        let postNum = sender.tag
        print("\(postNum)"+" is num")
        ref.child("\(postNum)").queryOrderedByValue().observe(.value, with: {(snapshot) in
            if self.canLike == true {
                self.canLike = false
                let dict = snapshot.value as? [String:AnyObject]
                let oldN = dict?["Likes"] as? Int
                let newN = oldN! - 1
                
                if let likers = dict?["likeList"] as? [String:String] {
                    for(_,person) in likers {
                        if person == zeroPage.userStats.userName {
                            self.ref.child("\(postNum)").child("likeList").child(zeroPage.userStats.userName).removeValue()
                        }
                    }
                }
                
                self.ref!.child("\(postNum)").child("Likes").setValue(newN)
                self.ref!.child("\(postNum)").child("lastLike").setValue(newN)
                
                self.heart.isHidden = false
                self.hearFilled.isHidden = true
            }
            
            
        })
        self.canLike = true
    }
    
    @IBAction func heartTouched(_ sender: UIButton) {
        let postNum = sender.tag
        print("\(postNum)"+" is num")
        ref.child("\(postNum)").queryOrderedByValue().observe(.value, with: {(snapshot) in
            if self.canLike == true {
                self.canLike = false
                let dict = snapshot.value as? NSDictionary
                let oldN = dict?["Likes"] as? Int
                let newN = oldN! + 1
                let likeInfo : [String:Any] = [zeroPage.userStats.userName:zeroPage.userStats.userName]
                
                self.ref!.child("\(postNum)").child("likeList").setValue(likeInfo)
                self.ref!.child("\(postNum)").child("Likes").setValue(newN)
                self.ref!.child("\(postNum)").child("lastLike").setValue(newN)
                
                self.heart.isHidden = true
                self.hearFilled.isHidden = false
            }
            
            
        })
        self.canLike = true
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
