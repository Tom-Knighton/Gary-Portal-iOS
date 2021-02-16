//
//  AdminService.swift
//  GaryPortal
//
//  Created by Tom Knighton on 15/01/2021.
//

import Foundation

struct AdminService {
    
    static func clearAllPrayers(uuid: String = "") {
        let request = APIRequest(method: .put, path: "admin/clearallprayers")
        request.queryItems?.append(URLQueryItem(name: "uuid", value: uuid))
        APIClient().perform(request, nil)
    }
    
    static func postStaffAnnouncement(uuid: String, announcement: String, completion: @escaping ((StaffRoomAnnouncement?, APIError?) -> Void)) {
        let request = APIRequest(method: .post, path: "admin/poststaffannouncement")
        let newAnnouncement = StaffRoomAnnouncement(announcementId: 0, announcement: announcement, userUUID: uuid, announcementDate: Date(), isDeleted: false, userDTO: nil)
        request.body = newAnnouncement.jsonEncode()
        APIClient().perform(request) { (result) in
            switch result {
            case .failure:
                completion(nil, .networkFail)
            case .success(let response):
                if let response = try? response.decode(to: StaffRoomAnnouncement.self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            }
        }
    }
    
    static func deleteStaffAnnouncement(id: Int) {
        let request = APIRequest(method: .put, path: "admin/markannouncementasdeleted/\(id)")
        APIClient().perform(request, nil)
    }
    
    static func getQueuedUsers(completion: @escaping(([User]?, APIError?) -> Void)) {
        let request = APIRequest(method: .get, path: "admin/queuedusers")
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
}
