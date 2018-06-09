//
//  pollController.swift
//  Gary Portal
//
//  Created by Tom Knighton on 20/05/2018.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import ChameleonFramework
import SDWebImage
import Firebase
import FirebaseDatabase

class pollController: UITableViewController {

    @IBOutlet var table: UITableView!
    
    var toUpdate : Bool = true
    
    var scroll : CGPoint = CGPoint(x: 0, y: 0)
    
    var first = true
    var pollList = [poll]()
    
    
    
    var timer: Timer!

    override func viewDidAppear(_ animated: Bool) {
        /*timer = Timer.every(3.seconds, {(timer: Timer) in
            self.loadPolls()
        })
        timer.start()*/
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        //timer.invalidate()
        
    }
    private var refresher = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.first = true
        self.loadPolls()
        Database.database().reference().child("poll").observe(.childChanged, with: { (snapshot) in
            self.first = false
            if self.toUpdate == true {
                self.toUpdate = false
                self.scroll = self.table.contentOffset
                self.loadPolls()
            }
        })
        
        if #available(iOS 10.0, *) {
            table.refreshControl = refresher
        } else {
            table.addSubview(refresher)
        }
        refresher.addTarget(self, action: #selector(refreshPage(_:)), for: .valueChanged)
        
    }
    @objc private func refreshPage(_ sender: Any) {
        loadPolls()
    }
    fileprivate var heightDictionary: [Int : CGFloat] = [:]
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 306
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        heightDictionary[indexPath.row] = cell.frame.size.height
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = heightDictionary[indexPath.row]
        return height ?? UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pollList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "pollCell", for: indexPath) as! pollCell
        cell.questionLabel.text = self.pollList[indexPath.row].question
        cell.afterVotes1.text = (self.pollList[indexPath.row].vote1Label! + " votes: \(self.pollList[indexPath.row].votesFor1!)")
        cell.afterVotes2.text = (self.pollList[indexPath.row].vote2Label! + " votes: \(self.pollList[indexPath.row].votesFor2!)")
        cell.vote1.tag = self.pollList[indexPath.row].pollNum!
        cell.vote2.tag = self.pollList[indexPath.row].pollNum!
        cell.pollOptions.tag = self.pollList[indexPath.row].pollNum!
        cell.pollOptions.addTarget(self, action: #selector(pollController.optsC), for: .touchUpInside)
        cell.vote1.setTitle(self.pollList[indexPath.row].vote1Label, for: UIControlState.normal)
        cell.vote2.setTitle(self.pollList[indexPath.row].vote2Label, for: UIControlState.normal)
        cell.questionerImage.sd_setImage(with: URL(string: self.pollList[indexPath.row].posterURL!), completed: nil)
        cell.questioner.text = self.pollList[indexPath.row].posterName
        
        if self.pollList[indexPath.row].hasVoted! {
            cell.afterVoteView.isHidden = false
            cell.vote1.isHidden = true
            cell.vote2.isHidden = true
        }
        else {
            cell.afterVoteView.isHidden = true
            cell.vote2.isHidden = false
            cell.vote1.isHidden = false
        }
        return cell
        
    }
    
    @objc func optsC(sender: UIButton) {
        let tag = sender.tag
        
        Database.database().reference().child("poll").child("\(tag)").observeSingleEvent(of: .value, with: {(snapshot) in
            
            let optsAlert = UIAlertController(title: "Options", message: "Select an option", preferredStyle: .alert)
            let dict = snapshot.value as? NSDictionary
            let uid = dict?["posterUID"] as? String
            if uid == zeroPage.userStats.userUID {
                optsAlert.addAction(UIAlertAction(title: "!! RESET ALL VOTES !!", style: .destructive, handler: { (action) in
                    Database.database().reference().child("poll").child("\(tag)").child("votesList").removeValue()
                    Database.database().reference().child("poll").child("\(tag)").updateChildValues(["vote1Votes": 0, "vote2Votes": 0])
                    self.loadPolls()
                }))
                
                optsAlert.addAction(UIAlertAction(title: "Delete Poll", style: .destructive, handler: { (action) in
                    Database.database().reference().child("poll").child("\(tag)").removeValue()
                    self.loadPolls()
                }))
                optsAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(optsAlert, animated: true, completion: nil)
            }
            
            else {
                optsAlert.addAction(UIAlertAction(title: "Report Poll", style: .destructive, handler: { (action) in
                    
                    let optsOpt = UIAlertController(title: "Report", message: "Report Poll", preferredStyle: .alert)
                    optsOpt.addAction(UIAlertAction(title: "NSFW", style: .default, handler: { (action) in
                        Database.database().reference().child("reported").observeSingleEvent(of: .value, with: {(snap) -> Void in
                            let dict = snap.value as? NSDictionary
                            let reports = dict?["lastReport"] as? Int
                            let newN = reports! + 1
                            let reportInfo :[String:Any] = ["type":"poll","poll":"\(tag)","reason":"NSFW","reporter":zeroPage.userStats.userName]
                            Database.database().reference().child("reported").child("\(newN)").setValue(reportInfo)
                            Database.database().reference().child("reported").child("lastReport").setValue(newN)
                            let OKdone = UIAlertController(title: "Information", message: "The poll has been reported, it will be reviewed shortly. You may be contacted for further information regarding the report.", preferredStyle: .alert)
                            OKdone.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(OKdone, animated: true, completion: nil)
                            
                        })
                        
                    }))
                    optsOpt.addAction(UIAlertAction(title: "Breaks Policy", style: .default, handler: { (action) in
                        Database.database().reference().child("reported").observeSingleEvent(of: .value, with: {(snap) -> Void in
                            let dict = snap.value as? NSDictionary
                            let reports = dict?["lastReport"] as? Int
                            let newN = reports! + 1
                            let reportInfo :[String:Any] = ["type":"poll","poll":"\(tag)","reason":"Policy","reporter":zeroPage.userStats.userName]
                            Database.database().reference().child("reported").child("\(newN)").setValue(reportInfo)
                            Database.database().reference().child("reported").child("lastReport").setValue(newN)
                            let OKdone = UIAlertController(title: "Information", message: "The poll has been reported, it will be reviewed shortly. You may be contacted for further information regarding the report.", preferredStyle: .alert)
                            OKdone.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(OKdone, animated: true, completion: nil)
                            
                        })
                    }))
                    optsOpt.addAction(UIAlertAction(title: "Breaks Feed", style: .default, handler: { (action) in
                        Database.database().reference().child("reported").observeSingleEvent(of: .value, with: {(snap) -> Void in
                            let dict = snap.value as? NSDictionary
                            let reports = dict?["lastReport"] as? Int
                            let newN = reports! + 1
                            let reportInfo :[String:Any] = ["type":"poll","poll":"\(tag)","reason":"Breaks polls","reporter":zeroPage.userStats.userName]
                            Database.database().reference().child("reported").child("\(newN)").setValue(reportInfo)
                            Database.database().reference().child("reported").child("lastReport").setValue(newN)
                            
                            let OKdone = UIAlertController(title: "Information", message: "The poll has been reported, it will be reviewed shortly. You may be contacted for further information regarding the report.", preferredStyle: .alert)
                            OKdone.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(OKdone, animated: true, completion: nil)
                            
                        })
                    }))
                    optsOpt.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(optsOpt, animated: true,completion: nil)
                    
                }))
                optsAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(optsAlert, animated: true, completion: nil)
            }
        })
    }
    
    
    func loadPolls() {
        self.pollList.removeAll()
        Database.database().reference().child("poll").queryOrderedByValue().observeSingleEvent(of: .value, with: {(snapshot) in
            
            for child in snapshot.children {
                let child = child as! DataSnapshot
                 if let childVal = child.value as? [String: AnyObject] {
                    let pollToAdd = poll()
                    pollToAdd.posterName = childVal["posterName"] as? String
                    pollToAdd.posterURL = childVal["posterURL"] as? String
                    pollToAdd.question = childVal["question"] as? String
                    pollToAdd.vote1Label = childVal["vote1"] as? String
                    pollToAdd.vote2Label = childVal["vote2"] as? String
                    pollToAdd.pollNum = childVal["pollNum"] as? Int
                    pollToAdd.votesFor1 = childVal["vote1Votes"] as? Int
                    pollToAdd.votesFor2 = childVal["vote2Votes"] as? Int
                    pollToAdd.posterUID = childVal["posterUID"] as? String
                    pollToAdd.hasVoted = false
                    if let likers = childVal["votesList"] as? [String:String] {
                        for(person,_) in likers {
                            if person == zeroPage.userStats.userUID {
                                print("voted by current")
                                pollToAdd.hasVoted = true
                            }
                        }
                    }
                    self.pollList.append(pollToAdd)
                }
            }
            self.table.reloadData()
            self.refresher.endRefreshing()
        })
    }

}
