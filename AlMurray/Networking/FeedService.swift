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
        let request = APIRequest(method: .get, path: "feed")
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
        let request = APIRequest(method: .get, path: "feed/aditlogs")
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
}
