//
//  createChatController.swift
//  Gary Portal
//
//  Created by Tom Knighton on 06/05/2018.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import Firebase
import FirebaseDatabase
import SDWebImage

class createChatController: UITableViewController {
    @IBOutlet var table: UITableView!
    
    var userList = [createChatUser]()
    //var selectedUsers = [String]()
    
    var toUpdate : Bool = true
    var scroll : CGPoint = CGPoint(x: 0, y: 0)

    public struct chatSelectedUsers {
        static var selectedUsers = [String]()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadUsers()
    }
    

    
    func loadUsers() {
        chatSelectedUsers.selectedUsers.removeAll()
        self.userList.removeAll()
        
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: {(snapshot) in
            
            for child in snapshot.children {
                let child = child as! DataSnapshot
                if let childVal = child.value as? [String:AnyObject] {
                    let userToShow = createChatUser()

                    if (childVal["uid"] as! String == zeroPage.userStats.userUID || childVal["hidden"] as! Bool == true || (childVal["team"] as! String != zeroPage.userStats.team && zeroPage.userStats.otherTeams != true)) {
                        print ("not allowed")
                    }
                    else {
                        userToShow.sendbird = childVal["sendbird"] as! String
                        userToShow.userName = childVal["fullName"] as! String
                        userToShow.userURL = childVal["urlToImage"] as! String
                        self.userList.append(userToShow)
                    
                    }
                    
                    
                    
                }
            }
            self.table.reloadData()
            
            
        })
        table.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.userList.count)
        return self.userList.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if ((table.cellForRow(at: indexPath) as! createChatUserCell).userRadio.image == #imageLiteral(resourceName: "btn_check_on")) {
            (self.table.cellForRow(at: indexPath) as! createChatUserCell).userRadio.image = #imageLiteral(resourceName: "btn_check_off")
            chatSelectedUsers.selectedUsers.remove(at: chatSelectedUsers.selectedUsers.index(of: self.userList[indexPath.row].sendbird)!)
        }
        else {
            (self.table.cellForRow(at: indexPath) as! createChatUserCell).userRadio.image = #imageLiteral(resourceName: "btn_check_on")
            chatSelectedUsers.selectedUsers.append(self.userList[indexPath.row].sendbird)
        }
        table.deselectRow(at: indexPath, animated: true)

        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "createUserCell") as! createChatUserCell
        cell.userName.text = self.userList[indexPath.row].userName
        cell.userPic.layer.cornerRadius = cell.userPic.frame.width / 2
        cell.userPic.layer.masksToBounds = true
        cell.userPic.sd_setImage(with: URL(string: self.userList[indexPath.row].userURL), completed: nil)
        return cell
    }

   
}

