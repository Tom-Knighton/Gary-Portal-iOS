//
//  ggCommentTable.swift
//  Gary Portal
//
//  Created by Tom Knighton on 19/05/2018.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SDWebImage
class ggCommentTable: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var commentList = [ggComment]()
    var currentNum : Int?
    
    @IBOutlet weak var table: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentList.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 98
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "ggComm") as! ggCommentCell
        cell.commentText.text = self.commentList[indexPath.row].comment
        cell.commentData.text = self.commentList[indexPath.row].commentDate
        cell.commentImage.layer.cornerRadius = 25
        cell.commentImage.layer.masksToBounds = true
        
        cell.commentImage.sd_setImage(with: URL(string: self.commentList[indexPath.row].commenterURL), completed: nil)
        return cell
    }
    
    
    private var refresher = UIRefreshControl()
    var timer : Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.delegate = self
        table.dataSource = self
        postButton.layer.cornerRadius = 15
        closeButton.layer.cornerRadius = 15
        postButton.layer.masksToBounds = true
        closeButton.layer.masksToBounds = true
        loadComments()
        
        if #available(iOS 10.0, *) {
            table.refreshControl = refresher
        } else {
            table.addSubview(refresher)
        }
        refresher.addTarget(self, action: #selector(refreshPage(_:)), for: .valueChanged)
    }
    @objc private func refreshPage(_ sender: Any) {
        loadComments()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        /*timer = Timer.every(3.seconds, {(timer: Timer) in
            self.loadComments()
        })
        timer.start()*/
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //timer.invalidate()
    }

    func loadComments() {
        self.commentList.removeAll()
        Database.database().reference().child("feed").child("\(self.currentNum!)").child("commentList").observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                let child = child as! DataSnapshot
                let dict = child.value as? NSDictionary
                let commToAdd = ggComment()
                commToAdd.comment = dict?["comment"] as! String
                commToAdd.commenterURL = dict?["commenterurl"] as! String
                commToAdd.commentDate = dict?["date"] as! String
                self.commentList.append(commToAdd)
            }
            self.table.reloadData()
            self.refresher.endRefreshing()
        })
        
    }

    

    @IBAction func postComment(_ sender: Any) {
        let alert = UIAlertController(title: "Post Comment", message: "Enter your comment below", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(textfield) in
            textfield.autocapitalizationType = .sentences
            textfield.autocorrectionType = .yes
        })
        alert.addAction(UIAlertAction(title: "Post", style: .default, handler: { (action) in
            let text = alert.textFields![0]
            if (text.text!.trim().count <= 0) {
                let alert2 = UIAlertController(title: "Error", message: "Please enter a comment", preferredStyle: .alert)
                alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert2, animated: true, completion: nil)
            }
            else {
                Database.database().reference().child("feed").child("\(self.currentNum!)").observeSingleEvent(of: .value, with: { (snap) in
                    let dict = snap.value as? NSDictionary
                    let old = dict?["Comments"] as! Int
                    let new = old + 1
                    let date = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd/MM/yy"
                    let dateResult = formatter.string(from: date)
                    Database.database().reference().child("feed").child("\(self.currentNum!)").child("commentList").child("\(new)").setValue(["commenterurl":zeroPage.userStats.url, "comment":text.text!, "date":dateResult])
                    Database.database().reference().child("feed").child("\(self.currentNum!)").updateChildValues(["Comments":new])
                    self.loadComments()
                    self.loadComments()
                    
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    

}
