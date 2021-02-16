//
//  Feed.swift
//  AlMurray
//
//  Created by Tom Knighton on 15/09/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import UIKit

struct AditLogGroup: Equatable, Hashable {
    static func == (lhs: AditLogGroup, rhs: AditLogGroup) -> Bool {
        return lhs.aditLogGroupHash == rhs.aditLogGroupHash
    }

    let aditLogGroupHash: UUID?
    let posterDTO: UserDTO?
    let aditLogs: [AditLog]?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(aditLogGroupHash)
    }

}

struct AditLog: Codable {
    
    let aditLogId: Int?
    let aditLogUrl: String?
    let aditLogThumbnailUrl: String?
    let posterUUID: String?
    let aditLogTeamId: Int?
    let isVideo: Bool?
    let datePosted: Date?
    let aditLogViews: Int?
    let caption: String?
    let isDeleted: Bool?
    
    let poster: User?
    let posterDTO: UserDTO?
    let aditLogTeam: Team?
    
    func getName() -> String {
        return self.posterDTO?.userFullName ?? ""
    }
    
    func getNiceTime() -> String {
        return self.datePosted?.niceDateAndTime() ?? ""
    }
}

struct AditLogUrlResult: Codable {
    
    let aditLogUrl: String?
    let aditLogThumbnailUrl: String?
}

class FeedPost: Codable, ObservableObject, Identifiable, Equatable {
    
    static func == (lhs: FeedPost, rhs: FeedPost) -> Bool {
        let sameId = lhs.postId == rhs.postId
        return sameId
    }
    
    
    let postId: Int?
    let posterUUID: String?
    var teamId: Int?
    let postIsGlobal: Bool?
    var postType: String?
    let postCreatedAt: Date?
    let postDescription: String?
    var postLikeCount: Int?
    var isDeleted: Bool?
    
    var poster: User?
    var posterDTO: UserDTO?
    var postTeam: Team?
    var likes: [FeedLike]?
    var comments: [FeedComment]?

    
    public init?(posterUUID: String, postType: String, teamId: Int, postDescription: String) {
        self.postId = 0; self.posterUUID = posterUUID; self.postCreatedAt = nil; self.postType = postType; self.teamId = teamId
        self.poster = nil
        self.postIsGlobal = false
        self.postDescription = postDescription
        self.postLikeCount = 0
        self.isDeleted = false
        
        self.likes = []
        self.posterDTO = nil
        self.comments = []
        self.postTeam = nil
    }
    
    func hasBeenLikedByUser(userUUID: String) -> Bool {
        return self.likes?.contains { $0.userUUID == userUUID && $0.isLiked == true } ?? false
    }
}

class FeedMediaPost: FeedPost {
    
    var postUrl: String?
    var isVideo: Bool?
    
    public init?(posterUUID: String, postType: String, teamId: Int, postURL: String, isVideo: Bool, postDescription: String) {
        super.init(posterUUID: posterUUID, postType: postType, teamId: teamId, postDescription: postDescription)
        
        self.postUrl = postURL
        self.isVideo = isVideo
        
    }
    
    required init(from decoder: Decoder) throws {
        self.postUrl = try decoder.container(keyedBy: CodingKeys.self)
            .decode(String.self, forKey: .postUrl)
        self.isVideo = try decoder.container(keyedBy: CodingKeys.self)
            .decode(Bool.self, forKey: .isVideo)
        try super.init(from: decoder)
    }
    
    enum CodingKeys: String, CodingKey {
        case postUrl
        case isVideo
    }
}

class FeedPollPost: FeedPost {
    
    var pollQuestion: String?
    var pollAnswers: [FeedPollAnswer]?
    
    public init?(posterUUID: String, postType: String, teamId: Int, postDescription: String, question: String, answers: [FeedPollAnswer]) {
        super.init(posterUUID: posterUUID, postType: postType, teamId: teamId, postDescription: postDescription)
        
        self.pollQuestion = question
        self.pollAnswers = answers
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
        
    func hasBeenVotedOn(by userUUID: String) -> Bool {
        return self.pollAnswers?.contains { ($0.votes?.contains { $0.userUUID == userUUID && $0.isDeleted == false } ?? false) } ?? false
    }
    
    func clearVotes() {
        if let answers = pollAnswers {
            for index in answers.indices {
                pollAnswers?[index].clearVotes()
            }
        }
    }
    
}

struct FeedPollAnswer: Codable {
    
    let pollAnswerId: Int?
    let pollId: Int?
    let answer: String?
    var votes: [FeedAnswerVote]?
    
    mutating func clearVotes() {
        votes?.removeAll()
    }
}

struct FeedAnswerVote: Codable {
    
    let pollAnswerId: Int?
    let userUUID: String?
    let isDeleted: Bool?
}

struct FeedLike: Codable {
    
    let userUUID: String?
    let postId: Int?
    let isLiked: Bool?
}

struct FeedComment: Codable {
    
    let feedCommentId: Int?
    let userUUID: String?
    let postId: Int?
    let comment: String?
    let isAdminComment: Bool?
    let isDeleted: Bool?
    let datePosted: Date?
    
    let userDTO: UserDTO?
}



enum FeedFamily: String, ClassFamily {
    case media = "media"
    case poll = "poll"
    
    static var discriminator: Discriminator = .type
    
    func getType() -> AnyObject.Type {
        switch self {
        case .media:
            return FeedMediaPost.self
        case .poll:
            return FeedPollPost.self
        }
    }
}
