//
//  ChatViewModels.swift
//  GaryPortal
//
//  Created by Tom Knighton on 07/05/2021.
//

import Foundation
import Combine

struct ChatMessageDTO: Codable, Hashable, Equatable {
    let messageUUID: String
    let messageRawContent: String
    let messageSender: UserDTO
    let messageSentAt: Date
    let messageTypeId: Int
    
    let previousSender: String?
    let previousDate: Date?
    let previousTypeId: Int?
    
    init(from chatMessage: ChatMessage, previousMessage: ChatMessageDTO? = nil) {
        self.messageUUID = chatMessage.chatMessageUUID ?? ""
        self.messageRawContent = chatMessage.messageContent ?? ""
        self.messageSentAt = chatMessage.messageCreatedAt ?? Date()
        self.messageTypeId = chatMessage.messageTypeId ?? 1
        self.messageSender = chatMessage.userDTO ?? UserDTO(userUUID: "", userFullName: "Deleted User", userProfileImageUrl: "https://cdn.tomk.online/GaryPortal/AppLogo.png", userIsAdmin: false, userIsStaff: false)
        
        if let previousMessage = previousMessage {
            self.previousSender = previousMessage.messageSender.userUUID ?? ""
            self.previousDate = previousMessage.messageSentAt
            self.previousTypeId = previousMessage.messageTypeId
        } else {
            self.previousSender = nil
            self.previousDate = nil
            self.previousTypeId = nil
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
        self.previousTypeId = nil
    }
    
    func isMessageWithinPrevious() -> Bool {
        guard let previousSender = self.previousSender,
              let previousDate = self.previousDate,
              self.messageTypeId != 5 && self.messageTypeId != 7,
              self.previousTypeId != 5 && self.previousTypeId != 7
              else { return false }
        
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
    @Published var newMessageUUID: String = ""
    @Published var messages: [ChatMessage] = []
    @Published var hasLoadedFirstMessages = false
    var isLoadingPage = false
    var canLoadMore = true
    var chatUUID = ""
    var lastMessageDate = Date()
    
    private var cancellableBag = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: .newChatMessage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.onReceiveChatMessage(notification)
            }
            .store(in: &cancellableBag)
    }
    
    func setup(for chatUUID: String) {
        self.chatUUID = chatUUID
        self.loadMoreContent()
    }
    
    //MARK: Callable
    func loadMoreContent() {
        guard !isLoadingPage, canLoadMore else {
            return
        }
        
        self.isLoadingPage = true
        ChatService.getChatMessages(for: self.chatUUID, startingFrom: self.lastMessageDate, limit: 30) { newMessages, _ in
            guard let newMessages = newMessages else { return }
            DispatchQueue.main.async {
                var messagesToInsert: [ChatMessage] = []
                newMessages.forEach { message in
                    if self.messages.contains(where: { $0.chatMessageUUID == message.chatMessageUUID }) == false {
                        messagesToInsert.insert(message, at: 0)
                    }
                }
                self.messages.insert(contentsOf: messagesToInsert, at: 0)
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
    
    //MARK: SEND MESSAGE
    func sendMessage(messageText: String, messageTypeId: Int) {
        let message = ChatMessage(chatMessageUUID: "", chatUUID: self.chatUUID, userUUID: GaryPortal.shared.currentUser?.userUUID ?? "", messageContent: messageText, messageCreatedAt: Date(), messageHasBeenEdited: false, messageTypeId: messageTypeId, messageIsDeleted: false, user: nil, userDTO: nil, chatMessageType: nil, replyingToDTO: nil)
        ChatService.postNewMessage(message, to: self.chatUUID) { newMessage, error in
            DispatchQueue.main.async {
                guard let newMessage = newMessage,
                      error == nil else {
                    GaryPortal.shared.showNotification(data: GPNotificationData(title: "Error", subtitle: "An error occurred sending this message", image: "xmark.octagon", imageColor: .red, onTap:{}))
                    return
                }
                GaryPortal.shared.chatConnection?.sendMessage(newMessage.chatMessageUUID ?? "", to: self.chatUUID, from: newMessage.userUUID ?? "")
                ChatService.postNotification(to: self.chatUUID, from: newMessage.userUUID ?? "", content: messageTypeId == 8 ? "sent a sticker" : messageTypeId == 1 ? "sent an image" : messageTypeId == 2 ? "sent a video" : newMessage.messageContent ?? "")
            }
        }
    }
    
    //MARK: OnReceive
    private func onReceiveChatMessage(_ notification: Notification) {
        guard let messageUUID = notification.userInfo?["messageUUID"] as? String else {
            return
        }
        
        ChatService.getChatMessage(by: messageUUID) { [weak self] message, error in
            if let message = message {
                DispatchQueue.main.async {
                    self?.messages.append(message)
                    self?.newMessageUUID = message.chatMessageUUID ?? ""
                }
            }
        }
    }
}

struct ChatMessageBarResult {
    
    let messageTypeId: Int
    let rawText: String
}
