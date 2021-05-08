//
//  ChatViewModels.swift
//  GaryPortal
//
//  Created by Tom Knighton on 07/05/2021.
//

import Foundation
import Combine

class ChatListViewModel: ObservableObject {
    
    static let userDTO = UserDTO(userUUID: "1", userFullName: "Tom Knighton", userProfileImageUrl: "https://cdn.tomk.online/GaryPortal/AppLogo.png", userIsAdmin: true, userIsStaff: true)
    static let textMessageType = ChatMessageType(chatMessageTypeId: 1, chatMessageTypeName: "Text", isProtected: false)
    static let imageMessageType = ChatMessageType(chatMessageTypeId: 2, chatMessageTypeName: "Text", isProtected: false)
    static let videoMessageType = ChatMessageType(chatMessageTypeId: 3, chatMessageTypeName: "Text", isProtected: false)
    static var messages: [ChatMessage] = [
        ChatMessage(chatMessageUUID: "1", chatUUID: "1", userUUID: "1", messageContent: "Hello world! https://tomk.online i am a super long message!!!!! HEre's some more information abouyt me: ", messageCreatedAt: Date(), messageHasBeenEdited: false, messageTypeId: 1, messageIsDeleted: false, user: nil, userDTO: userDTO, chatMessageType: textMessageType),
        ChatMessage(chatMessageUUID: "2", chatUUID: "1", userUUID: "1", messageContent: "https://cdn.tomk.online/GaryPortal/AppLogo.png", messageCreatedAt: Date(), messageHasBeenEdited: false, messageTypeId: 2, messageIsDeleted: false, user: nil, userDTO: userDTO, chatMessageType: imageMessageType),
    ]
    @Published var chats: [Chat] = [
        Chat(chatUUID: "1", chatName: "CHat 1", chatIsProtected: false, chatIsPublic: false, chatIsDeleted: false, chatCreatedAt: Date(), chatMembers: [], chatMessages: [], lastChatMessage: messages[0])
    ]
    
    private var cancellableBag = Set<AnyCancellable>()
    
    
    init() {
        NotificationCenter.default.publisher(for: .newChatMessage)
            .sink { [weak self] notification in
                self?.onNewChatMessage(notification)
            }
            .store(in: &cancellableBag)
    }
    
    
    func loadChats(for userUUID: String) {
        ChatService.getChats(for: userUUID) { [weak self] chats, error  in
            DispatchQueue.main.async {
                if let chats = chats {
                    self?.chats = chats
                }
            }
        }
    }
    
    private func sortChats() {
        self.chats.sort { a, b in
            a.lastChatMessage?.messageCreatedAt ?? a.chatCreatedAt ?? Date() > b.lastChatMessage?.messageCreatedAt ?? b.chatCreatedAt ?? Date()
        }
    }
    
    private func onNewChatMessage(_ notification: NotificationCenter.Publisher.Output) {
        guard let messageUUID = notification.userInfo?["messageUUID"] as? String, let chatUUID = notification.userInfo?["chatUUID"] as? String else {
            return
        }
        guard var chat = self.chats.first(where: { $0.chatUUID == chatUUID}) else { return }
        
        ChatService.getChatMessage(by: messageUUID) { [weak self] message, error in
            if let message = message {
                DispatchQueue.main.async {
                    chat.lastChatMessage = message
                    self?.sortChats()
                }
            }
        }
    }
}
