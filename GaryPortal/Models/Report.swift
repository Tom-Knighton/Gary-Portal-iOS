//
//  Report.swift
//  GaryPortal
//
//  Created by Tom Knighton on 10/02/2021.
//

import Foundation

struct UserReport: Codable {
    
    let userReportId: Int?
    let userUUID: String?
    let reportReason: String?
    let reportIssuedAt: Date?
    let reportByUUID: String?
    let isDeleted: Bool?
    
    let reportedUser: User?
    let reporter: User?
}

struct FeedReport: Codable {
    
    let feedReportId: Int?
    let feedPostId: Int?
    let reportReason: String?
    let reportIssuedAt: Date?
    let reportByUUID: String?
    let isDeleted: Bool?
    
    let reportedPost: FeedPost?
    let reporter: User?
}

struct ChatMessageReport: Codable {
    
    let chatMessageReportId: Int?
    let chatMessageUUID: String?
    let reportReason: String?
    let reportIssuedAt: Date?
    let reportByUUID: String?
    let isDeleted: Bool?
    
    let reportedMessage: ChatMessage?
    let reporter: User?
}
