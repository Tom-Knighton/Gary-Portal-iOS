//
//  GamesRootView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 12/04/2021.
//

import SwiftUI

struct GamesRootView: View {
    var body: some View {
        GamesListView()
            .navigationBarHidden(true)
    }
}

fileprivate struct GamesListView: View {
    
    @StateObject var datasource = GameTypeListDataSource()
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack {
                    ForEach(self.datasource.gameTypes, id: \.gameUUID) { game in
                        GameListCard(game: game)
                            .padding()
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    self.datasource.currentGame = .GarySweeper
                                }
                            }
                    }
                }
            }
        }
        .sheet(item: $datasource.currentGame) { item in
            if item == .GarySweeper {
                GarySweeperRoot()
            }
        }
        .onAppear {
            self.datasource.loadGameTypes(for: GaryPortal.shared.currentUser?.userTeam?.teamId ?? 0)
        }
        
    }
}

fileprivate struct GameListCard: View {
    
    @State var game: GameType
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                AsyncImage(url: game.gameCoverUrl ?? "")
                    .scaledToFit()
                    .frame(height: 150)
                    .opacity(0.4)
            }
            VStack {
                Text(self.game.gameName ?? "")
                    .font(.title).bold()
                    .shadow(radius: 3)
                    .padding()
                    .lineLimit(3)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                
                    
                Spacer()
                Text(self.game.gameDescription ?? "")
                    .padding(.all, 0)
                    .font(.subheadline)
                    .shadow(radius: 1)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.4).cornerRadius(15).shadow(radius: 3))
            }
        }
        .frame(minHeight: 200)
        .background(LinearGradient(gradient: Gradient(colors: [Color(UIColor(hexString: "#ad5389")), Color(UIColor(hexString: "#3c1053"))]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}
