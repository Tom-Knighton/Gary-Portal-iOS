//
//  ChatListView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 31/01/2021.
//

import SwiftUI

struct ChatRootView: View {
    
    @ObservedObject var dataSource = ChatListDataSource()

    var body: some View {
        ChatListView(dataSource: dataSource)
        
    }
}

class ChatListDataSource: ObservableObject {
    @Published var chats = [Chat]()
    
    init() {
        ChatService.getChats(for: GaryPortal.shared.currentUser?.userUUID ?? "") { (newChats, error) in
            DispatchQueue.main.async {
                self.chats = newChats ?? []
            }
        }
    }
}



struct ChatListView: View {
    
    @ObservedObject var dataSource: ChatListDataSource
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(dataSource.chats, id: \.chatUUID) { chat in
                    NavigationLink(destination: ChatView(chat: chat)) {
                        ChatListItem(chat: chat)
                    }
                }
            }
        }
        .background(Color.clear)
    }
}

class ChatMessagesDataSource: ObservableObject {
    @Published var messages = [ChatMessage]()
    @Published var isLoadingPage = false
    @Published var canLoadMore = true
    @Published var lastMessageUUID = ""
    @Published var hasLoadedFirst = false
    var chatUUID: String = ""
    private var lastDateFrom = Date()
    
    init(chatUUID: String) {
        self.chatUUID = chatUUID
    }
    
    func loadMoreContentIfNeeded(currentMessage message: ChatMessage?) {
        guard let message = message else {
            loadMoreContent()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.isLoadingPage = false
            }
            return
        }
        
        guard !isLoadingPage else { return }
        
        let thresholdIndex = 0
        if messages.firstIndex(where: { $0.chatMessageUUID == message.chatMessageUUID }) == thresholdIndex {
            loadMoreContent()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.isLoadingPage = false
            }
        }
    }
    
    func loadMoreContent() {
        guard !isLoadingPage, canLoadMore else {
            return
        }
        
        isLoadingPage = true
        ChatService.getChatMessages(for: chatUUID, startingFrom: lastDateFrom, limit: 20) { (newMessages, error) in
            if error == nil {
                DispatchQueue.main.async {
                    let oldLastMessage = self.messages.first?.chatMessageUUID ?? ""
                    var finalNewMessages: [ChatMessage] = []
                    newMessages?.forEach({ newMessage in
                        if !self.messages.contains(where: { $0.chatMessageUUID == newMessage.chatMessageUUID}) {
                            finalNewMessages.insert(newMessage, at: 0)
                        }
                    })
                    
                    self.messages.insert(contentsOf: finalNewMessages, at: 0)
                    self.lastMessageUUID = oldLastMessage == "" ? finalNewMessages.last?.chatMessageUUID ?? "" : oldLastMessage

                    self.lastDateFrom = newMessages?.last?.messageCreatedAt ?? Date()
                                        
                    if (newMessages?.count ?? 0) < 20 {
                        self.canLoadMore = false
                    }
                }
                
            }
        }
    }
}


struct ChatView: View {
    
    var chat: Chat
    @ObservedObject var datasource: ChatMessagesDataSource
    @Environment(\.presentationMode) var presentationMode
    
    init(chat: Chat) {
        self.chat = chat
        self.datasource = ChatMessagesDataSource(chatUUID: chat.chatUUID ?? "")
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                ScrollViewReader { reader in
                    LazyVStack(spacing: 0) {
                        ForEach(datasource.messages, id: \.chatMessageUUID) { message in
                            let index = datasource.messages.firstIndex(where: { $0.chatMessageUUID == message.chatMessageUUID })
                            let lastMessage = index == 0 ? nil : self.datasource.messages[(index ?? 0) - 1]
                            let nextMessage = index == datasource.messages.count - 1 ? nil : self.datasource.messages[(index ?? 0) + 1]
                            ChatMessageView(chatMessage: message, nextMessage: nextMessage, lastMessage: lastMessage)
                                .id(message.chatMessageUUID)
                                .onAppear(perform: {
                                    datasource.loadMoreContentIfNeeded(currentMessage: message)
                                })
                        }
                        
                    }
                    .onAppear {
                        reader.scrollTo(datasource.messages.last?.chatMessageUUID ?? "", anchor: .bottom)
                    }
                    .onChange(of: datasource.lastMessageUUID) { (newValue) in
                        reader.scrollTo(newValue, anchor: .bottom)
                        self.datasource.lastMessageUUID = ""
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.datasource.isLoadingPage = false
                        }
                    }
                }
            }
            .navigationTitle(chat.getTitleToDisplay(for: GaryPortal.shared.currentUser?.userUUID ?? ""))
            .navigationBarItems(leading:
                Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                   Image(systemName: "chevron.backward")
            })
        }
        .onAppear {
            self.datasource.loadMoreContentIfNeeded(currentMessage: nil)
        }
    }
}

struct ChatMessageView: View {

    var chatMessage: ChatMessage
    var nextMessage: ChatMessage?
    var lastMessage: ChatMessage?
    
    let otherMsgGradient = Gradient(colors: [Color(UIColor(hexString: "#ad5389")), Color(UIColor(hexString: "#3c1053"))])
    
    var body: some View {
        let ownMessage = chatMessage.userUUID == GaryPortal.shared.currentUser?.userUUID ?? ""
        let isWithinLastMessage = chatMessage.isWithinMessage(lastMessage)
        let isWithinNextMessage = chatMessage.isWithinMessage(nextMessage)
        VStack {
            if !ownMessage && ((isWithinNextMessage && !isWithinLastMessage) || (!isWithinNextMessage && !isWithinLastMessage)) {
                HStack {
                    Spacer().frame(width: 55)
                    Text(chatMessage.userDTO?.userFullName ?? "")
                        .font(.custom("Montserrat-Light", size: 12))
                    Spacer()
                }

            }
            
            HStack{
                Spacer().frame(width: 8)
                if ownMessage { Spacer() }
                
                if !ownMessage {
                    if (isWithinNextMessage && !isWithinLastMessage) || (!isWithinNextMessage && !isWithinLastMessage) {
                        AsyncImage(url: chatMessage.userDTO?.userProfileImageUrl ?? "")
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .frame(width: 45, height: 45)
                    } else {
                        Spacer().frame(width: isWithinLastMessage ? 50 : 45)
                    }
                    
                }
                Text(chatMessage.messageContent ?? "")
                    .padding()
                    .background(msgBG)
                    .clipShape(msgTail(mymsg: ownMessage, isWithinLastMessage: isWithinLastMessage, isWithinNextMessage: isWithinNextMessage))
                    .foregroundColor(.white)
                

                if !ownMessage { Spacer() }
                Spacer().frame(width: 8)
            }
        }
        .padding(.top, isWithinLastMessage ? 3 : 10)
        .padding(.bottom, isWithinNextMessage ? 3 : 10)
    }
    
    var msgBG: some View {
        let ownMessage = chatMessage.userUUID == GaryPortal.shared.currentUser?.userUUID ?? ""
        if ownMessage {
            return AnyView(Color(UIColor(hexString: "#323232")))
        } else {
            return AnyView(LinearGradient(gradient: otherMsgGradient, startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }
}

struct msgTail : Shape {
    
    var mymsg : Bool
    var isWithinLastMessage: Bool
    var isWithinNextMessage: Bool
    
    let myMessageCorners: UIRectCorner = [.topLeft, .topRight, .bottomLeft]
    let otherMessageCorners: UIRectCorner = [.topLeft, .topRight, .bottomRight]
    
    func path(in rect: CGRect) -> Path {
        var cornersToRound: UIRectCorner = []
        if isWithinLastMessage {
            cornersToRound = [.allCorners]
        } else {
            cornersToRound = mymsg ? myMessageCorners : otherMessageCorners
        }
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: cornersToRound, cornerRadii: CGSize(width: 25, height: 25))
        return Path(path.cgPath)
    }
}

struct ChatListItem: View {
    
    @State var chat: Chat
    
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
                    Spacer()
                    
                    // TODO: unread logic
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

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRootView()
    }
}
