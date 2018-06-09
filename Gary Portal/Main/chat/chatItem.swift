//
//  chatItem.swift
//  Gary Portal
//
//  Created by Tom Knighton on 05/04/2018.
//  Copyright © 2018 Tom Knighton. All rights reserved.
//

import UIKit
import SendBirdSDK

class chatItem : NSObject {
    var name : String!
    var unread : UInt!
    var memberCount : UInt!
    var channel : SBDGroupChannel!
    var lastMessage : String!
    var channelRef : String!
    var lastTime : String!
    var totalMessages : UInt!
    var isProtected: Bool!
    var otherMemberURL : String!
    var otherMemberName : String!
}
