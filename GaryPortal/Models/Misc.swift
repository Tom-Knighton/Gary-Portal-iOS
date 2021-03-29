//
//  Misc.swift
//  GaryPortal
//
//  Created by Tom Knighton on 21/01/2021.
//

import Foundation

struct Joke: Codable {
    
    let id: Int?
    let type: String?
    let setup: String?
    let punchline: String?
}

struct Event: Codable {
    
    let eventId: Int?
    let eventName: String?
    let eventDate: Date?
    let eventEndsAt: Date?
    let eventShortDescription: String?
    let eventDescription: String?
    let eventCoverUrl: String?
    let eventTeamId: Int?
    let isEventDeleted: Bool?
}

struct Commandment: Codable {
    
    let commandmentId: Int?
    let commandmentName: String?
    let commandmentDescription: String?
    let commandmentCoverUrl: String?
    let commandmentIsDeleted: Bool?
}
