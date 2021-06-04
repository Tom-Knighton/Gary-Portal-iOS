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
    
    let previousSender: String?
    let previousDate: Date?
    
    init(from chatMessage: ChatMessage, previousMessage: ChatMessageDTO? = nil) {
        self.messageUUID = chatMessage.chatMessageUUID ?? ""
        self.messageRawContent = chatMessage.messageContent ?? ""
        self.messageSentAt = chatMessage.messageCreatedAt ?? Date()
        self.messageTypeId = chatMessage.messageTypeId ?? 1
        self.messageSender = chatMessage.userDTO ?? UserDTO(userUUID: "", userFullName: "Deleted User", userProfileImageUrl: "https://cdn.tomk.online/GaryPortal/AppLogo.png", userIsAdmin: false, userIsStaff: false)
        
        if let previousMessage = previousMessage {
            self.previousSender = previousMessage.messageSender.userUUID ?? ""
            self.previousDate = previousMessage.messageSentAt
        } else {
            self.previousSender = nil
            self.previousDate = nil
        }
    }
    
    init?(from chatMessage: ChatMessage?) {
        guard let chatMessage = chatMessage else { return nil }
        
        self.messageUUID = chatMessage.chatMessageUUID ?? ""
        self.messageRawContent = chatMessage.messageContent ?? ""
        self.messageSentAt = chatMessage.messageCreatedAt ?? Date()
        self.messageTypeId = chatMessage.messageTypeId ?? 1
        self.messageSender = chatMessage.userDTO ?? UserDTO(userUUID: "", userFullName: "Deleted User", userProfileImageUrl: "https://cdn.tomk.online/GaryPortal/AppLogo.png", userIsAdmin: false, userIsStaff: false)
        self.previousSender = nil
        self.previousDate = nil
    }
    
    func isMessageWithinPrevious() -> Bool {
        guard let previousSender = self.previousSender, let previousDate = self.previousDate else { return false }
        
        return self.messageSender.userUUID ?? "" == previousSender && (Calendar.current.dateComponents([.minute], from: previousDate, to: self.messageSentAt).minute ?? 0) <= 7
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
    
    @Published var lastMessageUUID: String = ""
    @Published var messages: [ChatMessage] = []
    @Published var hasLoadedFirstMessages = false
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
                if newMessages.count < 30 {
                    self.canLoadMore = false
                }
                self.isLoadingPage = false
                self.hasLoadedFirstMessages = true
            }
        }
    }
    
    func getPreviousMessageInList(from messageUUID: String?) -> ChatMessageDTO? {
        let index = self.messages.firstIndex(where: { $0.chatMessageUUID == messageUUID })
        if let index = index, index < self.messages.count - 1, index != 0{
            return ChatMessageDTO(from: self.messages[index - 1])
        } else {
            return nil
        }
    }
}

struct ChatMessageBarResult {
    
    let isVideoURL: Bool
    let isImageURL: Bool
    let isStickerURL: Bool
    let rawText: String
}
