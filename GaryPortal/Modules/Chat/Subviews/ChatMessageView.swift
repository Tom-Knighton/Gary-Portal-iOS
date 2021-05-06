//
//  ChatMessageView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 06/05/2021.
//

import SwiftUI
import AVKit

extension Data: Identifiable {
    public var id: String { return UUID().uuidString }
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
    @State var viewingImageURL: String?
    
    var body: some View {
        let isWithinLastMessage = lastMessage?.isWithinMessage(chatMessage) ?? false
        let isWithinNextMessage = chatMessage.isWithinMessage(nextMessage)
        
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
                    
                    realMessageContent()
                }
               
            }
        }
        .padding(.top, isWithinLastMessage ? 3 : 10)
        .padding(.bottom, isWithinNextMessage ? 3 : 10)
        .alert(isPresented: $isAlertShowing, content: {
            Alert(title: Text(self.alertContent[0]), message: Text(self.alertContent[1]), dismissButton: .default(Text("Ok")))
        })
        .fullScreenCover(item: self.$viewingImageURL) { url in
            FullScreenAsyncImageView(url: url)
        }
    }
    
    @ViewBuilder
    func realMessageContent() -> some View {
        let ownMessage = chatMessage.userUUID == GaryPortal.shared.currentUser?.userUUID ?? ""
        let isWithinLastMessage = lastMessage?.isWithinMessage(chatMessage) ?? false
        let isWithinNextMessage = chatMessage.isWithinMessage(nextMessage)
        let shouldDisplayDate = chatMessage.shouldDisplayDate(from: lastMessage)
       
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
                .if(chatMessage.isStickerMessage() == false) {
                    $0.background(messageBackground())
                }
                .if(chatMessage.isStickerMessage() == false) {
                    $0.clipShape(msgTail(mymsg: ownMessage, isWithinLastMessage: isWithinLastMessage))
                }
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
                    
                    if self.chatMessage.messageTypeId == 2 {
                        Button(action: { self.viewImageFullScreen(self.chatMessage.messageContent ?? "") }, label: {
                            Text("View Image Full Screen")
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                        })
                    }
                    
                    if self.chatMessage.isMediaMessage() {
                        Button(action: { self.downloadContent() }, label: {
                            Text("Download Media")
                            Image(systemName: "square.and.arrow.down")
                        })
                    }

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
                .pinchToZoom()
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
        case 8:
            AsyncImage(url: self.chatMessage.messageContent ?? "")
                .aspectRatio(contentMode: .fit)
                .pinchToZoom()
                .frame(width: 150, height: 150)
            
        default:
            Text(self.chatMessage.messageContent ?? "")
                .padding()
        }
    }
    
    func goToProfile() {
        self.viewingUUID = self.chatMessage.userUUID ?? ""
        let profileView = UIHostingController(rootView: ProfileView(uuid: $viewingUUID))
        UIApplication.topViewController()?.present(profileView, animated: true, completion: nil)
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
        let safariView = UIHostingController(rootView: SafariView(url: GaryPortalConstants.URLs.DinoGameURL))
        UIApplication.topViewController()?.present(safariView, animated: true, completion: nil)
    }
    
    func viewImageFullScreen(_ url: String) {
//        let imageView = UIHostingController(rootView: FullScreenAsyncImageView(url: url))
//        UIApplication.topViewController()?.present(imageView, animated: true, completion: nil)
        self.viewingImageURL = url
    }
    
    func downloadContent() {
        getDataFromMedia { (data) in
            DispatchQueue.main.async {
                if let data = data {
                    if self.chatMessage.messageTypeId == 2, let image = UIImage(data: data) {
                        let av = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                        av.modalPresentationStyle = .pageSheet
                        UIApplication.topViewController()?.present(av, animated: true, completion: nil)
                    } else if self.chatMessage.messageTypeId == 3 {
                        DispatchQueue.global(qos: .background).async {
                            let filePath = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4").absoluteURL
                            DispatchQueue.main.async {
                                do {
                                    try data.write(to: filePath, options: .atomic)
                                    let av = UIActivityViewController(activityItems: [URL(fileURLWithPath: filePath.absoluteString)], applicationActivities: nil)
                                    av.excludedActivityTypes = [.saveToCameraRoll]
                                    UIApplication.topViewController()?.present(av, animated: true, completion: nil)
                                } catch {
                                    let alert = UIAlertController(title: "Error", message: "An error occurred sharing this video", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                    UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getDataFromMedia(completion: @escaping((Data?) -> Void)) {
        guard (self.chatMessage.messageTypeId ?? 0) >= 2 && (self.chatMessage.messageTypeId ?? 0) <= 4,
              let url = URL(string: self.chatMessage.messageContent ?? "") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data {
                completion(data)
            } else {
                completion(nil)
            }
        }.resume()
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
