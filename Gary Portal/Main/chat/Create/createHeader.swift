//
//  createHeader.swift
//  Gary Portal
//
//  Created by Tom Knighton on 07/05/2018.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import Alamofire
class createHeader: UIViewController {

    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var `continue`: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.cancel.layer.cornerRadius = 20
        self.cancel.layer.masksToBounds = true
        
        self.`continue`.layer.cornerRadius = 20
        self.`continue`.layer.masksToBounds = true
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        createdChat.channel = nil
    }
    public struct createdChat {
        static var channel : SBDGroupChannel!
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextSteps(_ sender: Any) {
        if (createChatController.chatSelectedUsers.selectedUsers.count == 0) {
            let alert = UIAlertController(title: "Error", message: "Please select some users to create a chat", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            if createChatController.chatSelectedUsers.selectedUsers.count > 2 {
                let name = UIAlertController(title: "Create Chat", message: "Please choose a name for this new chat:", preferredStyle: .alert)
                name.addTextField { (textField) in
                    textField.placeholder = "Choose a name"
                    
                }
                name.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
                    let text = name.textFields![0]
                    SBDGroupChannel.createChannel(withName: text.text!, isDistinct: true, userIds: createChatController.chatSelectedUsers.selectedUsers, coverUrl: "", data: nil, completionHandler: { (channel, error) in
                        createdChat.channel = channel!
                        self.sendCreateNotification(header: "Chat Created", sub: "", message: "You were invited to a chat by "+zeroPage.userStats.userName, channel: channel!)
                        self.dismiss(animated: true, completion: nil)
                    })
                }))
                name.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(name, animated: true, completion: nil)
            }
            else {
                SBDGroupChannel.createChannel(withUserIds: createChatController.chatSelectedUsers.selectedUsers, isDistinct: true, completionHandler: { (channel, error) in
                    createdChat.channel = channel!
                    self.sendCreateNotification(header: "Chat Created", sub: "", message: "You were invited to a chat by "+zeroPage.userStats.userName, channel: channel!)
                })
                
                self.dismiss(animated: true, completion: nil)
            }
           
            
        }
    }
    
    func checkToClose() {
        while createdChat.channel == nil {
            //print doing nothin
        }
        print("hi")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func sendCreateNotification(header: String, sub: String, message: String, channel: SBDGroupChannel) {
        for member in channel.members! {
            print("sending noti test user")
            if (member as! SBDUser).userId != zeroPage.userStats.sendbird {
                let toSend = (member as! SBDUser).userId
                let parameters: Parameters = [
                    "contents": [
                        "en":message
                    ],
                    "headings": [
                        "en":header
                    ],
                    "subtitle": [
                        "en":sub
                    ],
                    "filters":[
                        ["field":"tag", "key":"sendbird", "relation":"=", "value":toSend]
                    ],
                    "app_id": "7db3c7b8-adf2-4a26-8348-7e002bdd11dd",
                    "ios_badgeType": "Increase",
                    "ios_badgeCount": 1,
                    "content_available": true,
                    "mutable_content": true
                ]
                let headers: HTTPHeaders  = [
                    "Content-Type": "application/json; charset=utf-8",
                    "Authorization": "Basic OWM4ZTNiNzEtM2JjOS00NTVjLWJhMWItZjZlMGVhY2Y1YWI1"
                ]
                Alamofire.request("https://onesignal.com/api/v1/notifications", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            }
        }
    }
    

}
