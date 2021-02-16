//
//  FeedService.swift
//  GaryPortal
//
//  Created by Tom Knighton on 21/01/2021.
//

import Foundation

struct FeedService {
    
    static func getFeedPosts(startingFrom: Date? = Date(), limit: Int = 10, completion: @escaping(([FeedPost]?, APIError?) -> Void)) {
        let timefrom = String(describing: Int((startingFrom?.timeIntervalSince1970.rounded() ?? 0) * 1000) + 60000)
        let request = APIRequest(method: .get, path: "feed")
        request.queryItems = [URLQueryItem(name: "startfrom", value: timefrom), URLQueryItem(name: "limit", value: String(describing: limit))]
        APIClient().perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: [ClassWrapper<FeedFamily, FeedPost>].self) {
                    completion(response.body.compactMap { $0.object }, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }
    
    static func getAditLogs(completion: @escaping (([AditLog]?, APIError?) -> Void)) {
        let request = APIRequest(method: .get, path: "feed/aditlogs")
        APIClient().perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: [AditLog].self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }
    
    static func watchAditLog(_ aditLogId: Int, uuid: String) {
        let request = APIRequest(method: .put, path: "feed/watchedaditlog/\(aditLogId)/\(uuid)")
        APIClient().perform(request, nil)
    }
    
    static func reportPost(_ postId: Int, from uuid: String, for reason: String) {
        let report = FeedReport(feedReportId: 0, feedPostId: postId, reportReason: reason, reportIssuedAt: Date(), reportByUUID: uuid, isDeleted: false, reportedPost: nil, reporter: nil)
        let request = APIRequest(method: .post, path: "feed/reportpost/\(postId)")
        request.body = report.jsonEncode()
        APIClient().perform(request, nil)
    }
    
    static func deletePost(postId: Int) {
        let request = APIRequest(method: .put, path: "feed/deletepost")
        APIClient().perform(request, nil)
    }
    
    static func toggleLikeForPost(postId: Int, userUUID: String) {
        let request = APIRequest(method: .put, path: "feed/togglelike/\(postId)/\(userUUID)")
        APIClient().perform(request, nil)
    }
    
    static func voteOnPoll(for answerId: Int, userUUID: String) {
        let request = APIRequest(method: .put, path: "feed/votefor/\(answerId)/\(userUUID)")
        APIClient().perform(request, nil)
    }
    
    static func resetPollVotes(for postId: Int) {
        let request = APIRequest(method: .put, path: "feed/resetvotes/\(postId)")
        APIClient().perform(request, nil)
    }
}
