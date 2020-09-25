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
                    print("api fail")
                    completion(nil)
                }
            case .failure:
                print("fail res")
                completion(nil)
            }
        }
    }
    
}
