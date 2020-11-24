//
//  User.swift
//  AlMurray
//
//  Created by Tom Knighton on 19/08/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import Foundation

struct User: Codable {
    
    var userId: String?
    let userEmail: String?
    let userFullName: String?
    let userSpanishName: String?
    let userName: String?
    let userProfileImageUrl: String?
    let userPassword: String?
    let userQuote: String?
    let userBio: String?
    let userIsStaff: Bool?
    let userIsAdmin: Bool?
    let userStanding: String?
    let isQueued: Bool?
    
    let userTeam: UserTeam?
    let userRanks: UserRanks?
    var userPoints: UserPoints?
    let userBans: UserBans?
        
    mutating func updatePrayers(simple: Int, meaningful: Int) {
        userPoints?.prayers = simple
        userPoints?.meaningfulPrayers = meaningful
    }
    
}

struct UserDTO: Codable, Hashable {
    
    let userId: String?
    let userFullName: String?
    let userProfileImageUrl: String?
    let userIsStaff: Bool?
    let userIsAdmin: Bool?
}

struct UserTeam: Codable {
    
    let teamName: String?
    let teamRank: String?
}

struct UserRanks: Codable {
    
    let amigoRank: String?
    let positivityRank: String?
}

struct UserPoints: Codable {
    
    let amigoPoints: Int?
    let positivityPoints: Int?
    let bowelsRelieved: Int?
    var prayers: Int?
    var meaningfulPrayers: Int?
}

struct UserBans: Codable {
    
    let isBanned: Bool?
    let isChatBanned: Bool?
    let isFeedBanned: Bool?
    let banReason: String?
}

struct UserDetails: Codable {
    
    var username: String?
    var email: String?
    var fullName: String?
    var profilePictureUrl: String?
}
