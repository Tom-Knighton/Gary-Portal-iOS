//
//  AuthenticationService.swift
//  AlMurray
//
//  Created by Tom Knighton on 16/08/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth

enum AuthenticationResult {
    case error
    case success
}

struct AuthenticationService {
    
    func authenticateUser(_ authenticator: String, _ password: String, completion: @escaping((AuthenticationResult, User?) -> Void)) {
        Auth.auth().signIn(withEmail: authenticator, password: password) { (result, error) in
            if error != nil {
                print(error.debugDescription)
                completion(AuthenticationResult.error, nil)
            } else {
                UserService().getUserById(userId: result?.user.uid ?? "") { (user) in
                    if let user = user {
                        completion(AuthenticationResult.success, user)
                    } else {
                        print("Failed to decode user")
                        completion(AuthenticationResult.error, nil)
                    }
                }
            }
            
        }
    }
    
    func isEmailFree(_ email: String, completion: @escaping((Bool) -> Void)) {
        let request = APIRequest(method: .get, path: "api/users/IsEmailFree/\(email)")
        APIClient().perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: Bool.self) {
                    completion(response.body)
                } else {
                    completion(false)
                }
            case .failure:
                completion(false)
            }
        }
    }
    
    func isUsernameFree(_ username: String, completion: @escaping((Bool) -> Void)) {
        let request = APIRequest(method: .get, path: "api/users/IsUsernameFree/\(username)")
        APIClient().perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: Bool.self) {
                    completion(response.body)
                } else {
                    completion(false)
                }
            case .failure:
                completion(false)
            }
        }
    }
    
    func createNewUser(from user: User, completion: @escaping((User?) -> Void)) {
        let request = APIRequest(method: .post, path: "public/users/createnewuser/")
        request.body = try? JSONEncoder().encode(user)
        APIClient().perform(request) { (result) in
            switch result {
            case.success(let response):
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
    
    func sendUserPasswordReset(for user: User?) {
        let request = APIRequest(method: .post, path: "public/users/postreset/\(user?.userId ?? "")")
        APIClient().perform(request, nil)
    }
    
    func sendUserPasswordReset(to email: String?) {
        let request = APIRequest(method: .post, path: "public/users/postreset2/\(email ?? "")")
        APIClient().perform(request, nil)
    }
}
