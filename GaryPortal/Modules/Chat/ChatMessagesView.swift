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
    @State var textMessage: String = ""
    @State var paginate = false
    @State var showPaginate = true
    
    var body: some View {
        VStack {
            ScrollViewReader { reader in
                GPReverseList(self.datasource.messages, hasReachedTop: $paginate, canShowPaginator: $showPaginate) { message in
                    VStack {
                        let index = datasource.messages.firstIndex(where: { $0.chatMessageUUID == message.chatMessageUUID })
                        let lastMessage = index == 0 ? nil : self.datasource.messages[(index ?? 0) - 1]
                        let nextMessage = index == datasource.messages.count - 1 ? nil : self.datasource.messages[(index ?? 0) + 1]
                        ChatMessageView(chatMessage: message, nextMessage: nextMessage, lastMessage: lastMessage)
                            .id(message.chatMessageUUID)
                            
                    }
                }
                .onChange(of: self.datasource.lastMessageUUID) { newValue in
                    reader.scrollTo(newValue)
                }
                .onChange(of: self.datasource.canLoadMore) { newValue in
                    self.showPaginate = newValue
                }
            }
            
            if (self.chat.chatIsProtected == true && GaryPortal.shared.currentUser?.userIsAdmin == true) || self.chat.chatIsProtected == false {
                ChatMessageBarView(content: $textMessage) { text, hasMedia, imageURL, videoURL, stickerURL in
                    self.sendMessage(text: text, hasMedia: hasMedia, imageURL: imageURL, videoURL: videoURL, stickerURL: stickerURL)
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
        .onChange(of: paginate) { newValue in
            if newValue {
                self.datasource.loadMoreContent()
            }
        }
        .navigationTitle(self.datasource.chatName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ChatMemberList(chatUUID: self.chat.chatUUID ?? "", users: self.datasource.chat?.chatMembers ?? [])) {
                    Image(systemName: self.chat.getListImageName())
                }
            }
        }
        .onAppear {
            self.datasource.setup(for: chat)
            self.datasource.loadMoreContentIfNeeded(currentMessage: nil)
            ChatService.markChatAsRead(for: GaryPortal.shared.currentUser?.userUUID ?? "", chatUUID: self.chat.chatUUID ?? "")
            self.chat.markViewAsRead(for: GaryPortal.shared.currentUser?.userUUID ?? "")
        }
        
    }
    
    func sendMessage(text: String, hasMedia: Bool, imageURL: String?, videoURL: String?, stickerURL: String?) {

        if hasMedia {
            if let imageURL = imageURL {
                ChatService.uploadAttachment(to: self.chat.chatUUID ?? "", photoURL: imageURL) { (url, error) in
                    if let url = url {
                        let assetMessage = ChatMessage(chatMessageUUID: "", chatUUID: self.chat.chatUUID ?? "", userUUID: GaryPortal.shared.currentUser?.userUUID ?? "", messageContent: url, messageCreatedAt: Date(), messageHasBeenEdited: false, messageTypeId: 2, messageIsDeleted: false, user: nil, userDTO: nil, chatMessageType: nil, replyingToDTO: nil)
                        self.datasource.postNewMessage(message: assetMessage)
                        self.datasource.postNotification(for: "sent an image")
                    }
                }
            }
            if let videoURL = videoURL {
                ChatService.uploadAttachment(to: self.chat.chatUUID ?? "", videoURL: videoURL) { (url, error) in
                    if let url = url {
                        let assetMessage = ChatMessage(chatMessageUUID: "", chatUUID: self.chat.chatUUID ?? "", userUUID: GaryPortal.shared.currentUser?.userUUID ?? "", messageContent: url, messageCreatedAt: Date(), messageHasBeenEdited: false, messageTypeId: 3, messageIsDeleted: false, user: nil, userDTO: nil, chatMessageType: nil, replyingToDTO: nil)
                        self.datasource.postNewMessage(message: assetMessage)
                        self.datasource.postNotification(for: "sent a video")
                    }
                }
            }
        }

        if !text.isEmptyOrWhitespace() || stickerURL != nil {
            var message = ChatMessage(chatMessageUUID: "", chatUUID: self.chat.chatUUID ?? "", userUUID: GaryPortal.shared.currentUser?.userUUID ?? "", messageContent: self.textMessage.trim(), messageCreatedAt: Date(), messageHasBeenEdited: false, messageTypeId: 1, messageIsDeleted: false, user: nil, userDTO: nil, chatMessageType: nil, replyingToDTO: nil)

            if hasMedia, let stickerURL = stickerURL {
                message = ChatMessage(chatMessageUUID: "", chatUUID: self.chat.chatUUID ?? "", userUUID: GaryPortal.shared.currentUser?.userUUID ?? "", messageContent: stickerURL, messageCreatedAt: Date(), messageHasBeenEdited: false, messageTypeId: 8, messageIsDeleted: false, user: nil, userDTO: nil, chatMessageType: nil, replyingToDTO: nil)
            }

            self.datasource.postNewMessage(message: message)
            self.datasource.postNotification(for: message.messageTypeId == 8 ? "sent a sticker" : message.messageContent ?? "")

            if text.first == "?" {
                ChatService.getBotMessageResponse(for: text) { (response, error) in
                    if let response = response {
                        let message = ChatMessage(chatMessageUUID: "", chatUUID: self.chat.chatUUID ?? "", userUUID: GaryPortal.shared.currentUser?.userUUID ?? "", messageContent: response, messageCreatedAt: Date() + 1.seconds, messageHasBeenEdited: false, messageTypeId: 5, messageIsDeleted: false, user: nil, userDTO: nil, chatMessageType: nil, replyingToDTO: nil)
                        self.datasource.postNewMessage(message: message)
                    }
                }
            }
        }
        self.textMessage = ""
    }
    
}


