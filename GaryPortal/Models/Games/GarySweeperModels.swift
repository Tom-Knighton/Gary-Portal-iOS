//
//  GarySweeperModels.swift
//  GaryPortal
//
//  Created by Tom Knighton on 13/04/2021.
//

import Foundation
import SwiftUI
import Combine

//MARK: - GameManager

final class GSGameManager: ObservableObject {
    @Published var gameMode: GSGameMode = .playing
    @Published var cells: GSCells
    private var cancellables: [AnyCancellable] = []
    
    init(cellSize: Int) {
        self.cells = GSCells(size: cellSize)
        cells.objectWillChange.sink { (_) in
            self.objectWillChange.send()
        }
        .store(in: &cancellables)
    }
    
    func openCell(atIndex index: Int) {
        guard case .closed = self.cells.board[index] else { return }
        withAnimation {
            if !self.cells.open(index: index) {
                self.gameMode = .gameOver
            } else if self.cells.restOfCell == self.cells.numberOfMines {
                self.gameMode = .gameClear
            }
        }
    }
    
    func toggleFlag(atIndex index: Int) {
        guard case .closed(let flag) = self.cells.board[index] else { return }
        self.cells.board[index] = .closed(flag: !flag)
    }
    
    func restartGame() {
        self.cells.reset()
        self.gameMode = .playing
    }
    
    
    enum GSGameMode {
        case playing, gameOver, gameClear
    }
}

//MARK: - Cell

enum GSCell: Equatable {
    case closed(flag: Bool = false), open(Open)
    var unrevealed: Bool {
        self == .closed(flag: false) || self == .closed(flag: true)
    }
    enum Open: Equatable {
        case mine, empty, number(Int)
    }
}

final class GSCells: ObservableObject {
    let size: Int
    @Published var board: [GSCell] = []
    private(set) var mines: [Bool] = []
    private(set) var numberOfMines = 0
    
    var restOfCell: Int {
        board.filter { $0.unrevealed }.count
    }
    
    init(size: Int) {
        self.size = size
        reset()
    }
    
    func reset() {
        self.board = Array(repeating: GSCell.closed(), count: size*size)
        self.numberOfMines = Int(Double(size) * 1.5)
        mines = (Array(repeating: true, count: numberOfMines) + Array(repeating: false, count: size*size-numberOfMines)).shuffled()
    }
    
    @discardableResult
    func open(index: Int, recursive: Bool = false) -> Bool {
        guard case .closed = board[index] else { return true }
        
        if mines[index] {
            if recursive { return true }
            board[index] = .open(.mine)
            return false
        }
        
        let indices = self.indices(around: index)
        let numMines = indices.filter { mines[$0] }.count
        if numMines == 0 {
            board[index] = .open(.empty)
            indices.filter { board[$0].unrevealed }.forEach { open(index: $0, recursive: true) }
        } else {
            board[index] = .open(.number(numMines))
        }
        return true
    }
    
    func indices(around index: Int) -> [Int] {
        ((index % size == 0 ? [] : [
            index - size - 1,
            index - 1,
            index + size - 1
        ]) +
        ((index + 1) % size == 0 ? [] : [
            index - size + 1,
            index + 1,
            index + size + 1
        ]) +
        [
            index - size,
            index + size
        ]).filter { 0 <= $0 && $0 <= self.board.count }
    }
}
