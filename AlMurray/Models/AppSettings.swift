//
//  AppSettings.swift
//  AlMurray
//
//  Created by Tom Knighton on 21/11/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import Foundation

struct AppSettings {
    
    var autoPlayVideos: Bool = UserDefaults.standard.bool(forKey: GaryPortalConstants.UserDefaults.autoPlayVideos)
    var notificationsEnabled: Bool = UserDefaults.standard.bool(forKey: GaryPortalConstants.UserDefaults.notifications)
    
    /// Updates app settings stored in UserDefaults
    public mutating func saveSettings(autoPlayVideos: Bool = UserDefaults.standard.bool(forKey: GaryPortalConstants.UserDefaults.autoPlayVideos), notificationsEnabled: Bool = UserDefaults.standard.bool(forKey: GaryPortalConstants.UserDefaults.notifications)) {
        self.autoPlayVideos = autoPlayVideos
        self.notificationsEnabled = notificationsEnabled
        
        UserDefaults.standard.set(autoPlayVideos, forKey: GaryPortalConstants.UserDefaults.autoPlayVideos)
        UserDefaults.standard.set(notificationsEnabled, forKey: GaryPortalConstants.UserDefaults.notifications)
    }
}
