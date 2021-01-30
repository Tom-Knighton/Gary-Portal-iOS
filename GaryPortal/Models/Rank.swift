//
//  Rank.swift
//  Gary Portal
//
//  Created by Tom Knighton on 13/01/2021.
//  Copyright © 2021 Tom Knighton. All rights reserved.
//

import Foundation

struct Rank: Codable {
    
    let rankId: Int?
    let rankName: String?
    let rankAccessLevel: Int?
}

extension Rank: Identifiable, Hashable {
    
    var id: Int { return rankId ?? 0 }
}
