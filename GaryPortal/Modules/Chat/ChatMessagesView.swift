//
//  ChatMessagesView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 10/02/2021.
//

import SwiftUI


struct ChatView: View {
    
    @State var chat: Chat
    @StateObject var datasource: ChatMessagesDataSource = ChatMessagesDataSource()
    @Environment(\.presentationMode) var presentationMode
    @State var textMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
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
                            reader.scrollTo(datasource.messages.last?.chatMessageUUID, anchor: .bottom)
                            if self.datasource.messages.isEmpty {
                                self.datasource.loadMoreContent()
                            }
                            self.datasource.shouldRespondToNewMessages = true
                        }
                        .onDisappear {
                            self.datasource.shouldRespondToNewMessages = false
                            self.datasource.hasLoadedFirst = false
                        }
                        .onChange(of: datasource.lastMessageUUID) { (newValue) in
                            if datasource.hasLoadedFirst {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    reader.scrollTo(newValue, anchor: .bottom)
                                    self.datasource.lastMessageUUID = ""
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        self.datasource.isLoadingPage = false
                                    }
                                }
                            }
                            ChatService.markChatAsRead(for: GaryPortal.shared.currentUser?.userUUID ?? "", chatUUID: self.chat.chatUUID ?? "")
                            self.chat.markViewAsRead(for: GaryPortal.shared.currentUser?.userUUID ?? "")
                        }
                        .onChange(of: self.textMessage, perform: { value in
                            withAnimation(.easeInOut(duration: 0.5)) {
                                reader.scrollTo(self.datasource.messages.last?.chatMessageUUID, anchor: .bottom)
                            }
                        })
                    }
                }
                
                ChatMessageBarView(content: $textMessage) {
                    let message = ChatMessage(chatMessageUUID: "", chatUUID: self.chat.chatUUID ?? "", userUUID: GaryPortal.shared.currentUser?.userUUID ?? "", messageContent: self.textMessage, messageCreatedAt: Date(), messageHasBeenEdited: false, messageTypeId: 1, messageIsDeleted: false, user: nil, userDTO: nil, chatMessageType: nil)
                    self.datasource.postNewMessage(message: message)
                    self.textMessage = ""
                }
                    
            }
            .navigationTitle(chat.getTitleToDisplay(for: GaryPortal.shared.currentUser?.userUUID ?? ""))
            .navigationBarItems(leading:
                Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                   Image(systemName: "chevron.backward")
            })
        }
        .onAppear {
            self.datasource.setup(for: chat.chatUUID ?? "")
            self.datasource.loadMoreContentIfNeeded(currentMessage: nil)
            ChatService.markChatAsRead(for: GaryPortal.shared.currentUser?.userUUID ?? "", chatUUID: self.chat.chatUUID ?? "")
            self.chat.markViewAsRead(for: GaryPortal.shared.currentUser?.userUUID ?? "")
        }
    }
}

struct ChatMessageBarView: View {
    
    @Binding var text: String
    var onSendAction: () -> ()
    
    init(content: Binding<String>, _ onSend: @escaping () -> ()) {
        self.onSendAction = onSend
        _text = content
    }
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                
                TextEditor(text: $text)
                    .frame(maxHeight: 100)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(
                        ZStack {
                            if self.text.isEmpty {
                                HStack {
                                    Spacer().frame(width: 1)
                                    Text("Your message...")
                                        .foregroundColor(.gray)
                                        .disabled(true)
                                    Spacer()
                                }
                            }
                        }
                    )
                
                Button(action: {}) {
                    Image(systemName: "camera.fill")
                        .font(.body)
                }
                .foregroundColor(.gray)
                
            }
            .padding(.horizontal, 8)
            .background(Color("Section"))
            .cornerRadius(10)
            .shadow(radius: 3)
            
            if !text.isEmpty {
                withAnimation(.easeIn) {
                    Button(action: { self.onSendAction() }) {
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 15, height: 23)
                            .padding(13)
                            .shadow(radius: 3)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .clipShape(Circle())

                    }
                    .foregroundColor(.gray)
                }
               
            }
        }
        .transition(.slide)
        .animation(.easeInOut)
        .padding(.horizontal, 15)
        .padding(.bottom, 8)
        .background(Color.clear)
        .onAppear {
            UITextView.appearance().backgroundColor = .clear
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
        let isWithinLastMessage = lastMessage?.isWithinMessage(chatMessage) ?? false
        let isWithinNextMessage = chatMessage.isWithinMessage(nextMessage)
        let shouldDisplayDate = chatMessage.shouldDisplayDate(from: lastMessage)
        VStack {
            
            if shouldDisplayDate {
                HStack {
                    Spacer().frame(width: 8)
                    Text(chatMessage.messageCreatedAt?.niceDateAndTime() ?? "")
                    Spacer().frame(width: 8)
                }
            }
            
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
                    .clipShape(msgTail(mymsg: ownMessage, isWithinLastMessage: isWithinLastMessage))
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
