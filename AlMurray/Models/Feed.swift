//
//  Feed.swift
//  AlMurray
//
//  Created by Tom Knighton on 15/09/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import UIKit

struct AditLog: Codable {
    
    let postId: Int?
    let posterId: String?
    let datePosted: Date?
    let postURL: String?
    let postThumbnailURL: String?
    let postCaption: String?
    let postViews: Int?
    let postType: String?
    let postTeam: String?
    
    let poster: UserDTO?
    
}

class FeedPost: Codable {
    
    let postId: Int?
    let posterId: String?
    let datePosted: Date?
    let postType: String?
    let postTeam: String?
    var likes: [String: String]?
    var likesCount: Int?
    
    let poster: UserDTO?
    
    public init?(posterId: String, postType: String, postTeam: String) {
        self.postId = 0; self.posterId = posterId; self.datePosted = nil; self.postType = postType; self.postTeam = postTeam
        self.poster = nil
        self.likes = nil
    }
    
    func hasBeenLikedByUser(userName: String) -> Bool {
        return self.likes?.contains { $0.key == userName } ?? false
    }
}

class FeedMediaPost: FeedPost {
    
    var postURL: String?
    var postDescription: String?
    
    public init?(posterId: String, postType: String, postTeam: String, postURL: String, postDescription: String) {
        super.init(posterId: posterId, postType: postType, postTeam: postTeam)
        
        self.postURL = postURL
        self.postDescription = postDescription
        
    }
    
    required init(from decoder: Decoder) throws {
        self.postURL = try decoder.container(keyedBy: CodingKeys.self)
             .decode(String.self, forKey: .postURL)
        self.postDescription = try decoder.container(keyedBy: CodingKeys.self)
        .decode(String.self, forKey: .postDescription)
        try super.init(from: decoder)
    }
    
    enum CodingKeys: String, CodingKey {
        case postURL
        case postDescription
    }
}

class FeedPollPost: FeedPost {
    
    var pollQuestion: String?
    var pollAnswers: [FeedPollAnswer]?
    
    public init?(posterId: String, postType: String, postTeam: String, question: String, answers: [String]) {
        super.init(posterId: posterId, postType: postType, postTeam: postTeam)
        
        self.pollQuestion = question
        self.pollAnswers = nil
    }
    
    enum CodingKeys: String, CodingKey {
        case pollQuestion
        case pollAnswers
    }
    
    required init(from decoder: Decoder) throws {
        self.pollQuestion = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .pollQuestion)
        self.pollAnswers = try decoder.container(keyedBy: CodingKeys.self).decode([FeedPollAnswer].self, forKey: .pollAnswers)
        try super.init(from: decoder)
    }
        
    func hasBeenVotedOn(by userId: String) -> Bool {
        return self.pollAnswers?.contains { ($0.responses?.contains { $0 == userId } ?? false) } ?? false
    }
    
}

struct FeedPollAnswer: Codable {
    
    let answer: String?
    let responses: [String]?
}

enum FeedFamily: String, ClassFamily {
    case image = "Image"
    case video = "Video"
    case poll = "poll"
    
    static var discriminator: Discriminator = .type
    
    func getType() -> AnyObject.Type {
        switch self {
        case .image:
            return FeedMediaPost.self
        case .video:
            return FeedMediaPost.self
        case .poll:
            return FeedPollPost.self
        }
    }
}
