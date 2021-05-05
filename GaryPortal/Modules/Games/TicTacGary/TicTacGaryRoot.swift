//
//  TicTacGaryRoot.swift
//  GaryPortal
//
//  Created by Tom Knighton on 20/04/2021.
//

import SwiftUI
import AlertToast

struct TicTacGaryRoot: View {
    
    @State var gameCode: String = ""
    @State var game: TicTacGaryGame?
    
    var body: some View {
        ZStack {
            GradientBackground()
            ScrollView {
                VStack {
                    Spacer().frame(height: 16)
                    ZStack {
                        AsyncImage(url: "https://cdn.tomk.online/GaryPortal/Games/ttg_cover.jpg")
                        VStack {
                            Spacer()
                            HStack {
                                Text("Tic Tac Gary: ")
                                    .font(.title3).bold()
                                    .padding()
                                    .foregroundColor(.white)
                                    .shadow(radius: 1)
                                Spacer()
                                Button(action: { self.createGame() }) {
                                    Text("Host New Game")
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
                    .frame(height: 250)
                    .cornerRadius(20)
                    .padding()
                    
                    VStack {
                        Text("Join Game:")
                            .font(.title3).bold()
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .padding()
                        GPTextField(text: $gameCode, placeHolder: "Game Code:", characterLimit: 6, characterSet: "0123456789")
                            .padding()
                        Button(action: { self.joinGame() }) {
                            Text("Join")
                                .padding(.horizontal, 32)
                                .padding()
                                .background(Color("Section"))
                                .foregroundColor(.primary)
                                .cornerRadius(10)
                        }
                        .shadow(radius: 3)
                        Spacer()
                    }
                    .background(Color("Section").cornerRadius(10).shadow(radius: 3))
                    .cornerRadius(20)
                    .padding()
                    
                    VStack {
                        Text("Tic Tac Gary Instructions:")
                            .font(.title3).bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        Text("1) To win, you must place your symbol in a consecutive horizontal, vertical or diagonal line of 3 or 4, whichever is higher and can fit on the board\n2) Your opponent's job is to disrupt your lines and form their own!")
                            .font(.headline)
                            .padding()
                    }
                    .background(Color("Section").cornerRadius(10).shadow(radius: 3))
                    .padding(.horizontal)
                    
                    Spacer().frame(height: 32)
                }
                
            }
            .edgesIgnoringSafeArea(.all)
        }
        .fullScreenCover(item: $game) { item in
            TicTacGaryLobby(game: item)
        }
        .onReceive(NotificationCenter.default.publisher(for: .updateGameLobby), perform: { obj in
            print(obj.userInfo?["json"])
            if let info = obj.userInfo, let json = info["json"] as? String, let updatedGame = json.jsonDecode(to: TicTacGaryGame.self) {
                self.game = updatedGame
            }
        })
    }
    
    func createGame() {
        GaryPortal.shared.gameConnection?.ttgCreateGame(hostUUID: GaryPortal.shared.currentUser?.userUUID ?? "", gameSize: 3)
    }
    
    func joinGame() {
        GaryPortal.shared.gameConnection?.ttgJoinGame(userUUID: GaryPortal.shared.currentUser?.userUUID ?? "", gameCode: self.gameCode)
    }
}

struct TicTacGaryLobby: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var game: TicTacGaryGame
    @State var isShowingAlert = false
    @State var alertContent: [String] = []
    @State var isShowingGame = false
    
    var body: some View {
        ZStack {
            GradientBackground()
            NavigationLink(destination: TicTacGaryGameView(game: self.game), isActive: $isShowingGame) { EmptyView() }
            VStack {
                Text("Tic Tac Gary")
                    .font(.largeTitle).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .foregroundColor(Color(UIColor.secondarySystemGroupedBackground))
                
                Spacer().frame(height: 8)
                
                HStack {
                    Spacer().frame(width: 12)
                    Button(action: { self.leaveGame() }) {
                        Text("Leave game (like a loser)")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color("Section"))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                    .shadow(radius: 3)
                    Spacer()
                }
                
                Text("Game Code: \(game.gameCode ?? "")")
                    .font(.title3).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .foregroundColor(Color(UIColor.secondarySystemGroupedBackground))
                
                Spacer().frame(height: 16)
                
                Text("Players:")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .foregroundColor(Color(UIColor.secondarySystemGroupedBackground))
                
                
                Group {
                    if let firstUser = game.firstUser {
                        UserListElement(user: firstUser, secondaryText: "Host", displaysChevron: false)
                    }
                    if let secondUser = game.secondUser {
                        UserListElement(user: secondUser, secondaryText: "Guest", displaysChevron: false)
                    }
                    if self.game.firstPlayerUUID?.isEmpty == false && self.game.secondPlayerUUID?.isEmpty == false && self.game.firstPlayerUUID == GaryPortal.shared.currentUser?.userUUID {
                        Button(action: { self.startGame() }) {
                            Text("Start Game")
                                .padding(.horizontal, 32)
                                .padding()
                                .background(Color("Section"))
                                .foregroundColor(.primary)
                                .cornerRadius(10)
                        }
                        .shadow(radius: 3)
                    }
                }
                
                if self.game.firstPlayerUUID != GaryPortal.shared.currentUser?.userUUID {
                    Text("Waiting for host to start game...")
                        .bold()
                        .padding()
                        .foregroundColor(Color(UIColor.secondarySystemGroupedBackground))
                }
                Spacer()
            }
            .onReceive(NotificationCenter.default.publisher(for: .updateGameLobby), perform: { obj in
                guard !self.isShowingGame else { return }
                if let info = obj.userInfo, let json = info["json"] as? String, let updatedGame = json.jsonDecode(to: TicTacGaryGame.self) {
                    self.game = updatedGame
                }
            })
            .onReceive(NotificationCenter.default.publisher(for: .hostLeftLobby)) { (_) in
                guard !self.isShowingGame else { return }
                print("LEFT")
                self.alertContent = ["Uh Oh", "The host of this lobby left, as a result the lobby was destroyed. Please rest assured they will be punished"]
                self.isShowingAlert = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .ttgGameStarted)) { _ in
                guard !self.isShowingGame else { return }
                self.isShowingGame = true
            }
            .alert(isPresented: $isShowingAlert) {
                Alert(title: Text(self.alertContent[0]), message: Text(self.alertContent[1]), dismissButton: .default(Text("Ok"), action: {
                    self.presentationMode.wrappedValue.dismiss()
                }))
            }
            .fullScreenCover(isPresented: $isShowingGame, onDismiss: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                TicTacGaryGameView(game: self.game)
            }
        }
        
        
        
    }
    
    func startGame() {
        GaryPortal.shared.gameConnection?.ttgStartGame(gameCode: self.game.gameCode ?? "")
    }
    
    func leaveGame() {
        GaryPortal.shared.gameConnection?.ttgLeaveGame(uuid: GaryPortal.shared.currentUser?.userUUID ?? "", gameCode: self.game.gameCode ?? "")
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct TicTacGaryGameView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var game: TicTacGaryGame
    @State var isMyGo = false
    @State var alertContent = ["", ""]
    @State var isShowingAlert = false
    
    var body: some View {
        ZStack {
            GradientBackground()
            VStack {
                Button(action: { self.leaveGame() }) { Text("Leave") }
                VStack {
//                    ForEach(Array(self.game.gameMatrix?.enumerated() ?? []), id: \.offset) { rowIndex, row in
//                        HStack {
//                            ForEach(game.gameMatrix?[rowIndex].indices ?? Range(0...0), id: \.self) { colIndex in
//                                let move = game.gameMatrix?[rowIndex][colIndex]
//                                TTGCard(size: game.gameSize ?? 3, move: "\(rowIndex), \(colIndex) (\(move)")
//                                    .onTapGesture {
//                                        let _ = print(":::: \(rowIndex), \(colIndex)")
//                                        self.playMove(row: rowIndex, col: colIndex)
//                                    }
//                                    .id(UUID().uuidString)
//                            }
//                            .id(UUID().uuidString)
//                        }
//                    }.id(UUID().uuidString)
                    ForEachWithIndex(game.gameMatrix ?? [[]], id: \.self) { colIndex, row in
                        HStack {
                            ForEachWithIndex(row, id: \.id) { rowIndex, col in
                                TTGCard(size: game.gameSize ?? 3, move: "\(rowIndex), \(colIndex) (\(col.content))")
                                    .rotation3DEffect(
                                        .init(degrees: col.content?.isEmptyOrWhitespace() == false ? 180 : 0),
                                        axis: (x: 0.0, y: 1.0, z: 0.0),
                                        anchor: .center,
                                        anchorZ: 0.0,
                                        perspective: 1.0
                                    )
                                    .onTapGesture {
                                        let _ = print("::::: \(rowIndex) \(colIndex)")
                                        self.playMove(row: rowIndex, col: colIndex)
                                    }
                            }
                        }

                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .updateGameLobby), perform: { obj in
            if let info = obj.userInfo, let json = info["json"] as? String, let updatedGame = json.jsonDecode(to: TicTacGaryGame.self) {
                self.game = updatedGame
                self.game.gameMatrix = updatedGame.gameMatrix
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: .hostLeftLobby)) { (_) in
            self.alertContent = ["Uh Oh", "The host of this game left! They are cowards, and feared your superior TicTactics. Rest assured they will be punished."]
            self.isShowingAlert = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .ttgMovePlayed), perform: { obj in
            if let info = obj.userInfo, let uuid = info["uuid"] as? String, let row = info["row"] as? Int, let col = info["col"] as? Int {
                print("hey bby, updating at \(row) \(col)")
                let sign = uuid == self.game.firstPlayerUUID ? "X" : "O"
                self.game.gameMatrix?[row][col].content = sign
                
            }
        })
        .toast(isPresenting: $isShowingAlert) {
            AlertToast(displayMode: .alert, type: .error(.red), title: self.alertContent[0], subTitle: self.alertContent[1])
        }
    }
    
    func leaveGame() {
        GaryPortal.shared.gameConnection?.ttgLeaveGame(uuid: GaryPortal.shared.currentUser?.userUUID ?? "", gameCode: self.game.gameCode ?? "")
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func playMove(row: Int, col: Int) {
        GaryPortal.shared.gameConnection?.ttgPlayMove(code: self.game.gameCode ?? "", uuid: GaryPortal.shared.currentUser?.userUUID ?? "", row: row, col: col)
    }
}

fileprivate struct TTGCard: View {
    
    var size: Int
    @State var move: String?
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(move?.isEmptyOrWhitespace() == false ? Color.blue : Color.white)
            .frame(width: getWidth(), height: getWidth())
            .overlay(
                Text(self.move ?? "")
            )
    }
    
    func getWidth() -> CGFloat {
        let width = UIScreen.main.bounds.width - (30 + 30)
        return width / CGFloat(self.size)
    }
}
//
//struct TicTacGaryRoot_Previews: PreviewProvider {
//    static var previews: some View {
//        TicTacGaryGameView(game: TicTacGaryGame(gameCode: "000000", gameSize: 3, firstPlayerUUID: "", secondPlayerUUID: "", gameMatrix: [["X", nil, nil], ["O", nil, nil],[nil, nil, "X"], ], winnerUUID: nil, gameWinType: nil, firstUser: nil, secondUser: nil))
//    }
//}
