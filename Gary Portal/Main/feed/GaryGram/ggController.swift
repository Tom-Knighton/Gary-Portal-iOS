//
//  garygramView.swift
//  Mappr
//
//  Created by Tom Knighton on 28/01/2018.
//  Copyright © 2018 AroundMe. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseDatabase
import AVKit
import AVFoundation
import Photos
class ggController: UITableViewController {
    
    public struct currentNum {
        static var postNum : Int = 10000
    }
    @IBOutlet var table: UITableView!
    
    var ref : DatabaseReference!
    var garyList = [ggPost]()
    var toUpdate : Bool = true
    
    var scroll : CGPoint = CGPoint(x: 0, y: 0)
    
    var first = true
    private let refresherControl = UIRefreshControl()
    override func viewWillAppear(_ animated: Bool) {
        ref = Database.database().reference()
        self.first = true
        self.loadPosts()
        self.ref.child("feed").observe(.childChanged, with: { (snapshot) in
            self.first = false
            if self.toUpdate == true {
                self.toUpdate = false
                self.scroll = self.table.contentOffset
                self.loadPosts()
            }
        })
        
        
        if #available(iOS 10.0, *) {
            table.refreshControl = refresherControl
        } else {
            table.addSubview(refresherControl)
        }
        refresherControl.addTarget(self, action: #selector(refreshPage(_:)), for: .valueChanged)
        
        turnOnObsv()
    }
    @objc private func refreshPage(_ sender: Any) {
        loadPosts()
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UserDefaults.standard.bool(forKey: "compactGary") {
            return 289
        }
        else {
            return 504
        }
    }
    fileprivate var heightDictionary: [Int : CGFloat] = [:]
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        heightDictionary[indexPath.row] = cell.frame.size.height
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = heightDictionary[indexPath.row]
        return height ?? UITableViewAutomaticDimension
    }
    
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
       /* timer = Timer.every(3.seconds, {(timer: Timer) in
            self.loadPosts()
        })
        timer.start()*/
        self.loadPosts()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("invalidate")
        //timer.invalidate()
    }
    

    func turnOnObsv() {
        
    }
    
    func hasMore() {
        
    }
    
    func loadPosts() {
        self.garyList.removeAll()
        ref.child("feed").queryOrderedByKey().observeSingleEvent(of: .value, with: {(snapshot) -> Void in
            for child in snapshot.children {
                let child = child as! DataSnapshot
                if let childVal = child.value as? [String: AnyObject] {
                    let garyToShow = ggPost()
                    
                    let postNum = childVal["postNum"] as? Int ?? 10000
                    garyToShow.hasLiked = false
                    garyToShow.canLike = true
                    garyToShow.canDisLike = false
                    
                    if let likers = childVal["likeList"] as? [String:String] {
                        for(_,person) in likers {
                            if person == zeroPage.userStats.userName {
                                print("liked by current")
                                garyToShow.hasLiked = true
                            }
                        }
                    }
                    let desc = childVal["desc"] as? String ?? ""
                    let posterName = childVal["posterName"] as? String ?? ""
                    let posterURL = childVal["posterURL"] as? String ?? ""
                    let postURL = childVal["postURL"] as? String ?? ""
                    let likes = childVal["Likes"] as? Int ?? 0
                    let comments = childVal["Comments"] as? Int ?? 0
                    let type = childVal["type"] as! String
                    
                    
                    
                    
                    garyToShow.posterName = posterName
                    garyToShow.posterURL = posterURL
                    garyToShow.postURL = postURL
                    garyToShow.desc = desc
                    garyToShow.likes = likes
                    garyToShow.comments = comments
                    garyToShow.postNum = postNum
                    garyToShow.type = type
                    
                    
                    self.garyList.append(garyToShow)
                }
            }
            
            self.table.reloadData()
            self.table.scrollToNearestSelectedRow(at: UITableViewScrollPosition.top, animated: false)
            
            self.toUpdate = true
            self.refresherControl.endRefreshing()
        })
    }
    
    
    
    
    let standards = UserDefaults.standard

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ggCell!
        if standards.bool(forKey: "compactGary") {
            cell = table.dequeueReusableCell(withIdentifier: "compactGGCell") as! ggCell
        }
        else {
            cell = table.dequeueReusableCell(withIdentifier: "garyCell") as! ggCell
        }
        if self.garyList.count <= 0 {
            return cell
        }
        if self.garyList[indexPath.row].type == "Video"{
            cell.videoPost.isHidden = false
            if self.first == true {
                let videoURL = URL(string: self.garyList[indexPath.row].postURL!)
                let player = AVPlayer(url: videoURL!)

                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = cell.videoPost.bounds
                
                cell.videoPost.layer.addSublayer(playerLayer)
                player.isMuted = true
                do{
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
                    try AVAudioSession.sharedInstance().setActive(true)
                }catch{
                    print("ERROR")                    
                }
                player.play()
                
                NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { notification in
                    
                    player.seek(to: kCMTimeZero)
                    player.play()
                }
              
                
            }
        } else {
            cell.videoPost.isHidden = true
        }
        
        

        
        
        if garyList[indexPath.row].hasLiked == true {
            cell.heart.isHidden = true
            cell.hearFilled.isHidden = false
        } else {
            cell.heart.isHidden = false
            cell.hearFilled.isHidden = true
        }
        let likes = String(describing: garyList[indexPath.row].likes ?? 0)
        let comments = String(describing: garyList[indexPath.row].comments ?? 0)
        
        cell.posterName.text = garyList[indexPath.row].posterName
        cell.comments.text = "Comments: "+comments
        cell.likes.text = "Likes: "+likes
        cell.desc.text = garyList[indexPath.row].desc
        cell.posterImage.sd_setImage(with: URL(string: garyList[indexPath.row].posterURL!), completed: nil)
        cell.post.sd_setImage(with: URL(string: garyList[indexPath.row].postURL!), completed: nil)
        cell.postComment.tag = indexPath.row
        cell.postComment.addTarget(self, action: #selector(ggController.commentsClicked), for: .touchUpInside)
        
        cell.heart.tag = garyList[indexPath.row].postNum!
        cell.hearFilled.tag = garyList[indexPath.row].postNum!
        cell.postOptions.tag = garyList[indexPath.row].postNum!
        
        cell.tag = garyList[indexPath.row].postNum!
        cell.postOptions.addTarget(self, action: #selector(ggController.optsC), for: .touchUpInside)
        
        return cell
    }
    
    @objc func optsC(sender:UIButton) {
        let postNum = sender.tag
        self.ref.child("feed").child("\(postNum)").observeSingleEvent(of: .value, with: {(snapshot) -> Void in
            let optsAlert = UIAlertController(title: "Options", message: "Select an option", preferredStyle: .alert)
            let dictionary = snapshot.value as? NSDictionary
            let owner = dictionary?["posterUID"] as? String
            let senOwner = dictionary?["sendbird"] as? String
            let type = dictionary?["type"] as? String
            let url = dictionary?["postURL"] as? String
            
            //POST OWNED BY USER
            if owner == zeroPage
                .userStats.userUID {
                
                optsAlert.addAction(UIAlertAction(title: "Delete Post", style: .destructive, handler: { (action) in
                    self.ref.child("feed").child("\(postNum)").removeValue()
                    self.loadPosts()
                }))
                optsAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(optsAlert, animated: true, completion: nil)
            } else {
                
                
                
                // POST NOT OWNED BY USER
//                optsAlert.addAction(UIAlertAction(title: "View Profile", style: .default, handler: { (action) in
//                    seeUser.seeUserStats.uSendbird = senOwner!
//                    seeUser.seeUserStats.uName = owner!
//                    self.performSegue(withIdentifier: "feedToOther", sender: self)
//                }))
            
                
                optsAlert.addAction(UIAlertAction(title: "Report Post", style: .destructive, handler: { (action) in
                    
                    let optsOpt = UIAlertController(title: "Report", message: "Report Post", preferredStyle: .alert)
                    optsOpt.addAction(UIAlertAction(title: "NSFW", style: .default, handler: { (action) in
                        self.ref.child("reported").observeSingleEvent(of: .value, with: {(snap) -> Void in
                            let dict = snap.value as? NSDictionary
                            let reports = dict?["lastReport"] as? Int
                            let newN = reports! + 1
                            let reportInfo :[String:Any] = ["type":"post","post":"\(postNum)","reason":"NSFW","reporter":zeroPage.userStats.userName]
                            self.ref.child("reported").child("\(newN)").setValue(reportInfo)
                            self.ref.child("reported").child("lastReport").setValue(newN)
                            let OKdone = UIAlertController(title: "Information", message: "The post has been reported, it will be reviewed shortly. You may be contacted for further information regarding the report.", preferredStyle: .alert)
                            OKdone.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(OKdone, animated: true, completion: nil)
                            
                        })
                        
                    }))
                    optsOpt.addAction(UIAlertAction(title: "Breaks Policy", style: .default, handler: { (action) in
                        self.ref.child("reported").observeSingleEvent(of: .value, with: {(snap) -> Void in
                            let dict = snap.value as? NSDictionary
                            let reports = dict?["lastReport"] as? Int
                            let newN = reports! + 1
                            let reportInfo :[String:Any] = ["type":"post","post":"\(postNum)","reason":"Policy","reporter":zeroPage.userStats.userName]
                            self.ref.child("reported").child("\(newN)").setValue(reportInfo)
                            self.ref.child("reported").child("lastReport").setValue(newN)
                            let OKdone = UIAlertController(title: "Information", message: "The post has been reported, it will be reviewed shortly. You may be contacted for further information regarding the report.", preferredStyle: .alert)
                            OKdone.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(OKdone, animated: true, completion: nil)
                            
                        })
                    }))
                    optsOpt.addAction(UIAlertAction(title: "Breaks GaryGram", style: .default, handler: { (action) in
                        self.ref.child("reported").observeSingleEvent(of: .value, with: {(snap) -> Void in
                            let dict = snap.value as? NSDictionary
                            let reports = dict?["lastReport"] as? Int
                            let newN = reports! + 1
                            let reportInfo :[String:Any] = ["type":"post","post":"\(postNum)","reason":"Breaks GG","reporter":zeroPage.userStats.userName]
                            self.ref.child("reported").child("\(newN)").setValue(reportInfo)
                            self.ref.child("reported").child("lastReport").setValue(newN)
                            
                            let OKdone = UIAlertController(title: "Information", message: "The post has been reported, it will be reviewed shortly. You may be contacted for further information regarding the report.", preferredStyle: .alert)
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postsToComments" {
            let dest = segue.destination as! ggCommentTable
            dest.currentNum = currentNum.postNum
        }
    }
    
    @objc func commentsClicked(sender:UIButton) {
        print("Touched at \(sender.tag)")
        currentNum.postNum = garyList[sender.tag].postNum!
        print(currentNum.postNum)
        performSegue(withIdentifier: "postsToComments", sender: self)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return garyList.count
    }
    
    
    
}

