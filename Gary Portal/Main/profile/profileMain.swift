//
//  profileMain.swift
//  Gary Portal
//
//  Created by Tom Knighton on 31/03/2018.
//  Copyright © 2018 Tom Knighton. All rights reserved.
//

import UIKit
import ChameleonFramework
import Firebase
import FirebaseDatabase
import SDWebImage
import SafariServices
class profileMain: UITableViewController {

    @IBOutlet weak var statsView: UIView!
    @IBOutlet weak var pointsView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var miscView: UIView!
    
    
    @IBOutlet weak var staffButton: UIButton!
    @IBOutlet weak var prayerRoom: UIButton!
    @IBOutlet weak var rules: UIButton!
    @IBOutlet weak var maps: UIButton!
    @IBOutlet weak var book: UIButton!
    @IBOutlet weak var settings: UIButton!
    
    
    @IBOutlet weak var profileDisplay: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var sName: UILabel!
    @IBOutlet weak var aPoints: UILabel!
    @IBOutlet weak var pPoints: UILabel!
    @IBOutlet weak var aRank: UILabel!
    @IBOutlet weak var pRank: UILabel!
    @IBOutlet weak var team: UILabel!
    
    
    var isStaffEnabled : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        
        //Data
        profileDisplay.layer.cornerRadius = 90
        profileDisplay.layer.masksToBounds = true
        profileDisplay.layer.borderWidth = 1
        profileDisplay.layer.borderColor = GradientColor(.diagonal, frame: profileDisplay.layer.frame, colors: [UIColor(red:0.02, green:0.81, blue:1.00, alpha:1.0), UIColor(red:0.82, green:0.02, blue:1.00, alpha:1.0)]).cgColor
        
        loadData()
        
        
        //Views
        headerView.layer.cornerRadius = 20
        headerView.layer.masksToBounds = true
        
        pointsView.layer.cornerRadius = 20
        pointsView.layer.masksToBounds = true
        
        statsView.layer.cornerRadius = 20
        statsView.layer.masksToBounds = true
        
        miscView.layer.cornerRadius = 20
        miscView.layer.masksToBounds = true
        
        
        //Buttons
        
        prayerRoom.layer.cornerRadius = 20
        prayerRoom.layer.masksToBounds = true
        rules.layer.cornerRadius = 20
        rules.layer.masksToBounds = true
        maps.layer.cornerRadius = 20
        maps.layer.masksToBounds = true
        book.layer.cornerRadius = 20
        book.layer.masksToBounds = true
        settings.layer.cornerRadius = 20
        settings.layer.masksToBounds = true
        staffButton.layer.cornerRadius = 20
        staffButton.layer.masksToBounds = true
        
        maps.backgroundColor = GradientColor(.leftToRight, frame: maps.layer.frame, colors: [UIColor(red:0.02, green:0.81, blue:1.00, alpha:1.0), UIColor(red:0.82, green:0.02, blue:1.00, alpha:1.0)])
        book.backgroundColor = GradientColor(.leftToRight, frame: book.layer.frame, colors: [UIColor(red:0.02, green:0.81, blue:1.00, alpha:1.0), UIColor(red:0.82, green:0.02, blue:1.00, alpha:1.0)])
       
    }
    
    func loadData() {
        Database.database().reference().child("users").child(zeroPage.userStats.userUID).observe(.value, with: {(snapshot) in
            
            let dict = snapshot.value as! NSDictionary
            
            self.profileDisplay.sd_setImage(with: URL(string: dict["urlToImage"] as! String), completed: nil)
            self.name.text = (dict["fullName"] as! String)
            self.sName.text = (dict["sName"] as! String)
            self.aPoints.text = "AMIGO POINTS: "+("\(dict["aPoints"] as! Int)")
            self.pPoints.text = "POSITIVITY POINTS: "+("\(dict["pPoints"] as! Int)")
            self.aRank.text = (dict["aRank"] as! String).uppercased()
            self.pRank.text = (dict["pRank"] as! String).uppercased()
            self.team.text = (dict["team"] as! String).uppercased()
            
            /*if (dict["admin"] as! Bool) == true {
                self.isStaffEnabled = true
                self.staffButton.setTitle("Admin Panel", for: UIControlState.normal)
                self.staffButton.backgroundColor = UIColor(red:0.59, green:0.00, blue:0.00, alpha:1.0)
            } else if (dict["staff"] as! Bool) == true {
                self.isStaffEnabled = true
                self.staffButton.setTitle("Staff Panel", for: UIControlState.normal)
                self.staffButton.backgroundColor = UIColor(red:0.59, green:0.00, blue:0.00, alpha:1.0)
            } else {
                self.isStaffEnabled = false
                self.staffButton.backgroundColor = GradientColor(.leftToRight, frame: self.staffButton.frame, colors: [UIColor(red:0.02, green:0.81, blue:1.00, alpha:1.0), UIColor(red:0.82, green:0.02, blue:1.00, alpha:1.0)])
                self.staffButton.setTitle("Visit Website", for: UIControlState.normal)
            }*/
            
            self.isStaffEnabled = false
            self.staffButton.backgroundColor = GradientColor(.leftToRight, frame: self.staffButton.frame, colors: [UIColor(red:0.02, green:0.81, blue:1.00, alpha:1.0), UIColor(red:0.82, green:0.02, blue:1.00, alpha:1.0)])
            self.staffButton.setTitle("Visit Website", for: UIControlState.normal)
            
        })
        
    }
    
    @IBAction func mapsPressed(_ sender: Any) {
        let safariVC = SFSafariViewController(url: URL(string: "https://garyportal.typeform.com/to/wqObIy")!)
        self.present(safariVC, animated: true, completion: nil)
    }
    
    
    @IBAction func bookPressed(_ sender: Any) {
        let safariVC = SFSafariViewController(url: URL(string: "https://www.garyportal.xyz/computerdating")!)
        self.present(safariVC, animated: true, completion: nil)
    }
    
    @IBAction func rulesPressed(_ sender: Any) {let safariVC = SFSafariViewController(url: URL(string: "https://www.garyportal.xyz/rr")!)
        self.present(safariVC, animated: true, completion: nil)
        
    }
    
    @IBAction func panelPressed(_ sender: Any) {
        if isStaffEnabled == false {
            let safariVC = SFSafariViewController(url: URL(string: "https://www.garyportal.xyz")!)
            self.present(safariVC, animated: true, completion: nil)
        } else if isStaffEnabled == true {
            self.performSegue(withIdentifier: "profToStaff", sender: self)
        }
    }
    
    
    

}
