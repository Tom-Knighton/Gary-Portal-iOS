//
//  StaffRoomAnnouncement.swift
//  GaryPortal
//
//  Created by Tom Knighton on 16/01/2021.
//

import Foundation

struct StaffRoomAnnouncement: Codable {
    
    let announcementId: Int?
    let announcement: String?
    let userUUID: String?
    let announcementDate: Date?
    let isDeleted: Bool?
    let userDTO: UserDTO?
}
