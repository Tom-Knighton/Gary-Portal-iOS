//
//  ChatHome.swift
//  GaryPortal
//
//  Created by Tom Knighton on 07/05/2021.
//

import SwiftUI

struct ChatHome: View {
    @ObservedObject var datasource = ChatListViewModel()
    @State var edges = UIApplication.shared.windows.first?.safeAreaInsets
    @State var isShowingChatCreator = false
    
    var body: some View {
        GeometryReader { gr in
            ScrollViewReader { sr in
                ScrollView {
                    HStack {
                        Spacer()
                        Button(action: { self.isShowingChatCreator.toggle() }) {
                            HStack {
                                Text("New Chat")
                                    .fontWeight(.semibold)
                                Image(systemName: "plus.circle")
                            }
                            .foregroundColor(.black)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color.white)
                            .clipShape(Capsule())
                        }
                        Spacer().frame(width: 16)
                    }
                    LazyVStack {
                        ForEach(self.datasource.chats, id: \.chatUUID) { chat in
                            NavigationLink(destination: ChatConversationView(chat: chat)) {
                                ChatListItem(chat: chat)
                                    .id(chat.chatUUID)
                            }
                        }
                    }
                    .onAppear {
                        self.datasource.loadChats(for: GaryPortal.shared.currentUser?.userUUID ?? "")
                    }
                    Spacer().frame(height: (edges?.bottom ?? 0) + (edges?.bottom == 0 ? 70 : 30))
                }
            }
        }
        .sheet(isPresented: $isShowingChatCreator, content: {
            CreateChatView(chatDataSource: self.datasource)
        })
    }
}

fileprivate struct ChatListItem: View {
    
    @State var chat: Chat
    
    var body: some View {
        VStack {
            let uuid = GaryPortal.shared.currentUser?.userUUID ?? ""
            HStack(spacing: 8) {
                VStack {
                    chat.profilePicToDisplay(for: uuid)
                        .padding()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                    Spacer()
                }
                
                VStack(spacing: 8) {
                    Text(chat.getTitleToDisplay(for: uuid))
                        .font(.title2).bold()
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    Text(chat.getLastMessageToDisplay(for: uuid))
                        .frame(maxWidth: .infinity, maxHeight: 50, alignment: .leading)
                        .foregroundColor(.secondary)
                }
                VStack(spacing: 8) {
                    if chat.hasUnreadMessages(for: uuid) {
                        Image(systemName: "envelope.badge.fill")
                    }
                    Text((chat.lastChatMessage?.messageCreatedAt ?? chat.chatCreatedAt ?? Date()).shortDateOrTime())
                        .foregroundColor(.secondary)
                }
               
                Spacer().frame(width: 8)
            }
        }
        .padding()
        .background(Color("Section"))
        .cornerRadius(20)
        .shadow(radius: 3)
        .padding(.horizontal, 8)
        
    }
    
}

struct ChatHome_Previews: PreviewProvider {
    static var previews: some View {
        ChatHome()
            .preferredColorScheme(.dark)
    }
}
