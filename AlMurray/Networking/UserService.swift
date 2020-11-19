//
//  UserService.swift
//  AlMurray
//
//  Created by Tom Knighton on 19/08/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import UIKit

enum UserServiceError {
    case userNotFound
    case userCreationFailed
    case emailInUse
    case usernameInUse
}

struct UserService {    

    func getUserById(userId: String, completion: @escaping ((User?) -> Void)) {
        let request = APIRequest(method: .get, path: "users/\(userId)")
        APIClient().perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: User.self) {
                    completion(response.body)
                } else {
                    completion(nil)
                }
            case .failure:
                completion(nil)
            }
        }
    }
    
    func updateUserProfileImage(userId: String, newImage: UIImage, completion: @escaping((String?) -> Void)) {
        let imgData = newImage.jpegData(compressionQuality: 0.5)
        
        if let imgData = imgData {
            let boundary = "Boundary-\(UUID().uuidString)"
            let paramName = "image"
            let fileName = "image.jpg"
            let request = APIRequest(method: .post, path: "users/updateuserpicture/\(userId)")
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
        
    func updateUserSettings(userId: String, userDetails: UserDetails, completion: @escaping((User?) -> Void)) {
        let request = APIRequest(method: .put, path: "users/updateuserdetails/\(userId)")
        request.body = try? JSONEncoder().encode(userDetails)
        APIClient().perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: User.self) {
                    completion(response.body)
                } else {
                    completion(nil)
                }
            case .failure:
                completion(nil)
            }
        }
    }
    
    func getPrayers(userId: String, completion: @escaping (UserPoints?) -> Void) {
        let request = APIRequest(method: .get, path: "users/getprayers/\(userId)")
        APIClient().perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: UserPoints.self) {
                    completion(response.body)
                } else {
                    return completion(nil)
                }
            case .failure:
                return completion(nil)
            }
            
        }
    }
    
    func updatePrayers(userId: String, simplePrayers: Int, meaningfulPrayers: Int) {
        let request = APIRequest(method: .put, path: "users/updateprayers/\(userId)/\(simplePrayers)/\(meaningfulPrayers)")
        APIClient().perform(request, nil)
        GaryPortal.shared.user?.updatePrayers(simple: simplePrayers, meaningful: meaningfulPrayers)
    }
    
    func clearAllPrayers() {
        let request = APIRequest(method: .put, path: "users/clearallprayers")
        APIClient().perform(request, nil)
        GaryPortal.shared.user?.updatePrayers(simple: 0, meaningful: 0)
    }
    
}
