//
//  ChatViewModels.swift
//  GaryPortal
//
//  Created by Tom Knighton on 07/05/2021.
//

import Foundation
import Combine

struct ChatMessageDTO {
    let messageUUID: String
    let messageRawContent: String
    let messageSender: UserDTO
    let messageSentAt: Date
    let messageTypeId: Int
    
    init(from chatMessage: ChatMessage) {
        self.messageUUID = chatMessage.chatMessageUUID ?? ""
        self.messageRawContent = chatMessage.messageContent ?? ""
        self.messageSentAt = chatMessage.messageCreatedAt ?? Date()
        self.messageTypeId = chatMessage.messageTypeId ?? 1
        self.messageSender = chatMessage.userDTO ?? UserDTO(userUUID: "", userFullName: "Deleted User", userProfileImageUrl: "https://cdn.tomk.online/GaryPortal/AppLogo.png", userIsAdmin: false, userIsStaff: false)
    }
}

class ChatListViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var hasLoaded: Bool = false
    
    private var cancellableBag = Set<AnyCancellable>()
    
    
    init() {
        NotificationCenter.default.publisher(for: .newChatMessage)
            .sink { [weak self] notification in
                self?.onNewChatMessage(notification)
            }
            .store(in: &cancellableBag)
    }
    
    //MARK: Callable
    func loadChats(for userUUID: String) {
        ChatService.getChats(for: userUUID) { [weak self] chats, error  in
            DispatchQueue.main.async {
                if let chats = chats {
                    self?.chats = chats
                    self?.hasLoaded = true
                }
            }
        }
    }
    
    func addNewChat(_ chat: Chat) {
        DispatchQueue.main.async {
            self.chats.insert(chat, at: 0)
            self.sortChats()
        }
    }
    
    func doesChatWithUsersExist(uuids: [String]) -> Bool {
        let uuids = uuids.sorted()
        return self.chats.contains { (chat) -> Bool in
            let existing = chat.chatMembers?.compactMap { $0.userUUID }.sorted() ?? []
            return existing.count == uuids.count && existing == uuids
        }
    }
    
    //MARK: Helper methods:
    private func sortChats() {
        self.chats.sort { a, b in
            a.lastChatMessage?.messageCreatedAt ?? a.chatCreatedAt ?? Date() > b.lastChatMessage?.messageCreatedAt ?? b.chatCreatedAt ?? Date()
        }
    }
    
    //MARK: Notifications:
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

class ChatMessagesViewModel: ObservableObject {
    
    @Published var lastMessageUUID = ""
    @Published var messages: [ChatMessage] = []
    var isLoadingPage = false
    var canLoadMore = true
    var chatUUID = ""
    var lastMessageDate = Date()
    
    func setup(for chatUUID: String) {
        self.chatUUID = chatUUID
        self.loadMoreContent()
    }
    
    func loadMoreContent() {
        guard !isLoadingPage, canLoadMore else {
            print("isloading page or cant load any more")
            return
        }
        
        self.isLoadingPage = true
        ChatService.getChatMessages(for: self.chatUUID, startingFrom: self.lastMessageDate, limit: 30) { newMessages, _ in
            guard let newMessages = newMessages else { print("no messages"); return }
            DispatchQueue.main.async {
                var messagesToInsert: [ChatMessage] = []
                newMessages.forEach { message in
                    if self.messages.contains(where: { $0.chatMessageUUID == message.chatMessageUUID }) == false {
                        messagesToInsert.append(message)
                    }
                }
                self.messages.append(contentsOf: messagesToInsert)
                self.lastMessageDate = newMessages.last?.messageCreatedAt ?? Date()
                self.lastMessageUUID = newMessages.first?.chatMessageUUID ?? ""
                print(newMessages.first?.messageContent ?? "")
                if newMessages.count < 30 {
                    self.canLoadMore = false
                }
                self.isLoadingPage = false
            }
        }
    }
}

struct ChatMessageBarResult {
    
    let isVideoURL: Bool
    let isImageURL: Bool
    let isStickerURL: Bool
    let rawText: String
}
