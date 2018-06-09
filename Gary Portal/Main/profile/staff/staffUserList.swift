

//
//  staffUserList.swift
//  Gary Portal
//
//  Created by Tom Knighton on 02/04/2018.
//  Copyright © 2018 Tom Knighton. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class staffUserList: UITableViewController {
    
    var ref : DatabaseReference!
    var userList = [user]()
    var toUpdate : Bool = true
    
    var scroll : CGPoint = CGPoint(x: 0, y: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        loadUsers()
    }
    
    func loadUsers() {
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                let child = child as! DataSnapshot
                if let childVal = child.value as? [String:AnyObject] {
                    let userToShow = user()
                    
                    if childVal["team"] as! String == zeroPage.userStats.team {
                        if zeroPage.userStats.admin == true {
                            print("is admin yay!")
                            print(childVal["fullName"] as! String)
                            userToShow.picURL = childVal["urlToImage"] as! String
                            userToShow.name = childVal["fullName"] as! String
                            userToShow.team = childVal["team"] as! String
                            userToShow.uid = childVal["uid"] as! String
                            self.userList.append(userToShow)
                            self.table.reloadData()


                        } else if zeroPage.userStats.staff == true {
                            if childVal["staff"] as! Bool == true || childVal["admin"] as! Bool == true || childVal["uid"] as! String == zeroPage.userStats.userUID {
                                print("can't edit this user")
                            } else {
                                print(childVal["fullName"] as! String)
                                userToShow.picURL = childVal["urlToImage"] as! String
                                userToShow.name = childVal["fullName"] as! String
                                userToShow.team = childVal["team"] as! String
                                userToShow.uid = childVal["uid"] as! String
                                self.userList.append(userToShow)
                                self.table.reloadData()

                            }
                        }
                       
                    }
                    
                }
            }
            
        })
    }
    @IBOutlet var table: UITableView!
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "staffUserCellP", for: indexPath) as! staffUserCell
        cell.userName.text = userList[indexPath.row].name
        cell.userImage.sd_setImage(with: URL(string: userList[indexPath.row].picURL), completed: nil)
        
        cell.editB.tag = indexPath.row
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

}
