//
//  TicTacGary.swift
//  GaryPortal
//
//  Created by Tom Knighton on 20/04/2021.
//

import Foundation


class TicTacGaryGame: Codable, Identifiable {
    
    let gameCode: String?
    let gameSize: Int?
    let firstPlayerUUID: String?
    let secondPlayerUUID: String?
    var gameMatrix: [[TTGCell]]?
    let winnerUUID: String?
    let gameWinType: Int?
    
    let firstUser: UserDTO?
    let secondUser: UserDTO?
    
    var id: String { UUID().uuidString }
}

struct TTGCell: Codable, Identifiable, Hashable {
    let id: String?
    var content: String?
}

extension TicTacGaryGame: ObservableObject {
}
