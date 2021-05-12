//
//  ChatViewModels.swift
//  GaryPortal
//
//  Created by Tom Knighton on 07/05/2021.
//

import Foundation
import Combine

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

struct ChatMessageBarResult {
    
    let isVideoURL: Bool
    let isImageURL: Bool
    let isStickerURL: Bool
    let rawText: String
}
