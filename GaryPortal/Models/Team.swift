//
//  Team.swift
//  Gary Portal
//
//  Created by Tom Knighton on 13/01/2021.
//  Copyright © 2021 Tom Knighton. All rights reserved.
//

import Foundation

struct Team: Codable {
    
    let teamId: Int?
    let teamName: String?
    let teamAccessLevel: Int?
}

extension Team: Identifiable, Hashable {
    
    var id: Int { return teamId ?? 0}
}
