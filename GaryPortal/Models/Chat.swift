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
    let isInChat: Bool?
    let lastReadAt: Bool?
    
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
