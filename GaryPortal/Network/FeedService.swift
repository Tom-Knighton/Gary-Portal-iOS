//
//  FeedService.swift
//  GaryPortal
//
//  Created by Tom Knighton on 21/01/2021.
//

import Foundation
import UIKit

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
    
    static func uploadAditLogMedia(_ imageURL: String? = "", _ videoURL: String? = "", completion: @escaping ((AditLogUrlResult?, APIError?) -> Void)) {
        let request = APIRequest(method: .post, path: "feed/uploadaditlogattachment")
        var boundary = ""
        if let url = videoURL, let videoURL = URL(string: url) {
            do {
                let videoData = try Data(contentsOf: videoURL)
                boundary = "Boundary-\(UUID().uuidString)"
                let paramName = "video"
                let fileName = "video.mp4"
                var data = Data()
                data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
                data.append("Content-Type: video/mp4\r\n\r\n".data(using: .utf8)!)
                data.append(videoData)
                data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
                request.body = data
                request.queryItems = [URLQueryItem(name: "isVideo", value: "true")]
            } catch {
                completion(nil, .dataNotFound)
                return
            }
        } else if let url = imageURL, let photoURL = URL(string: url) {
            do {
                let photoData = try Data(contentsOf: photoURL)
                let image = UIImage(data: photoData)
                let imgData = image?.jpegData(compressionQuality: 0.5)
                boundary = "Boundary-\(UUID().uuidString)"
                let paramName = "image"
                let fileName = "image.jpg"
                var data = Data()
                data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
                data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                data.append(imgData!)
                data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
                request.body = data
            } catch {
                completion(nil, .dataNotFound)
                return
            }
            
        } else {
            completion(nil, .dataNotFound)
            return
        }
        
        APIClient().perform(request, contentType: "multipart/form-data; boundary=\(boundary)") { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: AditLogUrlResult.self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }
    
    static func uploadPostAttachment(_ imageURL: String? = "", _ videoURL: String? = "", completion: @escaping ((String?, APIError?) -> Void)) {
        let request = APIRequest(method: .post, path: "feed/UploadMediaAttachment")
        var boundary = ""
        if let url = videoURL, let videoURL = URL(string: url) {
            do {
                let videoData = try Data(contentsOf: videoURL)
                boundary = "Boundary-\(UUID().uuidString)"
                let paramName = "video"
                let fileName = "video.mp4"
                var data = Data()
                data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
                data.append("Content-Type: video/mp4\r\n\r\n".data(using: .utf8)!)
                data.append(videoData)
                data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
                request.body = data
            } catch {
                completion(nil, .dataNotFound)
                return
            }
        } else if let url = imageURL, let photoURL = URL(string: url) {
            do {
                let photoData = try Data(contentsOf: photoURL)
                let image = UIImage(data: photoData)
                let imgData = image?.jpegData(compressionQuality: 0.5)
                boundary = "Boundary-\(UUID().uuidString)"
                let paramName = "image"
                let fileName = "image.jpg"
                var data = Data()
                data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
                data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                data.append(imgData!)
                data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
                request.body = data
            } catch {
                completion(nil, .dataNotFound)
                return
            }
            
        } else {
            completion(nil, .dataNotFound)
            return
        }
        
        APIClient().perform(request, contentType: "multipart/form-data; boundary=\(boundary)") { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: String.self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }
    
    static func postAditLog(_ aditLog: AditLog, _ completion: @escaping((AditLog?, APIError?) -> Void)) {
        let request = APIRequest(method: .post, path: "feed/aditlog")
        request.body = aditLog.jsonEncode()
        APIClient().perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: AditLog.self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }
    
    static func postMediaPost(_ mediaPost: FeedMediaPost, _ completion: @escaping((FeedMediaPost?, APIError?) -> Void)) {
        let request = APIRequest(method: .post, path: "feed")
        request.body = mediaPost.jsonEncode()
        APIClient().perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: FeedMediaPost.self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }
    
    static func postPollPost(_ pollPost: FeedPollPost, _ completion: @escaping((FeedPollPost?, APIError?) -> Void)) {
        let request = APIRequest(method: .post, path: "feed")
        request.body = pollPost.jsonEncode()
        APIClient().perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: FeedPollPost.self) {
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
        let request = APIRequest(method: .put, path: "feed/deletepost/\(postId)")
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
