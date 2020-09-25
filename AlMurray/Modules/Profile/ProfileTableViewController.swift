//
//  ProfileTableViewController.swift
//  AlMurray
//
//  Created by Tom Knighton on 19/08/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    var dataSource = ProfileTableDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = dataSource
        self.tableView.delegate = dataSource
        
        self.refreshControl?.addTarget(self, action: #selector(self.refreshStats), for: .valueChanged)
    }
    
    @objc
    func refreshStats() {
        let userService = UserService()
        print("refresh")
        userService.getUserById(userId: GaryPortal.shared.user?.userId ?? "") { (user) in
            if let user = user {
                DispatchQueue.main.async {
                    GaryPortal.shared.user = user
                    print(user.userPoints?.amigoPoints ?? 0)
                    print(GaryPortal.shared.user?.userPoints?.amigoPoints ?? 0)
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            } else {
                print("no uiser")
            }
        }
    }

}
