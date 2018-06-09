//
//  aditController.swift
//  Gary Portal
//
//  Created by Tom Knighton on 29/05/2018.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import ChameleonFramework
import SDWebImage
import AVFoundation
import AVKit
import Firebase
import FirebaseDatabase
import AVFoundation

class aditController: UITableViewController {

    var aditList = [AditLog]()
    
    
    @IBOutlet var table: UITableView!
    private let refresherControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresherControl
        } else {
            tableView.addSubview(refresherControl)
        }
        refresherControl.addTarget(self, action: #selector(refreshLogs(_:)), for: .valueChanged)

        self.loadlogs()
       
    }
    
    @objc private func refreshLogs(_ sender: Any) {
        loadlogs()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.table.dequeueReusableCell(withIdentifier: "aditLogCell") as! aditCell
        
        if self.aditList[indexPath.row].type == "Video" {
            print("video")
            cell.aditVideoThumbnail.isHidden = false
            cell.aditThumbnail.isHidden = false
            cell.posterName.text = self.aditList[indexPath.row].posterName
            cell.aditThumbnail.sd_setImage(with: URL(string: self.aditList[indexPath.row].thumbnail!), completed: nil)
            
            
        }
        else {
            cell.posterName.text = self.aditList[indexPath.row].posterName
            cell.aditThumbnail.sd_setImage(with: URL(string: self.aditList[indexPath.row].postURL!), completed: nil)
            cell.aditVideoThumbnail.isHidden = true
            cell.aditThumbnail.isHidden = false
        }
        
        cell.postOptions.tag = self.aditList[indexPath.row].postNum!
        cell.postOptions.addTarget(self, action: #selector(optsC(sender:)), for: .touchUpInside)
        let timestamp = self.aditList[indexPath.row].timestamp
        let date = NSDate(timeIntervalSince1970: TimeInterval(timestamp! / 1000))
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        formatter.locale = NSLocale(localeIdentifier: "en_US") as Locale?
        cell.postedTime.text = "\((date as Date).timeAgoSinceNow())"
        
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.aditList.count
    }

    func loadlogs() {
        self.aditList.removeAll()
        
        Database.database().reference().child("aditlog").queryOrderedByKey().observeSingleEvent(of: .value, with: {(snapshot) in
            
            for child in snapshot.children {
                let child = child as! DataSnapshot
                if let childVal = child.value as? [String:AnyObject] {
                    let aditToShow = AditLog()
                    let aditNum = childVal["aditNum"] as? Int
                    let postURL = childVal["postURL"] as? String
                    let posterName = childVal["posterName"] as? String
                    let timestamp = childVal["timestamp"] as? Int
                    let views = childVal["views"] as? Int
                    let posterUID = childVal["posterUID"] as? String
                    let type = childVal["type"] as? String
                    let caption = childVal["postCaption"] as? String
                    if type == "Video" {
                        let thumbnail = childVal["thumbnail"] as? String
                        aditToShow.thumbnail = thumbnail
                    }
                    
                    aditToShow.posterName = posterName
                    aditToShow.posterUID = posterUID
                    aditToShow.postURL = postURL
                    aditToShow.postNum = aditNum
                    aditToShow.timestamp = timestamp
                    aditToShow.views = views
                    aditToShow.type = type
                    aditToShow.caption = caption
                    
                    if !((Date().millisecondsSince1970 - aditToShow.timestamp!) > 86400000) {
                        self.aditList.append(aditToShow)
                    }
                }
            }
            self.table.reloadData()
            self.refresherControl.endRefreshing()
            
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.table.deselectRow(at: indexPath, animated: false)
        currentTapped = indexPath.row
        self.performSegue(withIdentifier: "aditToFullAdit", sender: self)
    }
    
    var currentTapped : Int!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "aditToFullAdit" {
            let dest = segue.destination as! aditFullScreen
            dest.type = self.aditList[currentTapped].type
            dest.postURL = self.aditList[currentTapped].postURL
            dest.postNum = self.aditList[currentTapped].postNum
            dest.posterName = self.aditList[currentTapped].posterName
            dest.caption = self.aditList[currentTapped].caption
            dest.exisitingViews = self.aditList[currentTapped].views
        }
    }
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    @objc func optsC(sender: UIButton) {
        let tag = sender.tag
        
        Database.database().reference().child("aditlog").child("\(tag)").observeSingleEvent(of: .value, with: {(snapshot) in
            
            let optsAlert = UIAlertController(title: "Options", message: "Select an option", preferredStyle: .alert)
            let dict = snapshot.value as? NSDictionary
            let uid = dict?["posterUID"] as? String
            if uid == zeroPage.userStats.userUID {
                optsAlert.addAction(UIAlertAction(title: "Views: \((dict?["views"] as? Int) ?? 0)", style: .default, handler: nil))
                
                optsAlert.addAction(UIAlertAction(title: "Delete ADIT LOG", style: .destructive, handler: { (action) in
                    Database.database().reference().child("aditlog").child("\(tag)").removeValue()
                    self.loadlogs()
                }))
                optsAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(optsAlert, animated: true, completion: nil)
            }
                
            else {
                optsAlert.addAction(UIAlertAction(title: "Report ADIT LOG", style: .destructive, handler: { (action) in
                    
                    let optsOpt = UIAlertController(title: "Report", message: "Report ADIT LOG", preferredStyle: .alert)
                    optsOpt.addAction(UIAlertAction(title: "NSFW", style: .default, handler: { (action) in
                        Database.database().reference().child("reported").observeSingleEvent(of: .value, with: {(snap) -> Void in
                            let dict = snap.value as? NSDictionary
                            let reports = dict?["lastReport"] as? Int
                            let newN = reports! + 1
                            let reportInfo :[String:Any] = ["type":"aditlog","aditlog":"\(tag)","reason":"NSFW","reporter":zeroPage.userStats.userName]
                            Database.database().reference().child("reported").child("\(newN)").setValue(reportInfo)
                            Database.database().reference().child("reported").child("lastReport").setValue(newN)
                            let OKdone = UIAlertController(title: "Information", message: "The ADIT LOG has been reported, it will be reviewed shortly. You may be contacted for further information regarding the report.", preferredStyle: .alert)
                            OKdone.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(OKdone, animated: true, completion: nil)
                            
                        })
                        
                    }))
                    optsOpt.addAction(UIAlertAction(title: "Breaks Policy", style: .default, handler: { (action) in
                        Database.database().reference().child("reported").observeSingleEvent(of: .value, with: {(snap) -> Void in
                            let dict = snap.value as? NSDictionary
                            let reports = dict?["lastReport"] as? Int
                            let newN = reports! + 1
                            let reportInfo :[String:Any] = ["type":"aditlog","aditlog":"\(tag)","reason":"Policy","reporter":zeroPage.userStats.userName]
                            Database.database().reference().child("reported").child("\(newN)").setValue(reportInfo)
                            Database.database().reference().child("reported").child("lastReport").setValue(newN)
                            let OKdone = UIAlertController(title: "Information", message: "The ADIT LOG has been reported, it will be reviewed shortly. You may be contacted for further information regarding the report.", preferredStyle: .alert)
                            OKdone.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(OKdone, animated: true, completion: nil)
                            
                        })
                    }))
                    optsOpt.addAction(UIAlertAction(title: "Breaks Feed", style: .default, handler: { (action) in
                        Database.database().reference().child("reported").observeSingleEvent(of: .value, with: {(snap) -> Void in
                            let dict = snap.value as? NSDictionary
                            let reports = dict?["lastReport"] as? Int
                            let newN = reports! + 1
                            let reportInfo :[String:Any] = ["type":"aditlog","aditlog":"\(tag)","reason":"Breaks logs","reporter":zeroPage.userStats.userName]
                            Database.database().reference().child("reported").child("\(newN)").setValue(reportInfo)
                            Database.database().reference().child("reported").child("lastReport").setValue(newN)
                            
                            let OKdone = UIAlertController(title: "Information", message: "The ADIT LOG has been reported, it will be reviewed shortly. You may be contacted for further information regarding the report.", preferredStyle: .alert)
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

}
