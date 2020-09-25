//
//  ProfileTableDataSource.swift
//  AlMurray
//
//  Created by Tom Knighton on 19/08/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import Foundation
import UIKit

enum ProfileTableViewSections {
    case headerCell
    case pointsCell
    case statsCell
    case miscCell
}

class ProfileTableDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    let sections: [ProfileTableViewSections] = [.headerCell, .pointsCell, .statsCell, .miscCell]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = self.sections[indexPath.row]
        
        switch sectionType {
        case .headerCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderCell", for: indexPath) as? ProfileHeaderCell else { return UITableViewCell() }
            cell.updateStats()
            return cell
            
        case .pointsCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilePointsCell", for: indexPath) as? ProfilePointsCell else { return UITableViewCell() }
            cell.updateStats()
            return cell
            
        case .statsCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileStatsCell", for: indexPath) as? ProfileStatsCell else { return UITableViewCell() }
            cell.updateStats()
            return cell
            
        case .miscCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileMiscCell", for: indexPath) as? ProfileMiscCell else { return UITableViewCell() }
            cell.updateStats()
            return cell
        }
        
    }
}
