//
//  ChatMessagesView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 10/02/2021.
//

import SwiftUI
import AVKit
import SwiftDate

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
                        .animation(.spring())
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
                
                if (self.chat.chatIsProtected == true && GaryPortal.shared.currentUser?.userIsAdmin == true) || self.chat.chatIsProtected == false {
                    ChatMessageBarView(content: $textMessage) { text, hasMedia, imageURL, videoURL in
                        
                        if hasMedia {
                            if let imageURL = imageURL {
                                ChatService.uploadAttachment(to: self.chat.chatUUID ?? "", photoURL: imageURL) { (url, error) in
                                    if let url = url {
                                        let assetMessage = ChatMessage(chatMessageUUID: "", chatUUID: self.chat.chatUUID ?? "", userUUID: GaryPortal.shared.currentUser?.userUUID ?? "", messageContent: url, messageCreatedAt: Date(), messageHasBeenEdited: false, messageTypeId: 2, messageIsDeleted: false, user: nil, userDTO: nil, chatMessageType: nil)
                                        self.datasource.postNewMessage(message: assetMessage)
                                        self.datasource.postNotification(for: "posted an image")
                                    }
                                }
                            }
                            if let videoURL = videoURL {
                                ChatService.uploadAttachment(to: self.chat.chatUUID ?? "", videoURL: videoURL) { (url, error) in
                                    if let url = url {
                                        let assetMessage = ChatMessage(chatMessageUUID: "", chatUUID: self.chat.chatUUID ?? "", userUUID: GaryPortal.shared.currentUser?.userUUID ?? "", messageContent: url, messageCreatedAt: Date(), messageHasBeenEdited: false, messageTypeId: 3, messageIsDeleted: false, user: nil, userDTO: nil, chatMessageType: nil)
                                        self.datasource.postNewMessage(message: assetMessage)
                                        self.datasource.postNotification(for: "posted a video")
                                    }
                                }
                            }
                        }
                        
                        if !text.isEmptyOrWhitespace() {
                            
                            let message = ChatMessage(chatMessageUUID: "", chatUUID: self.chat.chatUUID ?? "", userUUID: GaryPortal.shared.currentUser?.userUUID ?? "", messageContent: self.textMessage.trim(), messageCreatedAt: Date(), messageHasBeenEdited: false, messageTypeId: 1, messageIsDeleted: false, user: nil, userDTO: nil, chatMessageType: nil)
                            self.datasource.postNewMessage(message: message)
                            self.datasource.postNotification(for: message.messageContent ?? "")

                            if text.first == "?" {
                                ChatService.getBotMessageResponse(for: text) { (response, error) in
                                    if let response = response {
                                        let message = ChatMessage(chatMessageUUID: "", chatUUID: self.chat.chatUUID ?? "", userUUID: GaryPortal.shared.currentUser?.userUUID ?? "", messageContent: response, messageCreatedAt: Date() + 1.seconds, messageHasBeenEdited: false, messageTypeId: 5, messageIsDeleted: false, user: nil, userDTO: nil, chatMessageType: nil)
                                        self.datasource.postNewMessage(message: message)
                                    }
                                }
                            }
                        }
                        self.textMessage = ""
                    }
                } else {
                    HStack {
                        Spacer().frame(width: 16)
                        HStack {
                            Spacer()
                            Text("You are unable to send mesages to this chat")
                                .fontWeight(.light)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        .padding(8)
                        .background(Color("Section"))
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        Spacer().frame(width: 16)

                    }
                    .padding(.bottom, 8)
                }
            }
            .navigationTitle(self.datasource.chatName)
            .navigationBarItems(
                leading:
                    Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                       Image(systemName: "chevron.backward")
                }, trailing:
                    HStack {
                        if self.chat.chatIsProtected == false {
                            NavigationLink(
                                destination: NavigationLazyView(ChatMemberList(chatUUID: self.chat.chatUUID ?? "", users: self.datasource.chat?.chatMembers ?? [])),
                                label: {
                                    Image(systemName: self.chat.getListImageName())
                                })
                        }
                    }
                    
            )
        }
        .onAppear {
            self.datasource.setup(for: chat)
            self.datasource.loadMoreContentIfNeeded(currentMessage: nil)
            ChatService.markChatAsRead(for: GaryPortal.shared.currentUser?.userUUID ?? "", chatUUID: self.chat.chatUUID ?? "")
            self.chat.markViewAsRead(for: GaryPortal.shared.currentUser?.userUUID ?? "")
        }
    }
    
}

struct ChatMessageBarView: View {
    
    @Binding var text: String
    
    var onSendAction: (_ text: String, _ hasMedia: Bool, _ imageURL: String?, _ videoURL: String?) -> ()
    
    @State var isShowingCamera = false
    
    @State var play = true
    
    @State var hasMedia = false
    @State var imageURL: String? = nil
    @State var videoURL: String? = nil
    
    var isCameraAllowed = true
    var placeHolderText = "Your message..."
    
    init(content: Binding<String>, _ onSend: @escaping (_ text: String, _ hasMedia: Bool, _ imageURL: String?, _ videoURL: String?) -> ()) {
        self.onSendAction = onSend
        _text = content
    }
    
    init(content: Binding<String>, isCameraAllowed: Bool, placeHolderText: String, _ onSend: @escaping (_ text: String, _ hasMedia: Bool, _ imageURL: String?, _ videoURL: String?) -> ()) {
        self.onSendAction = onSend
        self.isCameraAllowed = isCameraAllowed
        self.placeHolderText = placeHolderText
        _text = content
    }
    
    var body: some View {
        VStack {
            if self.hasMedia {
                HStack {
                    Spacer().frame(width: 16)
                    if self.imageURL != nil {
                        AsyncImage(url: self.imageURL ?? "")
                            .cornerRadius(10)
                            .frame(width: 80, height: 80)
                            .aspectRatio(contentMode: .fill)
                            .onTapGesture {
                                self.hasMedia = false
                                self.imageURL = nil
                            }
                    }
                    if self.videoURL != nil {
                        PlayerView(url: self.videoURL ?? "", play: $play)
                            .cornerRadius(10)
                            .frame(width: 80, height: 80)
                            .aspectRatio(contentMode: .fill)
                            .onTapGesture {
                                self.hasMedia = false
                                self.videoURL = nil
                            }
                    }
                   
                    Spacer()
                }
            }
            Spacer().frame(height: 8)
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
                                        Text(self.placeHolderText)
                                            .foregroundColor(.gray)
                                            .disabled(true)
                                        Spacer()
                                    }
                                }
                            }
                        )
                    if self.isCameraAllowed {
                        Button(action: { self.isShowingCamera = true }) {
                            Image(systemName: "camera.fill")
                                .font(.body)
                        }
                        .foregroundColor(.gray)
                    }
                    
                }
                .padding(.horizontal, 8)
                .background(Color("Section"))
                .cornerRadius(10)
                .shadow(radius: 3)
                
                if !text.trim().isEmptyOrWhitespace() || self.hasMedia {
                    withAnimation(.easeIn) {
                        Button(action: { self.onSendAction(self.text, self.hasMedia, self.imageURL, self.videoURL); self.hasMedia = false; self.imageURL = ""; self.videoURL = "" }) {
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
            .fullScreenCover(isPresented: $isShowingCamera, onDismiss: {}) {
                CameraView { (success, isVideo, urlToAsset) in
                    self.isShowingCamera = false
                    if success {
                        if isVideo {
                            self.videoURL = urlToAsset?.absoluteString ?? ""
                            self.hasMedia = true
                        } else {
                            self.imageURL = urlToAsset?.absoluteString ?? ""
                            self.hasMedia = true
                        }
                    }
                }
            }
            .onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
        }
       
        
    }
    
}

struct ChatMessageView: View {
    
    enum ActiveSheet: Identifiable {
        case none, dino, profile
        var id: ActiveSheet { self }
    }

    var chatMessage: ChatMessage
    var nextMessage: ChatMessage?
    var lastMessage: ChatMessage?
    
    let otherMsgGradient = Gradient(colors: [Color(UIColor(hexString: "#ad5389")), Color(UIColor(hexString: "#3c1053"))])
    var adminGradient = Gradient(colors: [Color(UIColor(hexString: "#ED213A")), Color(UIColor(hexString: "#93291E"))])

    @State var isAlertShowing = false
    @State var alertContent: [String] = []
    @State var isPlayingVideo = false
    
    @State var viewingUUID = ""
    @State var activeSheet: ActiveSheet?
    
    var body: some View {
        let ownMessage = chatMessage.userUUID == GaryPortal.shared.currentUser?.userUUID ?? ""
        let isWithinLastMessage = lastMessage?.isWithinMessage(chatMessage) ?? false
        let isWithinNextMessage = chatMessage.isWithinMessage(nextMessage)
        let shouldDisplayDate = chatMessage.shouldDisplayDate(from: lastMessage)
        VStack {
            if !chatMessage.isSenderBlocked() {
                
                if chatMessage.isBotMessage() {
                    Divider()
                    HStack {
                        Spacer()
                        Text("Bot Message:")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        messageContent(input: self.chatMessage.messageContent ?? "")
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color(UIColor(hexString: "#00b09b")), Color(UIColor(hexString: "#96c93d"))]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .cornerRadius(10)
                        Spacer()
                    }
                    .if(GaryPortal.shared.currentUser?.userIsStaff == true) {
                        $0.contextMenu(menuItems: {
                            Button("Delete Bot Message") { self.deleteMessage() }
                        })
                    }
                    Divider()
                } else {
                    
                    if chatMessage.isAdminMessage() {
                        Divider()
                        HStack {
                            Spacer()
                            Text("-- ADMIN ANNOUNCEMENT --")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    
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
                            if (isWithinNextMessage && !isWithinLastMessage) || (!isWithinNextMessage && !isWithinLastMessage) || lastMessage?.isBotMessage() == true {
                                AsyncImage(url: chatMessage.userDTO?.userProfileImageUrl ?? "")
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(Circle())
                                    .frame(width: 45, height: 45)
                            } else {
                                Spacer().frame(width: isWithinLastMessage ? 50 : 45)
                            }
                            
                        }

                        self.messageContent()
                            .background(messageBackground())
                            .clipShape(msgTail(mymsg: ownMessage, isWithinLastMessage: isWithinLastMessage))
                            .foregroundColor(.white)
                            .contextMenu(menuItems: {
                                if self.chatMessage.messageTypeId == 1 {
                                    Button(action: { UIPasteboard.general.string = chatMessage.messageContent ?? "" }, label: {
                                        Text("Copy Text")
                                        Image(systemName: "doc.on.doc")
                                    })
                                }
                                
                                Button(action: { self.loadDinoGame() }, label : {
                                    Text("🐸 Dinosaur Game 🐸")
                                })
                                if ownMessage {
                                    Button(action: { self.deleteMessage() }, label: {
                                        Text("Delete Message")
                                        Image(systemName: "trash")
                                    })
                                } else {
                                    Button(action: { self.goToProfile() }) {
                                        Text("View Profile")
                                    }
                                    
                                    Menu(content: {
                                        Text("Select Report Reason:")
                                        Divider()
                                        Button(action: { self.reportMessage(reason: "Breaks Gary Portal") }, label: {
                                            Text("Breaks Gary Portal")
                                        })
                                        Button(action: { self.reportMessage(reason: "Violates Policy") }, label: {
                                            Text("Violates Policy")
                                        })
                                        Button(action: { self.reportMessage(reason: "Is Offensive") }, label: {
                                            Text("Is Offensive")
                                        })
                                        Divider()
                                        Button(action: {}, label: {
                                            Text("Cancel")
                                        })
                                    },
                                    label: {
                                        Text("Report Message")
                                        Image(systemName: "exclamationmark.bubble")
                                    })
                                    
                                }
                            })

                        if !ownMessage { Spacer() }
                        Spacer().frame(width: 8)
                    }
                    if chatMessage.isAdminMessage() {
                        Divider()
                    }
                }
               
            }
        }
        .padding(.top, isWithinLastMessage ? 3 : 10)
        .padding(.bottom, isWithinNextMessage ? 3 : 10)
        .alert(isPresented: $isAlertShowing, content: {
            Alert(title: Text(self.alertContent[0]), message: Text(self.alertContent[1]), dismissButton: .default(Text("Ok")))
        })
        .sheet(item: $activeSheet) { item in
            if item == ActiveSheet.dino {
                SafariView(url: GaryPortalConstants.URLs.DinoGameURL)
            } else {
                ProfileView(uuid: self.$viewingUUID)
            }
        }
    }
    
    @ViewBuilder
    func messageBackground() -> some View {
        let ownMessage = chatMessage.userUUID == GaryPortal.shared.currentUser?.userUUID ?? ""
        let text = self.chatMessage.messageContent ?? ""
        if chatMessage.isAdminMessage() {
            LinearGradient(gradient: adminGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
        } else if ownMessage {
            if text.containsOnlyEmojis() && text.emojiCharacterCount() < 6 {
                EmptyView()
            } else {
                Color(UIColor(hexString: "#323232"))
            }
        } else {
            if text.containsOnlyEmojis() && text.emojiCharacterCount() < 6 {
                EmptyView()
            } else {
                LinearGradient(gradient: otherMsgGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
    }

    @ViewBuilder
    func messageContent(input: String = "") -> some View {
        switch self.chatMessage.messageTypeId {
        case 1:
            let text = self.chatMessage.messageContent ?? ""
            if text.containsOnlyEmojis() && text.emojiCharacterCount() < 6 {
                Text(text)
                    .padding()
                    .font(.system(size: 50))
            } else {
                Text(self.chatMessage.messageContent ?? "")
                    .padding()
            }
        case 2:
            AsyncImage(url: self.chatMessage.messageContent ?? "")
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: 250, maxHeight: 400)
        case 3:
            if let content = self.chatMessage.messageContent, let url = URL(string: content) {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(minWidth: 250, maxWidth: .infinity, minHeight: 250, maxHeight: .infinity)
                    .fixedSize(horizontal: true, vertical: true)
                    .cornerRadius(25)
                    .padding(.all, 8)
            }
        case 5, 6:
            if let _ = URL(string: input) {
                GIFView(gifUrl: input)
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 250, maxHeight: 400)
            } else {
                Text(input)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            
        default:
            Text(self.chatMessage.messageContent ?? "")
                .padding()
        }
    }
    
    func goToProfile() {
        self.viewingUUID = self.chatMessage.userUUID ?? ""
        self.activeSheet = .profile
    }
    
    func deleteMessage() {
        ChatService.markMessageAsDeleted(messageUUID: self.chatMessage.chatMessageUUID ?? "")
        GaryPortal.shared.chatConnection?.deleteMessage(self.chatMessage.chatMessageUUID ?? "", to: self.chatMessage.chatUUID ?? "")
    }
    
    func reportMessage(reason: String) {
        self.alertContent = [GaryPortalConstants.Messages.thankYou, GaryPortalConstants.Messages.messageReported]
        self.isAlertShowing = true
        ChatService.reportMessage(self.chatMessage.chatMessageUUID ?? "", from: GaryPortal.shared.currentUser?.userUUID ?? "", for: reason)
    }
    
    func loadDinoGame() {
        self.activeSheet = .dino
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
