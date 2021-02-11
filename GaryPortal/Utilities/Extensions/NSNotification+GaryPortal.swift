//
//  NSNotification+GaryPortal.swift
//  GaryPortal
//
//  Created by Tom Knighton on 26/01/2021.
//

import Foundation

extension NSNotification.Name {
    static let movedFromFeed = Notification.Name("movedFromFeed")
    static let goneToFeed = Notification.Name("goneBackToFeed")
    
    static let newChatMessage = Notification.Name("newChatMessage")
    static let deleteChatMessage = Notification.Name("deleteChatMessage")
    static let chatNameChanged = Notification.Name("chatNameChanged")
    static let newChatMember = Notification.Name("chatMemberAdded")
}
