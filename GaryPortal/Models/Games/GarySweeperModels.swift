//
//  GarySweeperModels.swift
//  GaryPortal
//
//  Created by Tom Knighton on 13/04/2021.
//

import Foundation
import SwiftUI

//MARK: - Game

class GSGame: ObservableObject {
    
    @Published var settings: GSGameSettings
    @Published var board: [[GSCell]]
    @Published var showResult: Bool = false
    @Published var isWon = false
    
    init(from settings: GSGameSettings) {
        self.settings = settings
        self.board = Self.generateBoard(from: settings)
    }
    
    func hasPlayerWon() -> Bool {
        var result = true
        for row in 0..<settings.numRows {
            for column in 0..<settings.numColumns {
                if self.board[row][column].status == .normal {
                    result = false
                }
            }
        }
        return result
    }
    
    func click(on cell: GSCell) {
       
        if case GSCell.GSCellStatus.exposed(_) = cell.status {
            return
        }
        if cell.isFlagged {
            return
        }
        
        if cell.status == .bomb {
            cell.isOpened = true
            self.showResult = true
            self.isWon = true
        } else {
            reveal(for: cell)
        }
        
        if self.hasPlayerWon() {
            self.showResult = true
            self.isWon = true
        }
        self.objectWillChange.send()
    }
    
    func toggleFlag(on cell: GSCell) {
        guard !cell.isOpened else { return }
        
        cell.isFlagged.toggle()
        if hasPlayerWon() {
            self.showResult = true
            self.isWon = true
        }
        self.objectWillChange.send()
    }
    
    func reset() {
        self.board = Self.generateBoard(from: settings)
        self.showResult = false
        self.isWon = false
    }
    
    private func reveal(for cell: GSCell) {
        guard !cell.isOpened, !cell.isFlagged, cell.status != .bomb else { return }
        
        let exposedCount = getExposedCount(for: cell)
        if cell.status != .bomb {
            cell.status = .exposed(exposedCount)
            cell.isOpened = true
        }
        
        if exposedCount == 0 {
            let topCell = self.board[max(0, cell.row - 1)][cell.column]
            let bottomCell = self.board[min(cell.row + 1, board.count - 1)][cell.column]
            let leftCell = self.board[cell.row][max(0, cell.column - 1)]
            let rightCell = self.board[cell.row][min(cell.column + 1, board[0].count - 1)]
            self.reveal(for: topCell)
            self.reveal(for: bottomCell)
            self.reveal(for: leftCell)
            self.reveal(for: rightCell)
        }
    }
    
    private func getExposedCount(for cell: GSCell) -> Int {
        let row = cell.row
        let col = cell.column
        
        let minRow = max(row - 1, 0)
        let minCol = max(col - 1, 0)
        let maxRow = min(row + 1, board.count - 1)
        let maxCol = min(col + 1, board[0].count - 1)
        
        var totalMurrayCount = 0
        for row in minRow...maxRow {
            for col in minCol...maxCol {
                if self.board[row][col].status == .bomb {
                    totalMurrayCount += 1
                }
            }
        }
        return totalMurrayCount
    }
    
    private static func generateBoard(from settings: GSGameSettings) -> [[GSCell]] {
        var newBoard = [[GSCell]]()
        
        for row in 0..<settings.numRows {
            var column = [GSCell]()
            for col in 0..<settings.numColumns {
                column.append(GSCell(row: row, column: col))
            }
            newBoard.append(column)
        }
        
        var numberOfMurraysPlaced = 0
        while numberOfMurraysPlaced < settings.numBombs {
            let randomRow = Int.random(in: 0..<settings.numRows)
            let randomCol = Int.random(in: 0..<settings.numColumns)
            let currentRandomCellStatus = newBoard[randomRow][randomCol].status
            if currentRandomCellStatus != .bomb {
                newBoard[randomRow][randomCol].status = .bomb
                numberOfMurraysPlaced += 1
            }
        }
        return newBoard
    }
}

//MARK: - Game Settings

class GSGameSettings: ObservableObject {
    
    @Published var numRows = 10
    @Published var numColumns = 10
    @Published var numBombs = 10
    
    var tileSize: CGFloat {
        max((UIScreen.main.bounds.width / CGFloat(numColumns)) - CGFloat(4), 30)
    }
    
    init(rows: Int = 10, columns: Int = 10, bombs: Int = 10) {
        self.numRows = rows
        self.numColumns = columns
        self.numBombs = bombs
    }
}

//MARK: - Cell

class GSCell: ObservableObject {
    
    var row: Int
    var column: Int
    @Published var status: GSCellStatus
    @Published var isOpened: Bool
    @Published var isFlagged: Bool
    
    
    var content: Text {
        if !isOpened && isFlagged {
            return Text("🚩")
        }
        
        switch self.status {
        case .bomb:
            if isOpened {
                return Text("💥")
            }
            return Text("")
        case .normal:
            return Text("")
        case .exposed(let total):
            if !isOpened {
                return Text("")
            }
            if total == 0 {
                return Text("")
            }
            
            return Text(String(describing: total))
        }
    }
    
    enum GSCellStatus: Equatable {
        case normal, exposed(Int), bomb
    }
    
    init(row: Int, column: Int) {
        self.row = row
        self.column = column
        self.status = .normal
        self.isOpened = false
        self.isFlagged = false
    }
}
