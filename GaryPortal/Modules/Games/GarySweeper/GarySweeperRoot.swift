//
//  GarySweeperRoot.swift
//  GaryPortal
//
//  Created by Tom Knighton on 12/04/2021.
//

import SwiftUI

struct GSPreviews: PreviewProvider {
    static var previews: some View {
        GarySweeperRoot()
    }
}

struct GarySweeperRoot: View {
    
    @State var isShowingGame = false
    @State var rows = 10
    @State var cols = 10
    @State var murrays = 10
    
    var body: some View {
        ZStack {
            GradientBackground()
            ScrollView {
                VStack {
                    Spacer().frame(height: 16)
                    ZStack {
                        AsyncImage(url: "https://cdn.tomk.online/GaryPortal/AppLogo.png")
                        VStack {
                            Spacer()
                            HStack {
                                Text("Gary Sweeper: ")
                                    .font(.title3).bold()
                                    .padding()
                                    .foregroundColor(.white)
                                    .shadow(radius: 1)
                                Spacer()
                                Button(action: { self.isShowingGame = true }) {
                                    Text("Play")
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(Color("Section"))
                                        .foregroundColor(.primary)
                                        .cornerRadius(10)
                                }
                                .shadow(radius: 3)
                                Spacer().frame(width: 16)
                            }
                            .frame(minHeight: 50)
                            .cornerRadius(20)
                            .background(Color.black.opacity(0.5))
                        }
                       
                    }
                    .frame(height: 300)
                    .cornerRadius(20)
                    .padding()
                    
                    
                    VStack {
                        Text("Gary Sweeper Instructions:")
                            .font(.title3).bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        Text("1) Choose the number of rows, columns and murrays below\n\n2) Tap a cell to open it, the number will indicate how many Murrays are around it\n\n3) If you tap on a Murray, he will explode and you will lose the game!\n\n4) Long tap a cell to mark it as a Murray, if you find all the Murrays without exploding any, you win!")
                            .font(.headline)
                            .shadow(radius: 1)
                            .padding()
                    }
                    .background(Color("Section").cornerRadius(10).shadow(radius: 3))
                    .padding(.horizontal)
                    
                    VStack {
                        Text("Gary Sweeper Settings:")
                            .font(.title3).bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        
                        Group {
                            Stepper("Rows: \(self.rows)") {
                                self.rows = min(self.rows + 1, 99)
                                if (self.rows * self.cols / 2) < self.murrays {
                                    self.murrays = (self.rows * self.cols) / 2
                                }
                            } onDecrement: {
                                self.rows = max(3, self.rows - 1)
                                if (self.rows * self.cols / 2) < self.murrays {
                                    self.murrays = (self.rows * self.cols) / 2
                                }
                            }

                            Stepper("Columns: \(self.cols)") {
                                self.cols = min(self.cols + 1, 99)
                                if (self.rows * self.cols / 2) < self.murrays {
                                    self.murrays = (self.rows * self.cols) / 2
                                }
                            } onDecrement: {
                                self.cols = max(3, self.cols - 1)
                                if (self.rows * self.cols / 2) < self.murrays {
                                    self.murrays = (self.rows * self.cols) / 2
                                }
                            }
                            Stepper("Murrays: \(self.murrays)") {
                                self.murrays = min(self.murrays + 1, (self.rows * self.cols) / 2)
                            } onDecrement: {
                                self.rows = max(3, self.murrays - 1)
                            }
                            .padding(.bottom, 16)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .background(Color("Section").cornerRadius(10).shadow(radius: 3))
                    .padding(.horizontal)
                    
                    
                    Spacer().frame(height: 32)
                }

            }
            .edgesIgnoringSafeArea(.all)
        }
        .fullScreenCover(isPresented: $isShowingGame) {
            GarySweeperGame(gameManager: GSGameManager(cellSize: 10))
        }
    }
}

struct GarySweeperGame: View {
    
    @ObservedObject var gameManager: GSGameManager
    
    var body: some View {
            GeometryReader { geometry -> AnyView in
                let cellSize = CGFloat(geometry.size.width) / CGFloat(self.gameManager.cells.size)
                return Grid(width: self.gameManager.cells.size, height: self.gameManager.cells.size) { hIndex, vIndex in
                    GSCellView(index: vIndex * self.gameManager.cells.size + hIndex, gameManager: self.gameManager)
                        .frame(width: cellSize, height: cellSize)
                        .border(Color.black.opacity(0.2), width: 2)
                }.erased
            }
        }
}

fileprivate struct Grid<Content: View>: View {
    let (width, height): (Int, Int)
    var content: (Int, Int) -> Content
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<self.height) { vIndex in
                HStack(spacing: 0) {
                    ForEach(0..<self.width) { hIndex in
                        self.content(hIndex, vIndex)
                    }
                }
            }
        }
    }
}

struct GSCellView: View {
    
    let index: Int
    @ObservedObject var gameManager: GSGameManager
    
    var body: some View {
            view(with: gameManager.cells.board[index])
                .minimumScaleFactor(0.1)
                .onTapGesture { self.gameManager.openCell(atIndex: self.index) }
                .onLongPressGesture { self.gameManager.toggleFlag(atIndex: self.index) }
        }
        
        private func view(with state: GSCell) -> AnyView {
            switch state {
            case .closed(let flag):
                return ZStack {
                    Color.blue
                    flag ? Text("🚩") : nil
                }.erased
            case .open(let openState):
                switch openState {
                case .mine: return Text("💣").erased
                case .empty: return Text("").erased
                case .number(let number): return Text(number.description).erased
                }
            }
        }
    
}

extension View {
    var erased: AnyView { AnyView(self) }
}
