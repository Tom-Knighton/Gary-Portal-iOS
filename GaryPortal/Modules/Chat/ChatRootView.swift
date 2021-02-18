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
    
    @State var isShowingNameAlert = false
    @State var isShowingAlert = false
    @State var alertContent: [String] = []
    @State var selectedChat: Chat?
    @State var newName: String = ""
    
    @State var isShowingCreator = false
    
    init() {
        UITableView.appearance().backgroundColor = UIColor.clear
        UITableViewCell.appearance().selectionStyle = .none
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            List {
                ForEach(dataSource.getChatsFiltered(), id: \.chatUUID) { chat in
                    ZStack {
                        NavigationLink(destination: NavigationLazyView(ChatView(chat: chat))) {
                            EmptyView()
                        }
                        .frame(width: 0)
                        .opacity(0)
                        
                        ChatListItem(chat: chat)
                            .contextMenu(menuItems: {
                                if chat.chatIsProtected == false {
                                    if chat.canRenameChat() {
                                        Button(action: { self.beginEditChat(chat: chat) }, label: {
                                            Text("Rename chat")
                                            Image(systemName: "pencil")
                                        })
                                    }

                                    Button(action: { self.leaveChat(chat: chat) }, label: {
                                        Text("Leave chat")
                                        Image(systemName: "hand.wave.fill")
                                    })
                                }
                            })
                    }
                    .animation(Animation.spring())
                    .listRowBackground(Color.clear)
                    .background(Color.clear)

                    }
                   
            }
            .listSeparatorStyle(.none)
            .introspectTableView { (tableView) in
                tableView.refreshControl = UIRefreshControl { refreshControl in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.dataSource.loadChats()
                        refreshControl.endRefreshing()
                    }
                }
                
            }
            .onAppear {
                self.dataSource.loadChats()
            }
            .background(Color.clear)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { self.isShowingCreator = true }) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.white)
                            .frame(width: 64, height: 64)
                            .cornerRadius(10)
                            .background(LinearGradient(gradient: Gradient(colors: [Color(UIColor(hexString: "#ad5389")), Color(UIColor(hexString: "#3c1053"))]), startPoint: .topLeading, endPoint: .bottomTrailing).cornerRadius(10))
                    }
                    .opacity(0.85)
                    .padding()
                    .shadow(radius: 5)
                    Spacer().frame(width: 16)
                }
                Spacer().frame(height: 16)
            }
            .sheet(isPresented: $isShowingCreator, onDismiss: { self.dataSource.loadChats() }, content: {
                CreateChatView(chatDataSource: self.dataSource)
            })
            
            AZAlert(title: "New Chat Name", message: "Enter a new chat name for: \(self.selectedChat?.getTitleToDisplay(for: GaryPortal.shared.currentUser?.userUUID ?? "") ?? "")", isShown: $isShowingNameAlert, text: $newName) { (newName) in
                let newName = newName.trim()
                if !newName.isEmptyOrWhitespace() {
                    guard let selectedChat = self.selectedChat else { return }
                    
                    self.dataSource.changeChatName(chat: selectedChat, newName: newName)
                    GaryPortal.shared.chatConnection?.editChatName(selectedChat.chatUUID ?? "", to: newName)
                } else {
                    self.alertContent = ["Error", "Please enter a valid chat name"]
                    self.isShowingAlert = true
                }
            }
            

        }
        
    }
    
    func beginEditChat(chat: Chat) {
        self.selectedChat = chat
        self.isShowingNameAlert = true
    }
    
    func leaveChat(chat: Chat) {
        ChatService.leaveChat(userUUID: GaryPortal.shared.currentUser?.userUUID ?? "", chatUUID: chat.chatUUID ?? "")
        self.dataSource.chats.removeAll(where: { $0.chatUUID == chat.chatUUID })
    }
}

struct ChatListItem: View {
    
    var chat: Chat
    let unreadGradient = [Color(UIColor(hexString: "#5f2c82")), Color(UIColor(hexString: "#49a09d"))]
    let protectedGradientColors = [Color(UIColor(hexString: "#642B73")), Color(UIColor(hexString: "#C6426E"))]
    
    var body: some View {
        ZStack {
            if !chat.isDMAndBlocked() {
                HStack {
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
                                .foregroundColor(self.chat.chatIsProtected == false ? .primary : .white)
                            Spacer()
                        
                            Spacer().frame(width: 16)
                        }
                        Spacer().frame(height: 8)
                        HStack {
                            Spacer().frame(width: 82)
                            Text(chat.getLastMessageToDisplay(for: GaryPortal.shared.currentUser?.userUUID ?? ""))
                                .font(.custom("Montserrat-Light", size: 14))
                                .multilineTextAlignment(.leading)
                                .frame(maxHeight: 80)
                                .foregroundColor(self.chat.chatIsProtected == false ? .secondary : .gray)
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
                    .if(self.chat.chatIsProtected == true) { $0.background(LinearGradient(gradient: Gradient(colors: self.protectedGradientColors), startPoint: .leading, endPoint: .trailing)) }
                    .if(self.chat.chatIsProtected == false) { $0.background(Color(UIColor.secondarySystemGroupedBackground)) }
                    .cornerRadius(20)
                    .shadow(radius: 10)
                }
            }
        }
        
        
    }
}
