//
//  UserAuthentication.swift
//  Gary Portal
//
//  Created by Tom Knighton on 13/01/2021.
//  Copyright © 2021 Tom Knighton. All rights reserved.
//

import Foundation

struct UserAuthentication: Codable {
    
    let userUUID: String?
    let userEmail: String?
    let userPhone: String?
    let userEmailConfirmed: Bool?
    let userPhoneConfirmed: Bool?

}

struct UserAuthenticationTokens: Codable {
    
    let authenticationToken: String?
    let refreshToken: String?
}

struct UserRefreshToken: Codable {
    
    let userUUID: String?
    let refreshToken: String?
    let tokenIssueDate: Date?
    let tokenExpiryDate: Date?
    let tokenClient: String?
    let tokenIsEnabled: Bool?
}

struct AuthenticatingUser: Codable {
    
    let authenticatorString: String?
    let password: String?
}
