//
//  uploadPollView.swift
//  Gary Portal
//
//  Created by Tom Knighton on 29/05/2018.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
class uploadPollView: UIViewController {

    @IBOutlet weak var headerBG: UIView!
    @IBOutlet weak var questionBG: UIView!
    @IBOutlet weak var optionsBG: UIView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var closeButtn: UIButton!
    @IBOutlet weak var setQuestionButton: UIButton!
    
    @IBOutlet weak var setFirst: UIButton!
    @IBOutlet weak var setSecond: UIButton!
    @IBOutlet weak var second: UILabel!
    @IBOutlet weak var first: UILabel!
    
    @IBOutlet weak var question: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        self.hasQuestion = false
        self.hasOpt2 = false
        self.hasOpt1 = false
        self.updatePostButton()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hasQuestion = false
        self.hasOpt2 = false
        self.hasOpt1 = false
        self.updatePostButton()
        self.headerBG.layer.cornerRadius = 20
        self.questionBG.layer.cornerRadius = 20
        self.optionsBG.layer.cornerRadius = 20
        self.uploadButton.layer.cornerRadius = 20
        self.closeButtn.layer.cornerRadius = 10
        self.setQuestionButton.layer.cornerRadius = 10
        self.setFirst.layer.cornerRadius = 10
        self.setSecond.layer.cornerRadius = 10
        
        self.headerBG.layer.masksToBounds = true
        self.questionBG.layer.masksToBounds = true
        self.optionsBG.layer.masksToBounds = true
        self.uploadButton.layer.masksToBounds = true
        self.closeButtn.layer.masksToBounds = true
        self.setQuestionButton.layer.masksToBounds = true
        self.setFirst.layer.masksToBounds = true
        self.setSecond.layer.masksToBounds = true
    }
    var hasOpt1 = false
    var hasQuestion = false
    var hasOpt2 = false
    func updatePostButton() {
        if hasOpt1 && hasOpt2 && hasQuestion {
            self.uploadButton.isEnabled = true
            self.uploadButton.layer.opacity = 1
        }
        else {
            self.uploadButton.isEnabled = false
            self.uploadButton.layer.opacity = 0.5
        }
    }
    
    @IBAction func setQuestionPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add Question", message: "Enter your poll question below", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(textfield) in
            textfield.autocapitalizationType = .sentences
            textfield.autocorrectionType = .yes
        })
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
            let text = alert.textFields![0]
            if (text.text!.trim().count <= 0) {
                let alert2 = UIAlertController(title: "Error", message: "Please enter a question", preferredStyle: .alert)
                alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert2, animated: true, completion: nil)
            }
            else {
                self.question.text = text.text!.trim()
                self.hasQuestion = true
                self.updatePostButton()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func setFirstPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add Option", message: "Enter your poll option below", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(textfield) in
            textfield.autocapitalizationType = .sentences
            textfield.autocorrectionType = .yes
            textfield.maxLength = 15
        })
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
            let text = alert.textFields![0]
            if (text.text!.trim().count <= 0) {
                let alert2 = UIAlertController(title: "Error", message: "Please enter an option", preferredStyle: .alert)
                alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert2, animated: true, completion: nil)
            }
            else {
                self.first.text = text.text!.trim()
                self.hasOpt1 = true
                self.updatePostButton()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func setSecondPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add Option", message: "Enter your poll option below", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(textfield) in
            textfield.autocapitalizationType = .sentences
            textfield.autocorrectionType = .yes
            textfield.maxLength = 15
        })
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
            let text = alert.textFields![0]
            if (text.text!.trim().count <= 0) {
                let alert2 = UIAlertController(title: "Error", message: "Please enter an option", preferredStyle: .alert)
                alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert2, animated: true, completion: nil)
            }
            else {
                self.second.text = text.text!.trim()
                self.hasOpt2 = true
                self.updatePostButton()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func uploadPressed(_ sender: Any) {
        if hasOpt2 && hasOpt1 && hasQuestion {
            Database.database().reference().child("globalvariables").observeSingleEvent(of: .value, with: {(snap) in
                let dict =  snap.value as? NSDictionary
                let old = dict?["lastPoll"] as? Int
                let newN = old! - 1
                Database.database().reference().child("poll").child("\(newN)").updateChildValues(["pollNum":newN,"posterID":zeroPage.userStats.sendbird,"posterName":zeroPage.userStats.userName,"posterUID":zeroPage.userStats.userUID,"posterURL":zeroPage.userStats.url,"question":self.question.text!,"totalVotes": 0,"vote1":self.first.text!,"vote2":self.second.text!,"vote1Votes":0,"vote2Votes":0])
                
                Database.database().reference().child("globalvariables").updateChildValues(["lastPoll": newN])
                
                self.dismiss(animated: true, completion: nil)
                
            })
        }
    }
    
    
    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    


}
