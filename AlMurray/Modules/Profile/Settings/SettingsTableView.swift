//
//  SettingsTableView.swift
//  AlMurray
//
//  Created by Tom Knighton on 16/11/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import UIKit

enum SettingsTableViewSections {
    case accountCell
    case securityCell
    case appCell
}

class SettingsTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    let sections: [SettingsTableViewSections] = [.accountCell, .securityCell, .appCell]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = self.sections[indexPath.row]
        
        switch sectionType {
        case .accountCell:
            guard let cell = self.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as? SettingsAccountCell else { return UITableViewCell() }
            cell.setup(for: GaryPortal.shared.user)
            return cell
        case .securityCell:
            guard let cell = self.dequeueReusableCell(withIdentifier: "securityCell", for: indexPath) as? SettingsSecurityCell else { return UITableViewCell() }
            return cell
        case .appCell:
            guard let cell = self.dequeueReusableCell(withIdentifier: "appCell", for: indexPath) as? SettingsAppCell else { return UITableViewCell() }
            return cell
        }
    }
}
