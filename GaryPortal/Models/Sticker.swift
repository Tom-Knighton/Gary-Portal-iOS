//
//  Sticker.swift
//  GaryPortal
//
//  Created by Tom Knighton on 24/03/2021.
//

import Foundation

struct Sticker: Codable, Identifiable, Hashable {
    let stickerId: Int?
    let stickerName: String?
    let stickerURL: String?
    let stickerStaffOnly: Bool?
    let stickerAdminOnly: Bool?
    let stickerIsDeleted: Bool?
    
    var id: Int { stickerId ?? 0 }
}
