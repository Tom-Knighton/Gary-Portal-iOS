//
//  GameTypeListDataSource.swift
//  GaryPortal
//
//  Created by Tom Knighton on 12/04/2021.
//

import Foundation
import SwiftUI

class GameTypeListDataSource: ObservableObject {
    
    @Published var gameTypes: [GameType] = []
    @Published var currentGame: CurrentGame? = .none
    
    enum CurrentGame: Identifiable {
        case GarySweeper, SpaceGambito, TicTacGary
        
        var id: String { return UUID().uuidString }
        
        static func fromName(name: String) -> CurrentGame {
            switch name {
            case "GarySweeper":
                return .GarySweeper
            case "Space Gambito":
                return .SpaceGambito
            case "Tic Tac Gary":
                return .TicTacGary
            default:
                return .GarySweeper
            }
        }
    }
    
    func loadGameTypes(for teamId: Int = 0) {
        GameService.getGameTypes(for: teamId) { (games, _) in
            if let games = games {
                DispatchQueue.main.async {
                    self.gameTypes = games
                }
            }
        }
    }
    
    func setCurrentGame(to gameName: String) {
        switch gameName {
        case "GarySweeper":
            self.currentGame = .GarySweeper
        default:
            self.currentGame = .none
        }
    }
}
