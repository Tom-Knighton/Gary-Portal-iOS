//
//  StaffService.swift
//  GaryPortal
//
//  Created by Tom Knighton on 16/01/2021.
//

import Foundation

struct StaffService {
    
    static func getStaffAnnouncements(completion: @escaping (([StaffRoomAnnouncement]?, APIError?) -> Void)) {
        let request = APIRequest(method: .get, path: "staff/getstaffroomannouncements")
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .failure:
                completion(nil, .networkFail)
            case .success(let response):
                if let response = try? response.decode(to: [StaffRoomAnnouncement].self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            }
        }
    }
    
    static func getTeams(completion: @escaping (([Team]?, APIError?) -> Void)) {
        let request = APIRequest(method: .get, path: "staff/getteams")
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: [Team].self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }
    
    static func getBanTypes(completion: @escaping (([BanType]?, APIError?) -> Void)) {
        let request = APIRequest(method: .get, path: "staff/getbantypes")
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: [BanType].self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }
    
    static func getRanks(completion: @escaping (([Rank]?, APIError?) -> Void)) {
        let request = APIRequest(method: .get, path: "staff/getranks")
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: [Rank].self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }
    
    static func revokeBan(banId: Int, userUUID: String) {
        let request = APIRequest(method: .put, path: "staff/revokeban/\(banId)")
        APIClient.shared.perform(request, nil)
    }
    
    static func createBan(userBan: UserBan, completion: @escaping((UserBan?, APIError?) -> Void)) {
        let request = APIRequest(method: .post, path: "staff/banuser")
        request.body = userBan.jsonEncode()
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: UserBan.self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }
    
    static func staffEditUser(userUUID: String, details: StaffManagedUserDetails, completion: @escaping ((User?, APIError?) -> Void)) {
        let request = APIRequest(method: .put, path: "staff/staffedituser/\(userUUID)")
        request.body = details.jsonEncode()
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: User.self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }
    
    static func getJoke(completion: @escaping((Joke?, APIError?) -> Void)) {
        let request = APIRequest(method: .get, path: "staff/joke")
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: Joke.self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }
    
}
