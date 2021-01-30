//
//  AuthService.swift
//  GaryPortal
//
//  Created by Tom Knighton on 14/01/2021.
//

import Foundation


struct AuthService {
    
    static func authenticate(user: AuthenticatingUser, needsTokens: Bool = true, completion: @escaping ((User?, APIError?) -> Void)) {
        let request = APIRequest(method: .post, path: "auth/authenticate")
        request.body = try? JSONEncoder().encode(user)
        request.queryItems?.append(URLQueryItem(name: "needsTokens", value: String(describing: needsTokens)))
        APIClient().perform(request) { (result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil, .networkFail)
            case .success(let response):
                if let response = try? response.decode(to: User.self) {
                    completion(response.body, nil)
                } else {
                    if response.statusCode == 400 {
                        completion(nil, .invalidUserDetails)
                    } else {
                        completion(nil, .codingFailure)
                    }
                }
            }
        }
    }
    
    static func isUsernameFree(username: String, completion: @escaping ((Bool) -> Void)) {
        let request = APIRequest(method: .get, path: "users/isusernamefree/\(username)")
        APIClient().perform(request) { (result) in
            switch result {
            case .failure:
                completion(false)
            case .success(let response):
                if let response = try? response.decode(to: Bool.self) {
                    completion(response.body)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    static func isEmailFree(email: String, completion: @escaping ((Bool) -> Void)) {
        let request = APIRequest(method: .get, path: "users/isemailfree/\(email)")
        APIClient().perform(request) { (result) in
            switch result {
            case .failure:
                completion(false)
            case .success(let response):
                if let response = try? response.decode(to: Bool.self) {
                    completion(response.body)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    static func registerUser(userRegistration: UserRegistration, completion: @escaping ((User?, APIError?) -> Void)) {
        let request = APIRequest(method: .post, path: "auth/registeruser")
        request.body = try? JSONEncoder().encode(userRegistration)
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
    
    static func refreshTokens(uuid: String, currentTokens: UserAuthenticationTokens, completion: @escaping ((UserAuthenticationTokens?, APIError?) -> Void)) {
        let request = APIRequest(method: .post, path: "auth/refresh/\(uuid)")
        request.body = try? JSONEncoder().encode(currentTokens)
        APIClient().perform(request, refresh: false) { (result) in
            switch result {
            case .failure:
                completion(nil, .notAuthorized)
            case .success(let response):
                if let response = try? response.decode(to: UserAuthenticationTokens.self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            }
        }
    }
}
