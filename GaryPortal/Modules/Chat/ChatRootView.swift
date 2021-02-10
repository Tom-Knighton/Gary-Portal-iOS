//
//  ChatListView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 31/01/2021.
//

import SwiftUI
import Combine
import Introspect
import ActionClosurable

struct ChatRootView: View {
    
    var body: some View {
        ChatListView()
    }
}

struct ChatListView: View {
    
    @ObservedObject var dataSource: ChatListDataSource = ChatListDataSource()
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(dataSource.chats, id: \.chatUUID) { chat in
                    NavigationLink(destination: NavigationLazyView(ChatView(chat: chat))) {
                        ChatListItem(chat: chat)
                    }
                }
                .animation(Animation.spring())
            }
            .introspectScrollView { (scrollView) in
                scrollView.refreshControl = UIRefreshControl { refreshControl in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.dataSource.loadChats()
                        refreshControl.endRefreshing()
                    }
                }
                
            }
        }
        .onAppear {
            self.dataSource.loadChats()
        }
        .background(Color.clear)
    }
}


struct ChatListItem: View {
    
    var chat: Chat
    let unreadGradient = [Color(UIColor(hexString: "#5f2c82")), Color(UIColor(hexString: "#49a09d"))]
    
    var body: some View {
        HStack {
            Spacer().frame(width: 16)
            VStack {
                HStack {
                    Spacer().frame(width: 16)
                    
                    chat.profilePicToDisplay(for: GaryPortal.shared.currentUser?.userUUID ?? "")
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    
                    Spacer().frame(width: 16)
                    Text(chat.getTitleToDisplay(for: GaryPortal.shared.currentUser?.userUUID ?? ""))
                        .font(.custom("Montserrat-SemiBold", size: 19))
                        .foregroundColor(.primary)
                    Spacer()
                
                    Spacer().frame(width: 16)
                }
                Spacer().frame(height: 8)
                HStack {
                    Spacer().frame(width: 82)
                    Text(chat.getLastMessageToDisplay(for: GaryPortal.shared.currentUser?.userUUID ?? ""))
                        .font(.custom("Montserrat-Light", size: 14))
                        .multilineTextAlignment(.leading)
                        .frame(maxHeight: 100)
                        .foregroundColor(.secondary)
                    Spacer()
                    
                    if chat.hasUnreadMessages(for: GaryPortal.shared.currentUser?.userUUID ?? "") {
                        LinearGradient(gradient: Gradient(colors: self.unreadGradient), startPoint: .topLeading, endPoint: .bottomTrailing)
                            .frame(width: 16, height: 16)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    
                    Spacer().frame(width: 16)
                }
                
                
            }
            .padding(.top, 16)
            .padding(.bottom, 16)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(20)
            .shadow(radius: 10)
            
            Spacer().frame(width: 16)
        }
    }
}
