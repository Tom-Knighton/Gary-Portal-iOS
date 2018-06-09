//
//  pollCell.swift
//  Gary Portal
//
//  Created by Tom Knighton on 20/05/2018.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import ChameleonFramework
import Firebase
import FirebaseDatabase
class pollCell: UITableViewCell {

    @IBOutlet weak var pollOptions: UIButton!
    @IBOutlet weak var questioner: UILabel!
    @IBOutlet weak var questionerImage: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var vote1: UIButton!
    @IBOutlet weak var vote2: UIButton!
    @IBOutlet weak var afterVoteView: UIView!
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var afterVotes1: UILabel!
    @IBOutlet weak var afterVotes2: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        card.layer.cornerRadius = 20
        card.layer.masksToBounds = true
        
        let path = UIBezierPath(roundedRect: vote1.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: 20, height: 20))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        
        vote1.layer.mask = maskLayer
        
        let path2 = UIBezierPath(roundedRect: vote2.bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: 20, height: 20))
        let maskLayer2 = CAShapeLayer()
        maskLayer2.path = path2.cgPath
        
        vote2.layer.mask = maskLayer2
        
        vote1.backgroundColor = GradientColor(.leftToRight, frame: vote1.layer.frame, colors: [UIColor(red:0.65, green:0.44, blue:0.94, alpha:1.0),UIColor(red:0.81, green:0.55, blue:0.95, alpha:1.0), UIColor(red:0.99, green:0.73, blue:0.61, alpha:1.0)])
        
        vote2.backgroundColor = GradientColor(.leftToRight, frame: vote2.layer.frame, colors: [UIColor(red:0.97, green:0.72, blue:0.20, alpha:1.0), UIColor(red:0.99, green:0.29, blue:0.10, alpha:1.0)])
        
        afterVoteView.layer.cornerRadius = 20
        afterVoteView.layer.masksToBounds = true
        afterVoteView.backgroundColor = GradientColor(.leftToRight, frame: afterVoteView.layer.frame, colors: [UIColor(red:0.02, green:0.81, blue:1.00, alpha:1.0), UIColor(red:0.82, green:0.02, blue:1.00, alpha:1.0)])
        
    }
    
    
    @IBAction func vote1Pressed(_ sender: UIButton) {
        let tag = sender.tag
        Database.database().reference().child("poll").child("\(tag)").observeSingleEvent(of: .value, with: {(snap) in
            let dict = snap.value as? NSDictionary
            let votes2 = dict?["vote2Votes"] as? Int
            let votes1 = dict?["vote1Votes"] as? Int
            let vote1 = dict?["vote1"] as? String
            let vote2 = dict?["vote2"] as? String
            Database.database().reference().child("poll").child("\(tag)").updateChildValues(["vote1Votes": votes1! + 1])
             Database.database().reference().child("poll").child("\(tag)").child("votesList").updateChildValues([zeroPage.userStats.userUID:"vote1"])
            
            
            self.afterVotes1.text = vote1! + " votes: \(votes1! + 1)"
            self.afterVotes2.text = vote2! + " votes: \(votes2!)"
            
        })
        
        self.vote1.isHidden = true
        self.vote2.isHidden = true
        self.afterVoteView.isHidden = false
    }
    @IBAction func vote2Pressed(_ sender: UIButton) {
        let tag = sender.tag
        Database.database().reference().child("poll").child("\(tag)").observeSingleEvent(of: .value, with: {(snap) in
            let dict = snap.value as? NSDictionary
            let votes2 = dict?["vote2Votes"] as? Int
            let votes1 = dict?["vote1Votes"] as? Int
            let vote1 = dict?["vote1"] as? String
            let vote2 = dict?["vote2"] as? String
            Database.database().reference().child("poll").child("\(tag)").updateChildValues(["vote2Votes": votes2! + 1])
            Database.database().reference().child("poll").child("\(tag)").child("votesList").updateChildValues([zeroPage.userStats.userUID:"vote2"])
            
            self.afterVotes1.text = vote1! + " votes: \(votes1!)"
            self.afterVotes2.text = vote2! + " votes: \(votes2! + 1)"
        })
        self.vote1.isHidden = true
        self.vote2.isHidden = true
        self.afterVoteView.isHidden = false
    }
    
    

}
