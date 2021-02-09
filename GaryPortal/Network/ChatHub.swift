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
    
    public init() {
        connection = HubConnectionBuilder(url: URL(string: GaryPortalConstants.APIChatHub)!)
            .withAutoReconnect()
            .withJSONHubProtocol()
            .withLogging(minLogLevel: .info)
            .build()
        
        connection.delegate = self
        
        connection.on(method: "MessageReceived", callback: { (chatUUID: String, senderUUID: String, messageUUID: String) in
            print("msg receives")
            self.messageReceived(chatUUID: chatUUID, senderUUID: senderUUID, messageUUID: messageUUID)
        })
        
        connection.start()
    }
    
    func connectionDidOpen(hubConnection: HubConnection) {
        self.subscribeToChats()
    }
    
    func connectionDidFailToOpen(error: Error) {
        print("failed")
    }
    
    func connectionDidClose(error: Error?) {
        print("closed")
    }
    
    func connectionDidReconnect() {
        print("reconnected")
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
    
    
}
