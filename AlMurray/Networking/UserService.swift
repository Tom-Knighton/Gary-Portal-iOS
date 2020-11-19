//
//  UserService.swift
//  AlMurray
//
//  Created by Tom Knighton on 19/08/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import Foundation

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
