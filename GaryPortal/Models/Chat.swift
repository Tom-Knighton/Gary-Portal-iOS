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
    var chatName: String?
    let chatIsProtected: Bool?
    let chatIsPublic: Bool?
    let chatIsDeleted: Bool?
    let chatCreatedAt: Date?
    
    var chatMembers: [ChatMember]?
    var chatMessages: [ChatMessage]?
    var lastChatMessage: ChatMessage?
    
    func getTitleToDisplay(for uuid: String) -> String {
        if (chatMembers?.count ?? 0) >= 3 || chatName?.hasPrefix("GP$AG_") == false {
            return self.chatName ?? "Group Chat"
        } else if chatMembers?.count == 2 {
            return chatMembers?.first(where: { $0.userUUID != uuid })?.userDTO?.userFullName ?? ""
        } else {
            return "Lonely Chat :("
        }
    }
    
    func profilePicToDisplay(for uuid: String) -> some View {
        if self.chatIsProtected == true {
            return AnyView(GPAvatarView(imageUrls: ["https://cdn.tomk.online/GaryPortal/AppLogo.png"]))
        } else if (self.chatMembers?.count ?? 0) >= 2 {
            return AnyView(GPAvatarView(imageUrls: self.chatMembers?.filter({ $0.userUUID != uuid }).compactMap( { $0.userDTO?.userProfileImageUrl ?? "" }) ?? []))
        } else {
            return AnyView(GPAvatarView(imageUrls: ["https://cdn.tomk.online/GaryPortal/lonely.png"]))
        }
    }
    
    func getLastMessageToDisplay(for uuid: String) -> String {
        guard let lastMessage = lastChatMessage else { return "" }
        let senderName = lastMessage.userDTO?.userUUID ?? "" == uuid ? "You" : lastMessage.userDTO?.userFullName ?? ""
        switch lastMessage.messageTypeId {
        case 1:
            return "\(senderName): \(lastMessage.messageContent ?? "")"
        case 2:
            return "\(senderName) sent an image"
        case 3:
            return "\(senderName) sent a video"
        case 4:
            return "\(senderName) sent a file"
        case 5, 6:
            return "Bot Message"
        case 7:
            return "-- ADMIN MESSAGE --"
        case 8:
            return "\(senderName) sent a sticker"
        default:
            return "\(senderName): \(lastMessage.messageContent ?? "")"
        }
    }
    
    func canRenameChat() -> Bool {
        return self.chatIsProtected == false && ((self.chatMembers?.count ?? 0) >= 3 || self.chatName?.hasPrefix("GP$AG_") == false)
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
    
    func getListImageName() -> String {
        return (self.chatMembers?.count ?? 0) >= 3 ? "person.3" : self.chatMembers?.count == 2 ? "person.2" : "person"
    }
    
    func isDMAndBlocked() -> Bool {
        return self.chatMembers?.count == 2 && GaryPortal.shared.currentUser?.hasBlockedUUID(uuid: self.chatMembers?[1].userUUID ?? "") == true
    }
}

extension Chat: Identifiable {
    var id: String { self.chatUUID ?? "" }
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

struct ChatMessage: Codable, Identifiable, Equatable {
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.chatMessageUUID == rhs.chatMessageUUID
    }

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
        return isSameSender && isValidDateDistance && otherMessage?.isBotMessage() == false
    }
    
    func shouldDisplayDate(from lastMessage: ChatMessage?) -> Bool {
        let thisDate = self.messageCreatedAt
        let lastDate = lastMessage?.messageCreatedAt
        let overTwoHours = !(thisDate?.compareCloseTo(lastDate ?? Date(), precision: 2.hours.timeInterval) ?? false)
        let sameDay = thisDate?.day == lastDate?.day
        return !sameDay || overTwoHours
    }
    
    func isSenderBlocked() -> Bool {
        return GaryPortal.shared.currentUser?.hasBlockedUUID(uuid: userUUID ?? "") == true
    }
    
    func isAdminMessage() -> Bool {
        return messageTypeId == 7
    }
    
    func isBotMessage() -> Bool {
        return messageTypeId == 5 || messageTypeId == 6
    }
    
    func isStickerMessage() -> Bool {
        return messageTypeId == 8
    }
    
    func isMediaMessage() -> Bool {
        return messageTypeId == 2 || messageTypeId == 3 || messageTypeId == 4
    }
}

struct ChatMessageType: Codable {
    
    let chatMessageTypeId: Int?
    let chatMessageTypeName: String?
    let isProtected: Bool?
}

struct BotMessageRequest: Codable {
    
    let input: String?
    let version: String?
}
