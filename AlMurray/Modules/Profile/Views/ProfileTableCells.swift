//
//  ProfileTableCells.swift
//  AlMurray
//
//  Created by Tom Knighton on 20/08/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import UIKit
import Nuke

class ProfileHeaderCell: UITableViewCell {
    
    @IBOutlet private weak var headerContainer: UIView?
    @IBOutlet private weak var profileImageView: UIImageView?
    @IBOutlet private weak var userFullNameLabel: UILabel?
    @IBOutlet private weak var userSpanishNameLabel: UILabel?
    @IBOutlet private weak var userActionButton: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.headerContainer?.roundCorners(radius: 20)
        self.profileImageView?.roundCorners(radius: (self.profileImageView?.frame.width ?? CGFloat(integerLiteral: 180)) / 2)
        self.profileImageView?.layer.borderColor = UIColor.white.cgColor
        self.profileImageView?.layer.borderWidth = 1
        self.userActionButton?.roundCorners(radius: 20)
        
        self.updateStats()
        
    }
    
    func updateStats() {
        
        guard let user = GaryPortal.shared.user else { return }
        
        self.userFullNameLabel?.text = user.userFullName
        self.userSpanishNameLabel?.text = user.userSpanishName
        
        if let url = URL(string: user.userProfileImageUrl ?? "") {
            Nuke.loadImage(with: url, into: self.profileImageView ?? UIImageView())
        }
        self.profileImageView?.addGradientBorder(colours: [UIColor(hexString: "#3494E6"), UIColor(hexString: "#EC6EAD")])
    }
    
    @IBAction func userActionButtonPressed(_ sender: UIButton) {
        if let url = URL(string: GaryPortalConstants.URLs.WebsiteURL) {
            UIApplication.shared.open(url)
        }
    }
}

class ProfilePointsCell: UITableViewCell {
    
    @IBOutlet private weak var pointsContainer: UIView?
    @IBOutlet private weak var amigoPointsLabel: UILabel?
    @IBOutlet private weak var positivityPointsLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.pointsContainer?.roundCorners(radius: 20)
        self.updateStats()
    }
    
    func updateStats() {
        guard let user = GaryPortal.shared.user else { return }
        
        self.amigoPointsLabel?.text = "AMIGO POINTS: \(String(describing: user.userPoints?.amigoPoints ?? 0))"
        self.positivityPointsLabel?.text = "POSITIVITY POINTS: \(String(describing: user.userPoints?.positivityPoints ?? 0))"
    }
}

class ProfileStatsCell: UITableViewCell {
    
    @IBOutlet private weak var statsContainer: UIView?
    @IBOutlet private weak var amigoRankLabel: UILabel!
    @IBOutlet private weak var positivityRankLabel: UILabel!
    @IBOutlet private weak var teamLabel: UILabel!
    @IBOutlet private weak var teamStandingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.statsContainer?.roundCorners(radius: 20)
        self.updateStats()
    }
    
    func updateStats() {
        guard let user = GaryPortal.shared.user else { return }
        
        self.amigoRankLabel.text = user.userRanks?.amigoRank ?? ""
        self.positivityRankLabel.text = user.userRanks?.positivityRank ?? ""
        self.teamLabel.text = user.userTeam?.teamName ?? ""
        self.teamStandingLabel.text = user.userStanding ?? ""
    }
}

class ProfileMiscCell: UITableViewCell {

    @IBOutlet private weak var miscContainer: UIView?
    @IBOutlet private weak var prayerRoomButton: UIButton?
    @IBOutlet private weak var rulesButton: UIButton?
    @IBOutlet private weak var feedbackButton: UIButton?
    @IBOutlet private weak var computerDatingButton: UIButton?
    @IBOutlet private weak var settingsButton: UIButton?
    
    func design() {        
        self.miscContainer?.roundCorners(radius: 20)
        
        self.prayerRoomButton?.roundCorners(radius: 10)
        self.rulesButton?.roundCorners(radius: 10)
        self.feedbackButton?.roundCorners(radius: 10)
        self.computerDatingButton?.roundCorners(radius: 10)
        self.settingsButton?.roundCorners(radius: 10)
        
        self.prayerRoomButton?.addGradient(colours: [UIColor(hexString: "#8E2DE2"), UIColor(hexString: "#4A00E0")], locations: nil)
        self.rulesButton?.addGradient(colours: [UIColor(hexString: "#8A2387"), UIColor(hexString: "#E94057")], locations: nil)
        self.feedbackButton?.addGradient(colours: [UIColor(hexString: "#4568DC"), UIColor(hexString: "#B06AB3")], locations: nil)
        self.computerDatingButton?.addGradient(colours: [UIColor(hexString: "#4568DC"), UIColor(hexString: "#B06AB3")], locations: nil)
        self.settingsButton?.addGradient(colours: [UIColor(hexString: "#485563"), UIColor(hexString: "#434343")], locations: nil)
    }
    
    func updateStats() {
        self.design()
    }
    
    @IBAction func rulesButtonTapped(_ sender: UIButton) {
        
        if sender == self.rulesButton {
            if let url = URL(string: GaryPortalConstants.URLs.RulesURL) {
                UIApplication.shared.open(url)
            }
        } else if sender == self.computerDatingButton {
            if let url = URL(string: GaryPortalConstants.URLs.ComputerDatingURL) {
                UIApplication.shared.open(url)
            }
        } else if sender == self.feedbackButton {
            if let url = URL(string: GaryPortalConstants.URLs.FeedbackURL) {
                UIApplication.shared.open(url)
            }
        }
    }
}
