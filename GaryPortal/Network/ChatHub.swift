//
//  ChatHub.swift
//  GaryPortal
//
//  Created by Tom Knighton on 09/02/2021.
//

import Foundation
import SignalRClient

class ChatConnection: HubConnectionDelegate {
    
    private var connection: HubConnection
    private var timer: Timer?
    
    public init() {
        connection = HubConnectionBuilder(url: URL(string: GaryPortalConstants.APIChatHub)!)
            .withAutoReconnect()
            .withJSONHubProtocol()
            .withLogging(minLogLevel: .info)
            .build()
        
        connection.delegate = self
        
        connection.on(method: "KeepAlive") { _ in
        }
        
        connection.on(method: "MessageReceived", callback: { (chatUUID: String, senderUUID: String, messageUUID: String) in
            self.messageReceived(chatUUID: chatUUID, senderUUID: senderUUID, messageUUID: messageUUID)
        })
        
        connection.on(method: "RemoveMessage") { (chatUUID: String, messageUUID: String) in
            self.messageDeleted(chatUUID: chatUUID, messageUUID: messageUUID)
        }
        
        connection.on(method: "NewChatName") { (chatUUID: String, newChatName: String) in
            self.chatNameChanged(chatUUID: chatUUID, newName: newChatName)
        }
        
        connection.on(method: "NewChatUser") { (chatUUID: String, newChatMember: ChatMember) in
            self.chatMemberAdded(chatUUID: chatUUID, member: newChatMember)
        }
        
        connection.start()
    }
    
    func connectionDidOpen(hubConnection: HubConnection) {
        self.stopKeepAlive()
        self.subscribeToChats()
        self.keepAliveInternal()
    }
    
    func connectionDidFailToOpen(error: Error) {
    }
    
    func connectionDidClose(error: Error?) {
    }
    
    func connectionDidReconnect() {
        self.stopKeepAlive()
        self.subscribeToChats()
        self.keepAliveInternal()
    }
    
    //MARK: - Methods
    
    func subscribeToChats() {
        ChatService.getChats(for: GaryPortal.shared.currentUser?.userUUID ?? "") { (chats, error) in
            if error == nil {
                for chat in chats ?? [] {
                    self.connection.invoke(method: "SubscribeToGroup", chat.chatUUID) { error in
                        if error != nil {
                            print(error?.localizedDescription ?? "")
                        }
                    }
                }
            }
        }
    }
    
    func sendMessage(_ messageUUID: String, to chatUUID: String, from userUUID: String) {
        self.connection.invoke(method: "SendMessage", userUUID, chatUUID, messageUUID) { error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            }
        }

    }
    
    func deleteMessage(_ messageUUID: String, to chatUUID: String) {
        self.connection.invoke(method: "DeleteMessage", chatUUID, messageUUID) { error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    func editChatName(_ chatUUID: String, to newChatName: String) {
        self.connection.invoke(method: "EditChatName", chatUUID, newChatName) { error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    func addUserToChat(_ member: ChatMember, to chatUUID: String) {
        self.connection.invoke(method: "AddedUserToChat", chatUUID, member) { error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    //MARK: - Handlers
    
    func messageReceived(chatUUID: String, senderUUID: String, messageUUID: String) {
        do {
            let dataDict : [String: Any] = ["chatUUID": chatUUID, "userUUID" : senderUUID, "messageUUID": messageUUID]
            NotificationCenter.default.post(Notification(name: .newChatMessage, object: self, userInfo: dataDict))
        }
    }
    
    func messageDeleted(chatUUID: String, messageUUID: String) {
        do {
            let dataDict: [String: Any] = ["chatUUID": chatUUID, "messageUUID": messageUUID]
            NotificationCenter.default.post(Notification(name: .deleteChatMessage, object: self, userInfo: dataDict))
        }
    }
    
    func chatNameChanged(chatUUID: String, newName: String) {
        do {
            let dataDict: [String: Any] = ["chatUUID": chatUUID, "newName": newName]
            NotificationCenter.default.post(Notification(name: .chatNameChanged, object: self, userInfo: dataDict))
        }
    }
    
    func chatMemberAdded(chatUUID: String, member: ChatMember) {
        do {
            let dataDict: [String: Any] = ["chatUUID": chatUUID, "chatMember": member]
            NotificationCenter.default.post(Notification(name: .newChatMember, object: self, userInfo: dataDict))
        }
    }
    
    //MARK: - Keep Alive
    func keepAliveInternal() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block: { _ in
            self.connection.send(method: "KeepAlive")
        })
    }
    
    func stopKeepAlive() {
        self.timer?.invalidate()
    }
}
