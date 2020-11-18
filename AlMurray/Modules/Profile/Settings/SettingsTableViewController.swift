//
//  SettingsTableViewController.swift
//  AlMurray
//
//  Created by Tom Knighton on 16/11/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import UIKit

class SettingsTableViewController: UIViewController {

    @IBOutlet private weak var settingsTable: SettingsTableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.settingsTable?.delegate = self.settingsTable
        self.settingsTable?.dataSource = self.settingsTable
        self.settingsTable?.rowHeight = UITableView.automaticDimension
        self.settingsTable?.estimatedRowHeight = 270
        self.settingsTable?.reloadData()
    }
}
