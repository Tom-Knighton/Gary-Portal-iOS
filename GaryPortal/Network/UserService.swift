//
//  UserService.swift
//  GaryPortal
//
//  Created by Tom Knighton on 14/01/2021.
//

import Foundation
import SwiftKeychainWrapper
import UIKit
import SwiftUI

struct UserService {
    
    static func getAllUsers(for teamId: Int = 0, completion: @escaping (([User]?, APIError?) -> Void)) {
        let request = APIRequest(method: .get, path: "users")
        request.queryItems = [URLQueryItem(name: "teamId", value: String(describing: teamId))]
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: [User].self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }

    static func getUser(with uuid: String, completion: @escaping ((User?, APIError?) -> Void)) {
        let request = APIRequest(method: .get, path: "users/\(uuid)")
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .failure(let error):
                completion(nil, error)
            case.success(let response):
                if let response = try? response.decode(to: User.self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            }
        }
    }
    
    static func getCurrentUser(completion: @escaping ((User?, APIError?) -> Void)) {
        UserService.getUser(with: KeychainWrapper.standard.string(forKey: "UUID") ?? "") { (user, error) in
            completion(user, error)
        }
    }
    
    static func updateUserProfileImage(userUUID: String, newImage: UIImage, completion: @escaping((String?) -> Void)) {
        let imgData = newImage.jpegData(compressionQuality: 0.5)
        
        if let imgData = imgData {
            let boundary = "Boundary-\(UUID().uuidString)"
            let paramName = "image"
            let fileName = "image.jpg"
            let request = APIRequest(method: .post, path: "users/updateprofilepictureforuser/\(userUUID)")
            var data = Data()
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            data.append(imgData)
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            request.body = data
            request.contentType = "multipart/form-data; boundary=\(boundary)"
            APIClient.shared.perform(request) { (result) in
                switch result {
                case .success(let response):
                    if let response = try? response.decode(to: String.self) {
                        completion(response.body)
                    } else {
                        completion(nil)
                    }
                case .failure:
                    print("fail")
                    completion(nil)
                }
            }
        } else {
            print("no imgdata")
            completion(nil)
        }
    }
    
    static func updatePointsForUser(userUUID: String, userPoints: UserPoints, completion: @escaping ((UserPoints?, APIError?) -> Void)) {
        let request = APIRequest(method: .put, path: "users/updatepointsforuser/\(userUUID)")
        request.body = try? JSONEncoder().encode(userPoints)
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .failure:
                completion(nil, .networkFail)
            case .success(let response):
                if let response = try? response.decode(to: UserPoints.self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            }
        }
    }
    
    static func updateUserDetails(userUUID: String, userDetails: UserDetails, completion: @escaping ((User?, APIError?) -> Void)) {
        let request = APIRequest(method: .put, path: "users/updatedetailsforuser/\(userUUID)")
        request.body = try? JSONEncoder().encode(userDetails)
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .failure:
                completion(nil, .networkFail)
            case .success(let response):
                if let response = try? response.decode(to: User.self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            }
        }
    }
    
    static func getBlockedUsers(userUUID: String, _ completion: @escaping (([UserBlock]?, APIError?) -> Void)) {
        let request = APIRequest(method: .get, path: "users/getblockedusersfor/\(userUUID)")
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: [UserBlock].self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }
    
    static func blockUser(blockerUUID: String, blockedUUID: String, _ completion: @escaping ((UserBlock?, APIError?) -> Void)) {
        let request = APIRequest(method: .post, path: "users/blockuser/\(blockerUUID)/\(blockedUUID)")
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: UserBlock.self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }
    
    static func unblockUser(blockerUUID: String, blockedUUID: String, _ completion: @escaping (() -> Void)) {
        let request = APIRequest(method: .post, path: "users/unblockuser/\(blockerUUID)/\(blockedUUID)")
        APIClient.shared.perform(request) { (result) in
            completion()
        }
    }
    
    static func reportUser(uuid: String, reportedBy: String, reason: String) {
        let report = UserReport(userReportId: 0, userUUID: uuid, reportReason: reason, reportIssuedAt: Date(), reportByUUID: reportedBy, isDeleted: false, reportedUser: nil, reporter: nil)
        let request = APIRequest(method: .post, path: "users/reportuser/\(uuid)")
        request.body = report.jsonEncode()
        APIClient.shared.perform(request, nil)
    }
    
    static func postAPNS(uuid: String, apns: String) {
        let request = APIRequest(method: .post, path: "users/addapns/\(uuid)/\(apns)")
        APIClient.shared.perform(request, nil)
    }
    
    static func postNotification(to uuid: String, content: String) {
        let request = APIRequest(method: .post, path: "users/SendNotification/\(uuid)")
        request.body = content.jsonEncode()
        APIClient.shared.perform(request, nil)
    }
}
