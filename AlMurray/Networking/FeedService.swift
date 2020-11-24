//
//  FeedService.swift
//  AlMurray
//
//  Created by Tom Knighton on 15/09/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import Foundation

struct FeedService {
    
    func getFeedPosts(startingFrom: Date? = Date(), limit: Int? = 10, _ completion: @escaping(([FeedPost]?) -> Void)) {
        let timefrom = String(describing: Int((startingFrom?.timeIntervalSince1970.rounded() ?? 0) * 1000))
        let request = APIRequest(method: .get, path: "api/feed")
        request.queryItems = [URLQueryItem(name: "startfrom", value: timefrom)]
        APIClient().perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: [ClassWrapper<FeedFamily, FeedPost>].self) {
                    completion(response.body.compactMap { $0.object })
                } else {
                    completion(nil)
                }
            case .failure:
                completion(nil)
            }
        }
    }
    
    func getAditLogs(startingFrom: Date? = Date(), _ completion: @escaping(([AditLog]?) -> Void)) {
        let request = APIRequest(method: .get, path: "api/feed/aditlogs")
        APIClient().perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: [AditLog].self) {
                    completion(response.body)
                } else {
                    completion(nil)
                }
            case .failure:
                completion(nil)
            }
        }
    }
    
    func toggleLike(for post: FeedPost?, _ userId: String) {
        let reqType = post?.postType == "Image" || post?.postType == "Video" ? "feed" : "poll"
        let request = APIRequest(method: .put, path: "api/feed/togglelike/\(userId)/\(String(describing: post?.postId ?? 0))/\(reqType)")
        APIClient().perform(request) { (_) in }        
    }
}
