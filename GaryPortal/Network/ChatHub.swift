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
            print("got")
        }
        
        connection.on(method: "MessageReceived", callback: { (chatUUID: String, senderUUID: String, messageUUID: String) in
            self.messageReceived(chatUUID: chatUUID, senderUUID: senderUUID, messageUUID: messageUUID)
        })
        
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
    
    func messageReceived(chatUUID: String, senderUUID: String, messageUUID: String) {
        do {
            let dataDict : [String: Any] = ["chatUUID": chatUUID, "userUUID" : senderUUID, "messageUUID": messageUUID]
            NotificationCenter.default.post(Notification(name: .newChatMessage, object: self, userInfo: dataDict))
        }
    }
    
    func keepAliveInternal() {
        print("register")
        self.timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block: { _ in
            self.connection.send(method: "KeepAlive")
        })
    }
    
    func stopKeepAlive() {
        self.timer?.invalidate()
    }
}
