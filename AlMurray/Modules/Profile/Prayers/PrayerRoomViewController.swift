//
//  PrayerRoomViewController.swift
//  AlMurray
//
//  Created by Tom Knighton on 17/11/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import UIKit

class PrayerRoomViewController: UIViewController {
    
    @IBOutlet private weak var simplePrayerButton: UIButton?
    @IBOutlet private weak var meaningfulPrayerButton: UIButton?
    @IBOutlet private weak var adminClearButton: UIButton?
    
    @IBOutlet private weak var simplePrayersLabel: UILabel?
    @IBOutlet private weak var meaningfulPrayersLabel: UILabel?
    
    private var simplePrayerCount: Int = 0
    private var meaningfulPrayerCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.simplePrayerButton?.roundCorners(radius: 10)
        self.simplePrayerButton?.addGradient(colours: [UIColor(hexString: "#FF5F6D"), UIColor(hexString: "#FFC371")], locations: nil)
        self.meaningfulPrayerButton?.roundCorners(radius: 10)
        self.meaningfulPrayerButton?.addGradient(colours: [UIColor(hexString: "#8A2387"), UIColor(hexString: "#E94057"), UIColor(hexString: "#F27121")], locations: nil)
        
        self.adminClearButton?.roundCorners(radius: 10)
        self.adminClearButton?.addGradient(colours: [UIColor(hexString: "#ED213A"), UIColor(hexString: "#93291E")], locations: nil)
        
        UserService().getPrayers(userId: GaryPortal.shared.user?.userId ?? "") { (points) in
            DispatchQueue.main.async {
                GaryPortal.shared.user?.updatePrayers(simple: points?.prayers ?? 0, meaningful: points?.meaningfulPrayers ?? 0)
                self.simplePrayerCount = GaryPortal.shared.user?.userPoints?.prayers ?? 0
                self.meaningfulPrayerCount = GaryPortal.shared.user?.userPoints?.meaningfulPrayers ?? 0
                self.updateCountLabels()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        UserService().updatePrayers(userId: GaryPortal.shared.user?.userId ?? "", simplePrayers: self.simplePrayerCount, meaningfulPrayers: self.meaningfulPrayerCount)
    }
    
    @IBAction func performPrayer(_ sender: UIButton?) {
        
        if sender == self.simplePrayerButton {
            self.simplePrayerCount += 1
        } else if sender == meaningfulPrayerButton {
            self.meaningfulPrayerCount += 1
        }
        
        updateCountLabels()
    }
    
    func updateCountLabels() {
        
        self.simplePrayersLabel?.text = GaryPortalConstants.Prayers.SimpleCount + String(describing: self.simplePrayerCount)
        self.meaningfulPrayersLabel?.text = GaryPortalConstants.Prayers.MeaningfulCount + String(describing: self.meaningfulPrayerCount)
    }
    
    @IBAction func clearPrayers(_ sender: UIButton?) {
        
        UserService().clearAllPrayers()
        self.simplePrayerCount = 0
        self.meaningfulPrayerCount = 0
        self.updateCountLabels()
    }

}
