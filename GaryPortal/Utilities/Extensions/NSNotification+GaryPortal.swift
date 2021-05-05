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
    
    static let postDeleted = Notification.Name("postDeleted")
    static let postVotesCleared = Notification.Name("postVotesCleared")
    
    static let newChatMessage = Notification.Name("newChatMessage")
    static let deleteChatMessage = Notification.Name("deleteChatMessage")
    static let chatNameChanged = Notification.Name("chatNameChanged")
    static let newChatMember = Notification.Name("chatMemberAdded")
    static let addedToChat = Notification.Name("addedToChat")
    
    static let banStatusUpdated = Notification.Name("banStatusUpdated")
    
    static let addTextLabelPressed = Notification.Name("addTextLabelBtnPressed")
    static let addStickerLabelPressed = Notification.Name("addStickerBtnPressed")
    
    static let hostLeftLobby = Notification.Name("hostLeftLobby")
    static let updateGameLobby = Notification.Name("updateGameLobby")
    static let ttgGameStarted = Notification.Name("ttg:GameStarted")
    static let ttgMovePlayed = Notification.Name("ttg:MovePlayed")
    static let ttgGameWon = Notification.Name("ttg:GameWon")
}
