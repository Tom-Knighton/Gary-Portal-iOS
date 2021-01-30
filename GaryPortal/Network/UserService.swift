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
        APIClient().perform(request) { (result) in
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

    static func getUser(with uuid: String, completion: @escaping ((User?) -> Void)) {
        let request = APIRequest(method: .get, path: "users/\(uuid)")
        APIClient().perform(request) { (result) in
            switch result {
            case .failure(let error):
                completion(nil)
            case.success(let response):
                if let response = try? response.decode(to: User.self) {
                    completion(response.body)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    static func getCurrentUser(completion: @escaping ((User?, APIError?) -> Void)) {
        UserService.getUser(with: KeychainWrapper.standard.string(forKey: "UUID") ?? "") { (user) in
            completion(user, nil)
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
            APIClient().perform(request, contentType: "multipart/form-data; boundary=\(boundary)") { (result) in
                switch result {
                case .success(let response):
                    if let response = try? response.decode(to: String.self) {
                        completion(response.body)
                    } else {
                        completion(nil)
                    }
                case .failure:
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
    }
    
    static func updatePointsForUser(userUUID: String, userPoints: UserPoints, completion: @escaping ((UserPoints?, APIError?) -> Void)) {
        let request = APIRequest(method: .put, path: "users/updatepointsforuser/\(userUUID)")
        request.body = try? JSONEncoder().encode(userPoints)
        APIClient().perform(request) { (result) in
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
        APIClient().perform(request) { (result) in
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
}
