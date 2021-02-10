//
//  ChatViewModels.swift
//  GaryPortal
//
//  Created by Tom Knighton on 10/02/2021.
//

import Foundation
import UIKit

class ChatListDataSource: ObservableObject {
    @Published var chats = [Chat]()
    
    
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(onNewMessage(_:)), name: .newChatMessage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onChatNameChanged(_:)), name: .chatNameChanged, object: nil)
        self.loadChats()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .newChatMessage, object: nil)
        NotificationCenter.default.removeObserver(self, name: .chatNameChanged, object: nil)
    }
    
    func loadChats() {
        ChatService.getChats(for: GaryPortal.shared.currentUser?.userUUID ?? "") { (newChats, error) in
            DispatchQueue.main.async {
                self.chats = newChats ?? []
            }
        }
    }
    
    func changeChatName(chat: Chat, newName: String) {
        ChatService.editChatName(chat, newName: newName) { (newChat, error) in
            if error == nil, let newChat = newChat {
                DispatchQueue.main.async {
                    guard let index = self.chats.firstIndex(where: { $0.chatUUID == newChat.chatUUID }) else { return }
                    self.chats[index] = newChat
                }
            }
        }
    }
    
    @objc
    func refresh(_ sender: UIRefreshControl) {
        loadChats()
        sender.endRefreshing()
    }
    
    @objc
    func onNewMessage(_ notification: NSNotification) {
        if let messageUUID = notification.userInfo?["messageUUID"] as? String, let chatUUID = notification.userInfo?["chatUUID"] as? String {
            let index = self.chats.firstIndex(where: { $0.chatUUID == chatUUID }) ?? -1
            guard index != -1 else { return }
            
            ChatService.getChatMessage(by: messageUUID) { (message, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        var old = self.chats[index]
                        old.lastChatMessage = message
                        self.chats[index] = old
                        
                        self.chats.sort(by: { $0.lastChatMessage?.messageCreatedAt ?? Date() > $1.lastChatMessage?.messageCreatedAt ?? Date()})
                    }
                }
            }
        }
    }
    
    @objc
    func onChatNameChanged(_ notification: NSNotification) {
        if let chatUUID = notification.userInfo?["chatUUID"] as? String, let newName = notification.userInfo?["newName"] as? String {
            let index = self.chats.firstIndex(where: { $0.chatUUID == chatUUID }) ?? -1
            guard index != -1 else { return }
            
            DispatchQueue.main.async {
                self.chats[index].chatName = newName
            }
        }
    }
}


class ChatMessagesDataSource: ObservableObject {
    @Published var chatName = ""
    @Published var messages = [ChatMessage]()
    @Published var isLoadingPage = false
    @Published var canLoadMore = true
    @Published var lastMessageUUID = ""
    @Published var hasLoadedFirst = false
    
    var shouldRespondToNewMessages = false
    var chat: Chat?
    private var lastDateFrom = Date()
    
    func setup(for chat: Chat) {
        self.chat = chat
        self.chatName = chat.getTitleToDisplay(for: GaryPortal.shared.currentUser?.userUUID ?? "")
        NotificationCenter.default.addObserver(self, selector: #selector(onNewMessage(_:)), name: .newChatMessage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDeleteMessage(_:)), name: .deleteChatMessage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onChatNameChanged(_:)), name: .chatNameChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .newChatMessage, object: nil)
        NotificationCenter.default.removeObserver(self, name: .chatNameChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .chatNameChanged, object: nil)
    }
    
    func loadMoreContentIfNeeded(currentMessage message: ChatMessage?) {
        
        guard hasLoadedFirst else { return }
        
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
        ChatService.getChatMessages(for: self.chat?.chatUUID ?? "", startingFrom: lastDateFrom, limit: 20) { (newMessages, error) in
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
                    
                    if !self.hasLoadedFirst { self.hasLoadedFirst = true }
                }
                
            }
        }
    }
    
    func postNewMessage(message: ChatMessage) {
        ChatService.postNewMessage(message, to: self.chat?.chatUUID ?? "") { (newMessage, error) in
            guard let newMessage = newMessage else { return }
            
            DispatchQueue.main.async {
                self.messages.append(newMessage)
                self.lastMessageUUID = newMessage.chatMessageUUID ?? ""
                GaryPortal.shared.chatConnection?.sendMessage(newMessage.chatMessageUUID ?? "", to: newMessage.chatUUID ?? "", from: newMessage.userUUID ?? "")
            }
        }
    }
    
    func deleteMessage(messageUUID: String) {
        ChatService.markMessageAsDeleted(messageUUID: messageUUID)
        self.messages.removeAll(where: { $0.chatMessageUUID == messageUUID })
    }
    
    @objc
    func onNewMessage(_ notification: NSNotification) {
        guard shouldRespondToNewMessages else { return }
        
        if let messageUUID = notification.userInfo?["messageUUID"] as? String, let chatUUID = notification.userInfo?["chatUUID"] as? String {
            
            guard chatUUID == self.chat?.chatUUID else { return }
            
            ChatService.getChatMessage(by: messageUUID) { (message, error) in
                if let message = message {
                    DispatchQueue.main.async {
                        if !self.messages.contains(where: { $0.chatMessageUUID == message.chatMessageUUID }) {
                            self.messages.append(message)
                            self.lastMessageUUID = message.chatMessageUUID ?? ""
                        }
                    }
                }
            }
        }
    }
    
    @objc
    func onDeleteMessage(_ notification: NSNotification) {
        guard shouldRespondToNewMessages else { return }
        
        if let messageUUID = notification.userInfo?["messageUUID"] as? String {
            self.messages.removeAll(where: { $0.chatMessageUUID == messageUUID })
        }
    }
    
    @objc
    func onChatNameChanged(_ notification: NSNotification) {
        guard shouldRespondToNewMessages else { return }
        if let chatUUID = notification.userInfo?["chatUUID"] as? String, let newName = notification.userInfo?["newName"] as? String {
            guard self.chat?.chatUUID == chatUUID else { return }
            DispatchQueue.main.async {
                self.chat?.chatName = newName
                self.chatName = self.chat?.getTitleToDisplay(for: GaryPortal.shared.currentUser?.userUUID ?? "") ?? ""
            }
        }
    }
}
