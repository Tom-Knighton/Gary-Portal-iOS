//
//  chatListView.swift
//  Gary Portal
//
//  Created by Tom Knighton on 05/04/2018.
//  Copyright © 2018 Tom Knighton. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import ChameleonFramework
import SendBirdSDK
import SwiftyTimer
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
class chatListView: UITableViewController, SBDChannelDelegate{
    
    
    public struct currentChat {
        static var channel : SBDGroupChannel? = nil
    }

    @IBOutlet var table: UITableView!
    var chatList : [chatItem] = []
    var queryList : [String] = []
    
    var lastReadList : [Int] = []
    
    var chatQuery : SBDGroupChannelListQuery?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadChats()
        self.table.reloadData()
        let timer = Timer.every(3.seconds, {(timer: Timer) in
            self.loadChats()
        })
        timer.start()
       
    }
   

    

    @objc func loadChats() {
        self.queryList.removeAll()
        self.lastReadList.removeAll()
        Database.database().reference().child("users").child(zeroPage.userStats.userUID).child("chats").observe(.value, with: {(snapshot) in
            
            if !snapshot.exists() { return }
            for item in snapshot.children {
                let item = item as! DataSnapshot
                self.queryList.append(item.key)
                self.lastReadList.append(item.value as? Int ?? 1)
            }
            
            self.putChannels()
            
        })
        
       
        
        
    }
    func putChannels() {
        
        self.chatList.removeAll()
        for chat in self.queryList {
            Database.database().reference().child("chats").child(chat).observeSingleEvent(of: .value, with: { (snapshot) in
                
                let dict = snapshot.value as? NSDictionary
                let mCount = dict?["memberCount"] as? UInt
                let cName = dict?["name"] as? String
                let lastM = dict?["lastM"] as? String
                let lastTime = dict?["lastT"] as? String
                let totalM = dict?["totalM"] as? UInt
                
                var otherPic : String!
                var otherID: String!
                
                Database.database().reference().child("chats").child(chat).child("members").observeSingleEvent(of: .value, with: {(snap2) in
                    for child in snap2.children {
                        let child = child as! DataSnapshot
                        if child.key != zeroPage.userStats.userUID {
                            otherPic = child.value as! String
                            otherID = child.key
                        }
                    }
                    
                    let channelToShow = chatItem()
                    
                    channelToShow.otherMemberName = otherID
                    channelToShow.otherMemberURL = otherPic
                    channelToShow.name = cName
                    channelToShow.memberCount = mCount
                    channelToShow.channelRef = chat
                    channelToShow.lastMessage = lastM
                    channelToShow.lastTime = lastTime
                    channelToShow.totalMessages = totalM
                    
                    self.chatList.append(channelToShow)
                    
                    self.table.reloadData()
                })
                
                
                
            })
        }
       
        
    }
//    @objc func loadChannels() {
//        self.chatQuery = SBDGroupChannel.createMyGroupChannelListQuery()
//        self.chatQuery?.limit = 50
//        self.chatQuery?.order = .latestLastMessage
//
//        self.chatQuery?.loadNextPage(completionHandler: { (channels, error) in
//            if error != nil {
//                return
//            }
//
//            self.chatList.removeAll()
//
//            for channel in channels! {
//                let channelToSet = chatItem()
//                channelToSet.name = channel.name
//                channelToSet.unread = channel.unreadMessageCount
//                channelToSet.memberCount = channel.memberCount
//                channelToSet.channel = channel
//                self.chatList.append(channelToSet)
//            }
//
//            DispatchQueue.main.async {
//                if self.chatList.count == 0 {
//                    self.table.separatorStyle = .none
//                } else {
//                    self.table.separatorStyle = .singleLine
//                }
//
//            }
//            self.tableView.reloadData()
//        })
//        self.tableView.reloadData()
//
//
//    }
    
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        print("NEW MESSAGE RECEIVED")
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "chatItemCell") as! chatItemCell
        
        cell.cover.layer.cornerRadius = 30
        cell.cover.layer.masksToBounds = true
        
        cell.unreadView.layer.cornerRadius = 15
        cell.unreadView.layer.masksToBounds = true
        
        if self.chatList[indexPath.row].memberCount == 1 {
            cell.name.text = "Lonely Chat :("
            cell.cover.sd_setImage(with: URL(string: zeroPage.userStats.url), completed: nil)
        } else if self.chatList[indexPath.row].memberCount == 2 {
            if self.chatList[indexPath.row].otherMemberName != nil {
                Database.database().reference().child("users").child(self.chatList[indexPath.row].otherMemberName).observeSingleEvent(of: .value, with: { (snapshot) in
                    let dict = snapshot.value as! NSDictionary
                    let name = dict["fullName"] as? String ?? "Private Chat"
                    let url = dict["urlToImage"] as! String
                    cell.cover.sd_setImage(with: URL(string: url), completed: nil)
                    cell.name.text = name
                })
            } else {
                cell.name.text = "Private Chat"
            }
        } else {
            cell.name.text = self.chatList[indexPath.row].name
            cell.cover.image = #imageLiteral(resourceName: "gCht")
        }
        
      
        cell.desc.text = self.chatList[indexPath.row].lastMessage
        
        
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = table.dequeueReusableCell(withIdentifier: "chatItemCell") as! chatItemCell
//        cell.name.text = self.chatList[indexPath.row].name
//
//        if self.chatList[indexPath.row].memberCount == 1 {
//            cell.name.text = "Lonely Chat :("
//        }
//
//        else if self.chatList[indexPath.row].memberCount == 2 {
//            for member in self.chatList[indexPath.row].channel.members! as NSArray as! [SBDUser] {
//                if member.nickname != SBDMain.getCurrentUser()?.nickname {
//                    cell.cover.sd_setImage(with: URL(string: member.profileUrl!), completed: nil)
//                    cell.name.text = member.nickname
//                }
//            }
//        } else {
//            cell.cover.image = #imageLiteral(resourceName: "gCht")
//        }
//
//        cell.cover.layer.cornerRadius = 30
//        cell.cover.layer.masksToBounds = true
//
//        cell.unreadView.layer.cornerRadius = 15
//        cell.unreadView.layer.masksToBounds = true
//        cell.unreadView.backgroundColor = GradientColor(.leftToRight, frame: cell.unreadView.frame, colors: [UIColor(red:0.02, green:0.81, blue:1.00, alpha:1.0), UIColor(red:0.82, green:0.02, blue:1.00, alpha:1.0)])
//
//        if self.chatList[indexPath.row].channel.lastMessage is SBDUserMessage {
//            let last = self.chatList[indexPath.row].channel.lastMessage as! SBDUserMessage
//            cell.desc.text = last.message
//        }
//        let date64 = self.chatList[indexPath.row].channel.lastMessage?.createdAt
//        let dateTimeStamp = Date(timeIntervalSince1970:Double(date64!)/1000)  //UTC time  //YOUR currentTimeInMiliseconds METHOD
//        let dateFormatter = DateFormatter()
//        dateFormatter.timeZone = NSTimeZone.local
//        dateFormatter.dateFormat = "dd/MM/yyyy"
//
//        let lastMessageDateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: dateTimeStamp)
//        let currComponents = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
//        if (lastMessageDateComponents.year != currComponents.year || lastMessageDateComponents.month != currComponents.month || lastMessageDateComponents.day != currComponents.day) {
//            dateFormatter.dateStyle = DateFormatter.Style.short
//            dateFormatter.timeStyle = DateFormatter.Style.none
//            let strDateSelect = dateFormatter.string(from: dateTimeStamp)
//            cell.lastMessageDate.text = strDateSelect
//        } else {
//            dateFormatter.dateStyle = DateFormatter.Style.none
//            dateFormatter.timeStyle = DateFormatter.Style.short
//            let strDateSelect = dateFormatter.string(from: dateTimeStamp)
//            cell.lastMessageDate.text = strDateSelect
//        }
//
//
//        if self.chatList[indexPath.row].channel.unreadMessageCount > 0 {
//            cell.unreadView.isHidden = false
//            if self.chatList[indexPath.row].channel.unreadMessageCount < 10 {
//                cell.unreadCount.text = "\(self.chatList[indexPath.row].channel.unreadMessageCount)"
//            } else {
//                cell.unreadCount.text = "9+"
//            }
//        } else {
//            cell.unreadView.isHidden = true
//        }
//        return cell
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.table.deselectRow(at: indexPath, animated: false)
        currentChat.channel = self.chatList[indexPath.row].channel
        self.performSegue(withIdentifier: "listToChat", sender: self)
    }
 
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
  
}
