//
//  chatLister.swift
//  Gary Portal
//
//  Created by Tom Knighton on 21/04/2018.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import SDWebImage
import ChameleonFramework
import MGSwipeTableCell

class chatLister: UITableViewController, SBDChannelDelegate, ConnectionManagerDelegate, SBDConnectionDelegate {
    
    
    
    @IBOutlet var table: UITableView!
    
    private var refreshController: UIRefreshControl?
    private var channels: [SBDGroupChannel] = []
    private var groupChannelListQuery: SBDGroupChannelListQuery?
    private var typingAnimationChannelList: [String] = []
    
    private var cachedChannels: Bool = true
    private var firstLoading: Bool = true
    
    
    override func viewDidAppear(_ animated: Bool) {
        if createHeader.createdChat.channel != nil {
            let vc = GroupChannelChattingViewController(nibName: "GroupChannelChattingViewController", bundle: Bundle.main)
            vc.groupChannel = createHeader.createdChat.channel
            
            self.present(vc, animated: false, completion: nil)
            createHeader.createdChat.channel = nil
        }
        refreshChannelList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addDelegate()
        self.table.delegate = self
        self.table.dataSource = self
        self.table.register(GroupChannelListTableViewCell.nib(), forCellReuseIdentifier: GroupChannelListTableViewCell.cellReuseIdentifier())
        
        self.refreshController = UIRefreshControl()
        self.refreshController?.addTarget(self, action: #selector(refreshChannelList), for: UIControlEvents.valueChanged)
        self.table.addSubview(self.refreshController!)
        
        self.setDefaultNavigationItems()
        
        ConnectionManager.add(connectionObserver: self as ConnectionManagerDelegate)
        if SBDMain.getConnectState() == .closed {
            SBDMain.connect(withUserId: zeroPage.userStats.sendbird, completionHandler: { (user, error) in
                guard error == nil else {
                    return;
                }
            })
        } else {
            self.firstLoading = false;
            self.showList();
        }
    }
    
    private func showList() {
        let dumpLoadQueue: DispatchQueue = DispatchQueue(label: "com.sendbird.dumploadqueue", attributes: .concurrent)
        dumpLoadQueue.async {
            self.channels = Utils.loadGroupChannels()
            if self.channels.count > 0 {
                DispatchQueue.main.async {
                    self.table.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(150), execute: {
                        self.refreshChannelList()
                    })
                }
            }
            else {
                self.cachedChannels = false
                self.refreshChannelList()
            }
            self.firstLoading = true;
        }
    }
    
    deinit {
        ConnectionManager.remove(connectionObserver: self as ConnectionManagerDelegate)
    }
    
    
    
    func addDelegate() {
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
    }
    
    private func setDefaultNavigationItems() {
        //TODO: Nav items
    }
    
    @objc private func refreshChannelList() {
        self.groupChannelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()!
        self.groupChannelListQuery?.limit = 20
        self.groupChannelListQuery?.order = SBDGroupChannelListOrder.latestLastMessage
        
        self.groupChannelListQuery?.loadNextPage(completionHandler: {(channels, error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    self.refreshController?.endRefreshing()
                }
                return
            }
            
            self.channels.removeAll()
            self.cachedChannels = false
            
            for channel in channels! {
                self.channels.append(channel)
            }
            
            DispatchQueue.main.async {
                if self.channels.count > 0 {
                    self.table.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                }
                self.refreshController?.endRefreshing()
                self.table.reloadData()
            }
            
        })
    }
    
    private func loadChannels() {
        if self.cachedChannels {
            return
        }
        
        if self.groupChannelListQuery != nil {
            if self.groupChannelListQuery?.hasNext == false {
                return
            }
            
            self.groupChannelListQuery?.loadNextPage(completionHandler: { (channels, error) in
                if error != nil {
                    if error?.code != 800170 {
                        self.refreshController?.endRefreshing()
                    }
                    return

                }
                
                for channel in channels! {
                    self.channels.append(channel)
                }
                
                DispatchQueue.main.async {
                    self.refreshController?.endRefreshing()
                    self.table.reloadData()
                }
            })
        }
    }
    
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
   
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channels.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.table.deselectRow(at: indexPath, animated: false)
        let vc = GroupChannelChattingViewController(nibName: "GroupChannelChattingViewController", bundle: Bundle.main)
        vc.groupChannel = self.channels[indexPath.row]
        
        self.present(vc, animated: false, completion: nil)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "chatItemCell") as! chatItemCell?
        
        //Swiping
        var isProtected = false
        if self.channels[indexPath.row].memberCount > 2  {
            for chat in zeroPage.userStats.protectedChats {
                if self.channels[indexPath.row].channelUrl == chat {
                    isProtected = true
                }
            }
            
            if isProtected == true {
                cell?.rightButtons = [MGSwipeButton(title: "Leave Chat", backgroundColor: UIColor.flatGray) {
                    (sender: MGSwipeTableCell!) -> Bool in
                    self.channels[indexPath.row].leave(completionHandler: { (error) in
                        print("left channel")
                        self.table.reloadData()
                    })
                    return true
                    }]
            }
            else {
                cell?.rightButtons = [MGSwipeButton(title: "Leave Chat", backgroundColor: UIColor.flatGray) {
                    (sender: MGSwipeTableCell!) -> Bool in
                    self.channels[indexPath.row].leave(completionHandler: { (error) in
                        print("left channel")
                        self.refreshChannelList()
                    })
                    return true
                    }, MGSwipeButton(title: "Change Name", backgroundColor: UIColor.flatBlue) {
                        (sender: MGSwipeTableCell!) -> Bool in
                        let nameAlert = UIAlertController(title: "Information", message: "Enter the new name of the channel:", preferredStyle: .alert)
                        nameAlert.addTextField(configurationHandler: { (textfield) in
                            textfield.placeholder = self.channels[indexPath.row].name
                            textfield.autocapitalizationType = .words
                            textfield.autocorrectionType = .yes
                        })
                        
                        nameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        nameAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
                            let text = nameAlert.textFields![0]
                            if text.text?.trim() != "" && text.text?.trim() != " " {
                                self.channels[indexPath.row].update(withName: text.text!, coverUrl: nil, data: nil, completionHandler: { (channel, error) in
                                    self.refreshChannelList()
                                })
                            }
                            
                        }))
                        self.present(nameAlert, animated: true, completion: nil)
                        return true
                    }]
            }
           
        }
        else {
            cell?.rightButtons = [MGSwipeButton(title: "Leave Chat", backgroundColor: UIColor.flatGray) {
                (sender: MGSwipeTableCell!) -> Bool in
                self.channels[indexPath.row].leave(completionHandler: { (error) in
                    print("left channel")
                    self.refreshChannelList()
                })
                return true
                }]
        }
        
        cell?.cover.layer.cornerRadius = 30
        cell?.cover.layer.masksToBounds = true
        cell?.unreadView.layer.cornerRadius = 15
        cell?.unreadView.layer.masksToBounds = true
        cell?.unreadView.backgroundColor = GradientColor(.leftToRight, frame: (cell?.unreadView.frame)!, colors: [UIColor(red:0.02, green:0.81, blue:1.00, alpha:1.0), UIColor(red:0.82, green:0.02, blue:1.00, alpha:1.0)])
        
     
    
        
        if isProtected == true {
            cell?.backgroundColor = UIColor.flatRed
            cell?.name.textColor = UIColor.flatWhite
            cell?.desc.textColor = UIColor.flatWhiteDark
            cell?.lastMessageDate.textColor = UIColor.flatWhite
        } else {
            cell?.backgroundColor = UIColor.white
            cell?.name.textColor = UIColor.flatBlack
            cell?.desc.textColor = UIColor.black
            cell?.lastMessageDate.textColor = UIColor.black
        }
      
        if self.channels[indexPath.row].memberCount <= 1 {
            cell?.name.text = "Lonely Chat :("
            cell?.cover.sd_setImage(with: URL(string: zeroPage.userStats.url), completed: nil)
        } else if self.channels[indexPath.row].memberCount == 2 {
            for member in self.channels[indexPath.row].members as! [SBDUser] {
                if member.userId != zeroPage.userStats.sendbird {
                    cell?.name.text = member.nickname
                    cell?.cover.sd_setImage(with: URL(string: member.profileUrl!), completed: nil)
                }
            }
        } else if self.channels[indexPath.row].memberCount > 2 {
            cell?.name.text = self.channels[indexPath.row].name
            cell?.cover.image = #imageLiteral(resourceName: "gCht")
        }
        
        
        //Last Message
        cell?.desc.text = self.lastMessageGetter(indexPath: indexPath.row)
        
        //Unread
        if self.channels[indexPath.row].unreadMessageCount > 0 {
            cell?.unreadCount.text = "\(self.channels[indexPath.row].unreadMessageCount)"
            cell?.unreadView.isHidden = false
        } else {
            cell?.unreadView.isHidden = true
        }
        
        //Time Date
        
        let date64 = self.channels[indexPath.row].lastMessage?.createdAt
        if date64 != nil {
            let dateTimeStamp = Date(timeIntervalSince1970:Double(date64!)/1000)  //UTC time  //YOUR currentTimeInMiliseconds METHOD
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = NSTimeZone.local
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            let lastMessageDateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: dateTimeStamp)
            let currComponents = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
            if (lastMessageDateComponents.year != currComponents.year || lastMessageDateComponents.month != currComponents.month || lastMessageDateComponents.day != currComponents.day) {
                dateFormatter.dateStyle = DateFormatter.Style.short
                dateFormatter.timeStyle = DateFormatter.Style.none
                let strDateSelect = dateFormatter.string(from: dateTimeStamp)
                cell?.lastMessageDate.text = strDateSelect
            } else {
                dateFormatter.dateStyle = DateFormatter.Style.none
                dateFormatter.timeStyle = DateFormatter.Style.short
                let strDateSelect = dateFormatter.string(from: dateTimeStamp)
                cell?.lastMessageDate.text = strDateSelect
            }
        }
        
        
        
        //Typing
        if self.channels[indexPath.row].isTyping() {
            if self.typingAnimationChannelList.index(of: self.channels[indexPath.row].channelUrl) == nil {
                self.typingAnimationChannelList.append(self.channels[indexPath.row].channelUrl)
                cell?.desc.text = "Users are typing..."
            }
        }
        else {
            if self.typingAnimationChannelList.index(of: self.channels[indexPath.row].channelUrl) != nil {
                self.typingAnimationChannelList.remove(at: self.typingAnimationChannelList.index(of: self.channels[indexPath.row].channelUrl)!)
                cell?.desc.text = self.lastMessageGetter(indexPath: indexPath.row)
            }
        }
        
        
        
        //Load Channels
        if self.channels.count > 0 && indexPath.row + 1 == self.channels.count {
            self.loadChannels()
        }
        
        return cell!
        
        
    }
    
    func lastMessageGetter(indexPath: Int) -> String {
        var lastMessage = ""
        if self.channels[indexPath].lastMessage is SBDUserMessage {
            let message = self.channels[indexPath].lastMessage as! SBDUserMessage
            lastMessage = message.message!
        } else if self.channels[indexPath].lastMessage is SBDFileMessage {
            let message = self.channels[indexPath].lastMessage as! SBDFileMessage
            if message.type.hasPrefix("image"){
                lastMessage = "(Image)"
            } else if message.type.hasPrefix("video") {
                lastMessage = "(Video)"
            } else if message.type.hasPrefix("audio") {
                lastMessage = "(Audio)"
            }
        } else if self.channels[indexPath].lastMessage is SBDAdminMessage {
            let message = self.channels[indexPath].lastMessage as! SBDAdminMessage
            lastMessage = "ADMIN: "+message.message!
        }
        
        return lastMessage
        
    }
    
    //Sendbird
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        print("received")
        if sender is SBDGroupChannel {
            let channel = sender as! SBDGroupChannel
            if self.channels.index(of: channel) != nil {
                self.channels.remove(at: self.channels.index(of: channel)!)
            }
            self.channels.insert(channel, at: 0)
            
            
        }
        self.table.reloadData()
        
    }
    
    func channelWasChanged(_ sender: SBDBaseChannel) {
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
   
    
    
    func didConnect(isReconnection: Bool) {
        print("connected")
    }
    
    func didDisconnect() {
        print("disconnected")
    }



}
