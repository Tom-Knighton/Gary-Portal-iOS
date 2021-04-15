//
//  Game.swift
//  GaryPortal
//
//  Created by Tom Knighton on 12/04/2021.
//

import Foundation

struct GameType: Codable {
    
    let gameUUID: String?
    let gameName: String?
    let gameDescription: String?
    let gameTeamId: Int?
    let gameIsEnabled: Bool?
    let gameCoverUrl: String?
    
}
