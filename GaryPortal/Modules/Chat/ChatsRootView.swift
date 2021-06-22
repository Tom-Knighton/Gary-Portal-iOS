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

struct ChatsRootView: View {
    
    var body: some View {
        ChatHome()
            .navigationBarHidden(true)
    }
}

struct ChatsListView: View {
    
    @ObservedObject var dataSource: ChatListDataSource = ChatListDataSource()
    
    @State var isShowingNameAlert = false
    @State var isShowingAlert = false
    @State var alertContent: [String] = []
    @State var selectedChat: Chat?
    @State var newName: String = ""
    
    @State var isShowingCreator = false
    @State var edges = UIApplication.shared.windows.first?.safeAreaInsets
    
    var body: some View {
        ZStack(alignment: .top) {
            if self.dataSource.isChatBanned {
                ZStack {
                    Color.black.cornerRadius(5).edgesIgnoringSafeArea(.all)
                    Text("You have been temporarily banned from GaryChat, please wait until your ban expires to access GaryChat again")
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                        .edgesIgnoringSafeArea(.all)
                }
            } else {
                GeometryReader { gr in
                    ScrollView {
                        LazyVStack {
                            ForEach(dataSource.getChatsFiltered(), id: \.chatUUID) { chat in
                                NavigationLink(destination: ChatView(chat: chat)) {
                                    ChatsListItem(chat: chat)
                                        .contextMenu(menuItems: {
                                            if chat.chatIsProtected == false {
                                                if chat.canRenameChat() {
                                                    Button(action: { beginEditChat(chat: chat) }, label: {
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
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                            }
                        }
                        .onAppear {
                            self.dataSource.loadChats()
                        }
                        Spacer().frame(height: (edges?.bottom ?? 0) + (edges?.bottom == 0 ? 70 : 30))
                    }
                }
                
                
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
                    Spacer().frame(height: (edges?.bottom ?? 0) + (edges?.bottom == 0 ? 70 : 30))
                }
                .sheet(isPresented: $isShowingCreator, onDismiss: { self.dataSource.loadChats() }, content: {
//                    CreateChatView(chatDataSource: self.dataSource)
                })
            }
        }
//        .navigationBarHidden(true)
    }
    
    func beginEditChat(chat: Chat) {
        self.selectedChat = chat
        self.textFieldAlert()
    }
    
    func leaveChat(chat: Chat) {
        ChatService.leaveChat(userUUID: GaryPortal.shared.currentUser?.userUUID ?? "", chatUUID: chat.chatUUID ?? "")
        self.dataSource.chats.removeAll(where: { $0.chatUUID == chat.chatUUID })
    }
    
    func textFieldAlert() {
        let oldChatName = self.selectedChat?.getTitleToDisplay(for: GaryPortal.shared.currentUser?.userUUID ?? "") ?? ""
        let alert = UIAlertController(title: "New Chat Name", message: "Enter a new chat name for: \(oldChatName)", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = oldChatName
            textField.autocapitalizationType = .words
            textField.autocorrectionType = .yes
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
            guard let textField = alert.textFields?[0], let newName = textField.text?.trim() else { return }
            if !newName.isEmptyOrWhitespace() {
                guard let selectedChat = self.selectedChat else { return }
                
                self.dataSource.changeChatName(chat: selectedChat, newName: newName)
                GaryPortal.shared.chatConnection?.editChatName(selectedChat.chatUUID ?? "", to: newName)
            } else {
                self.alertContent = ["Error", "Please enter a valid chat name"]
                self.isShowingAlert = true
            }
        }))
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
}

struct ChatsListItem: View {
    
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
