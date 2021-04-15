//
//  GarySweeperRoot.swift
//  GaryPortal
//
//  Created by Tom Knighton on 12/04/2021.
//

import SwiftUI

struct GarySweeperRoot: View {
    
    @State var isShowingGame = false
    @State var rows = 10
    @State var cols = 10
    @State var murrays = 10
    
    var body: some View {
        ZStack {
            GradientBackground()
            VStack {
                Text("GarySweeper")
                    .font(.largeTitle).bold()
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding()
                Spacer()
                GPGradientButton(action: { self.isShowingGame.toggle() }, buttonText: "Start A New Game", gradientColours: [Color(UIColor(hexString: "#283c86")), Color(UIColor(hexString: "#45a247"))])
                Stepper("Rows: \(rows)", value: $rows, in: 3...99)
                    .padding(6)
                    .background(Color("Section"))
                    .cornerRadius(10)
                    .foregroundColor(.primary)
                    .padding()
                    .shadow(radius: 3)
                Stepper("Columns: \(cols)", value: $cols, in: 3...99)
                    .padding(6)
                    .background(Color("Section"))
                    .cornerRadius(10)
                    .foregroundColor(.primary)
                    .padding()
                    .shadow(radius: 3)
                Stepper("Murrays: \(murrays)", value: $murrays, in: 3...self.cols)
                    .padding(6)
                    .background(Color("Section"))
                    .cornerRadius(10)
                    .foregroundColor(.primary)
                    .padding()
                    .shadow(radius: 3)
                Spacer()
            }
        }
//        .fullScreenCover(isPresented: $isShowingGame) {
//            GarySweeperGame(gameplay: GSGame(from: GSGameSettings(rows: rows, columns: cols, bombs: murrays)))
//        }
    }
}

struct GarySweeperGame: View {
    
    @ObservedObject var gameplay: GSGame
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                VStack {
                    Spacer()
                    ScrollView([.horizontal, .vertical]) {
                        VStack(spacing: 4) {
                            ForEach(0..<gameplay.board.count, id: \.self) { row in
                                HStack(spacing: 4) {
                                    ForEach(0..<gameplay.board[row].count, id: \.self) { col in
                                        GSCellView(game: self.gameplay, cell: self.gameplay.board[row][col])
                                    }
                                }
                            }
                        }
                        .alert(isPresented: $gameplay.showResult) {
                            Alert(title: Text("Finito!"))
                        }
                    }
                    Spacer()
                }
            }
            .navigationTitle("GarySweeper")
        }
    }
}


fileprivate struct GSCellView: View {
    
    @ObservedObject var game: GSGame
    var cell: GSCell
    
    var body: some View {
        content
            .frame(width: game.settings.tileSize, height: game.settings.tileSize, alignment: .center)
            .shadow(radius: 3)
            .onTapGesture {
                game.click(on: cell)
            }
            .onLongPressGesture {
                game.toggleFlag(on: cell)
            }
            .overlay(cell.content)
    }
    
    @ViewBuilder
    var content: some View {
        switch self.cell.status {
        case .exposed(let total):
            if total == 0 {
                RoundedRectangle(cornerRadius: 10).fill(Color.clear)
            } else {
                RoundedRectangle(cornerRadius: 10).fill(Color.red)
                    .overlay(cell.content.shadow(radius: 3))
            }
        case .bomb:
            RoundedRectangle(cornerRadius: 10).fill(Color.red)
                .overlay(cell.content.shadow(radius: 3))
        case .normal:
            RoundedRectangle(cornerRadius: 10).fill(Color.red)
        }
    }
    
}
