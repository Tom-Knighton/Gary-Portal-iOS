//
//  User.swift
//  AlMurray
//
//  Created by Tom Knighton on 19/08/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import Foundation


struct UserDTO: Codable, Hashable {
        
    let userUUID: String?
    let userFullName: String?
    let userProfileImageUrl: String?
    let userIsAdmin: Bool?
    let userIsStaff: Bool?
}

extension UserDTO: Identifiable {
    var id: String { return userUUID ?? "" }
}

struct UserDetails: Codable {
    
    var userName: String?
    var userEmail: String?
    var fullName: String?
    var profilePictureUrl: String?
}

struct StaffManagedUserDetails: Codable {
    
    var userName: String?
    var spanishName: String?
    var profilePictureUrl: String?
    var teamId: Int?
    var amigoPoints: Int?
    var positivePoints: Int?
    var amigoRankId: Int?
    var positiveRankId: Int?
    var isQueued: Bool?
}

class User: Codable, ObservableObject {
    
    let userUUID: String?
    let userFullName: String?
    let userSpanishName: String?
    let userName: String?
    var userProfileImageUrl: String?
    let userQuote: String?
    let userBio: String?
    let userGender: String?
    let userIsStaff: Bool?
    let userIsAdmin: Bool?
    let userStanding: String?
    let userCreatedAt: Date?
    let userDateOfBirth: Date?
    let isDeleted: Bool?
    let isQueued: Bool?
    
    let userAuthTokens: UserAuthenticationTokens?
    let userAuthentication: UserAuthentication?
    var userTeam: UserTeam?
    var userRanks: UserRanks?
    var userPoints: UserPoints?
    
    var userBans: [UserBan]?
    var blockedUsers: [UserBlock]?
    
    public func ConvertToDTO() -> UserDTO {
        return UserDTO(userUUID: self.userUUID, userFullName: self.userFullName, userProfileImageUrl: self.userProfileImageUrl, userIsAdmin: self.userIsAdmin, userIsStaff: self.userIsStaff)
    }

    public func RemoveBan(banId: Int) {
        self.userBans?.removeAll(where: { $0.userBanId == banId })
    }
    
    public func hasBlockedUUID(uuid: String) -> Bool {
        return self.blockedUsers?.contains(where: { $0.blockedUserUUID == uuid && $0.isBlocked == true}) == true
    }
}

struct UserTeam: Codable {
    
    let userUUID: String?
    let teamId: Int?
    let team: Team?
}

struct UserRanks: Codable {
    
    let userUUID: String?
    let amigoRankId: Int?
    let positivityRankId: Int?
    let amigoRank: Rank?
    let positivityRank: Rank?
}

struct UserPoints: Codable {
    
    let userUUID: String?
    var amigoPoints: Int?
    var positivityPoints: Int?
    var bowelsRelieved: Int?
    var prayers: Int?
    var meaningfulPrayers: Int?
}

struct UserBan: Codable {

    let userBanId: Int?
    let userUUID: String?
    let banIssued: Date?
    let banExpires: Date?
    let banTypeId: Int?
    let banReason: String?
    let bannedByUUID: String?
    
    let bannedUser: User?
    let banType: BanType?
    let bannedBy: User?
}

struct BanType: Codable {
    
    let banTypeId: Int?
    let banTypeName: String?
}

extension BanType: Hashable, Identifiable {
    
    var id: Int { return banTypeId ?? 0 }
}

struct UserBlock: Codable {
    
    let blockerUserUUID: String?
    let blockedUserUUID: String?
    let isBlocked: Bool?
    
    let blockerUser: User?
    let blockedUser: User?
    let blockedUserDTO: UserDTO?
}

struct UserRegistration: Codable {
    
    let userEmail: String?
    let userName: String?
    let userFullName: String?
    let userPassword: String?
    let userGender: String?
    let userDOB: Date?
}
