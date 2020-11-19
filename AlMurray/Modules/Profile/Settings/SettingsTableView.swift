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

    weak var settingsDelegate: SettingsTableDelegate?
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = self.sections[indexPath.row]
        
        switch sectionType {
        case .accountCell:
            guard let cell = self.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as? SettingsAccountCell else { return UITableViewCell() }
            cell.setup(for: GaryPortal.shared.user)
            cell.delegate = self
            return cell
        case .securityCell:
            guard let cell = self.dequeueReusableCell(withIdentifier: "securityCell", for: indexPath) as? SettingsSecurityCell else { return UITableViewCell() }
            cell.delegate = self
            return cell
        case .appCell:
            guard let cell = self.dequeueReusableCell(withIdentifier: "appCell", for: indexPath) as? SettingsAppCell else { return UITableViewCell() }
            return cell
        }
    }
}

extension SettingsTableView: SettingsTableDelegate {
    
    func updateEmail(email: String) {
        settingsDelegate?.updateEmail(email: email)
    }
    
    func updateUsername(username: String) {
        settingsDelegate?.updateUsername(username: username)
    }
    
    func updateFullName(fullName: String) {
        settingsDelegate?.updateFullName(fullName: fullName)
    }
    
    func updateImage(newImage: UIImage) {
        settingsDelegate?.updateImage(newImage: newImage)
    }
    
    func presentView(viewcontroller: UIViewController) {
        settingsDelegate?.presentView(viewcontroller: viewcontroller)
    }
    
    func displayMessage(title: String, message: String) {
        settingsDelegate?.displayMessage(title: title, message: message)
    }
}
