//
//  Chat.swift
//  GaryPortal
//
//  Created by Tom Knighton on 31/01/2021.
//

import Foundation
import SwiftUI
import SwiftDate

struct Chat: Codable {
    
    let chatUUID: String?
    let chatName: String?
    let chatIsProtected: Bool?
    let chatIsPublic: Bool?
    let chatIsDeleted: Bool?
    let chatCreatedAt: Date?
    
    var chatMembers: [ChatMember]?
    var chatMessages: [ChatMessage]?
    var lastChatMessage: ChatMessage?
    
    func getTitleToDisplay(for uuid: String) -> String {
        switch chatMembers?.count ?? 0 {
        case 2:
            return chatMembers?.first(where: { $0.userUUID != uuid })?.userDTO?.userFullName ?? ""
        case 3...:
            return self.chatName ?? "Group Chat"
        default:
            return "Lonely Chat :("
        }
    }
    
    func profilePicToDisplay(for uuid: String) -> some View {
        switch chatMembers?.count ?? 0 {
        case 2:
            let url = chatMembers?.first(where: { $0.userUUID != uuid})?.userDTO?.userProfileImageUrl ?? ""
            return AnyView(AsyncImage(url: url))
        case 3...:
            return AnyView(Image("GroupChatCover").resizable())
        default:
            return AnyView(Image("IconSprite"))
        }
    }
    
    func getLastMessageToDisplay(for uuid: String) -> String {
        guard let lastMessage = lastChatMessage else { return "" }
        let senderName = lastMessage.userDTO?.userUUID ?? "" == uuid ? "You" : lastMessage.userDTO?.userFullName ?? ""
        switch lastMessage.messageTypeId {
        case 1:
            return "\(senderName): \(lastMessage.messageContent ?? "")"
        case 2:
            return "\(senderName) sent some media"
        case 3, 4:
            return "Bot Message"
        case 5:
            return "-- ADMIN MESSAGE --"
        default:
            return "\(senderName): \(lastMessage.messageContent ?? "")"
        }
    }
    
    func hasUnreadMessages(for uuid: String) -> Bool {
        guard let lastMessage = lastChatMessage,
              let thisUser = self.chatMembers?.first(where: { $0.userUUID == uuid })
              else { return false }
        
        return thisUser.lastReadAt ?? Date() < lastMessage.messageCreatedAt ?? Date()
    }
    
    func markViewAsRead(for uuid: String) {
        guard var thisUser = self.chatMembers?.first(where: { $0.userUUID == uuid }) else { return }
       
        thisUser.lastReadAt = Date()
    }
}

struct ChatEditDetails: Codable {
    
    let chatUUID: String?
    let chatName: String?
    let chatIsProtected: Bool?
    let chatIsPublic: Bool?
    let chatIsDeleted: Bool?
}

struct ChatMember: Codable {
    
    let chatUUID: String?
    let userUUID: String?
    var isInChat: Bool?
    var lastReadAt: Date?
    
    let user: User?
    let userDTO: UserDTO?
}

struct ChatMessage: Codable, Identifiable {

    let chatMessageUUID: String?
    let chatUUID: String?
    let userUUID: String?
    let messageContent: String?
    let messageCreatedAt: Date?
    let messageHasBeenEdited: Bool?
    let messageTypeId: Int?
    let messageIsDeleted: Bool?
    
    let user: User?
    let userDTO: UserDTO?
    let chatMessageType: ChatMessageType?
    
    var id: String { get { return chatMessageUUID ?? "" }}
    
    func isWithinMessage(_ otherMessage: ChatMessage?) -> Bool {
        let isSameSender = self.userUUID == otherMessage?.userUUID ?? ""
        let isValidDateDistance = (self.messageCreatedAt?.minutesBetweenDates(otherMessage?.messageCreatedAt ?? Date()) ?? CGFloat(0)) <= CGFloat(7)
        return isSameSender && isValidDateDistance
    }
    
    func shouldDisplayDate(from lastMessage: ChatMessage?) -> Bool {
        let thisDate = self.messageCreatedAt
        let lastDate = lastMessage?.messageCreatedAt
        let overTwoHours = !(thisDate?.compareCloseTo(lastDate ?? Date(), precision: 2.hours.timeInterval) ?? false)
        let sameDay = thisDate?.day == lastDate?.day
        return !sameDay || overTwoHours
    }
}

struct ChatMessageType: Codable {
    
    let chatMessageTypeId: Int?
    let chatMessageTypeName: String?
    let isProtected: Bool?
}
