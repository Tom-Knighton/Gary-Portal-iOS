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
        let request = APIRequest(method: .get, path: "users/IsEmailFree/\(email)")
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
        let request = APIRequest(method: .get, path: "users/IsUsernameFree/\(username)")
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
    
    /*func CreateNewUser(user: User, completion: @escaping ((User?, UserServiceError?) -> Void)) {
           var user = user
           Auth.auth().createUser(withEmail: user.UserEmail ?? "", password: user.UserPassword ?? "") { (res, err) in
               if let error = err {
                   print(error.localizedDescription)
                   completion(nil, UserServiceError.UserCreationFailed)
                   return
               }
               
               user.UserId = res?.user.uid
               UserService().CreateNewUser(user: user) { (finalUser, error)  in
                   if let error = error {
                       completion(nil, UserServiceError.EmailInUse)
                   }
                   
                   self.userService.GetUserById(UserId: user.UserId ?? "") { (usr) in
                       if let usr = usr {
                           completion(usr, nil)
                       }
                       else { completion(nil, UserServiceError.UserCreationFailed) }
                   }
               }
           }
       }*/
}
