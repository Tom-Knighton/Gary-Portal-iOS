//
//  AppService.swift
//  GaryPortal
//
//  Created by Tom Knighton on 24/03/2021.
//

import Foundation

struct AppService {
    
    static func GetStickers(_ completion: @escaping(([Sticker]?) -> Void)) {
        let request = APIRequest(method: .get, path: "app/getstickers")
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: [Sticker].self) {
                    completion(response.body)
                } else {
                    completion([])
                }
            case .failure:
                completion([])
            }
        }
    }
    
    static func GetEvents(teamId: Int = 0, _ completion: @escaping(([Event]?) -> Void)) {
        let request = APIRequest(method: .get, path: "app/getevents")
        request.queryItems = [URLQueryItem(name: "teamId", value: String(describing: teamId))]
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: [Event].self) {
                    completion(response.body)
                } else {
                    completion([])
                }
            case .failure:
                completion([])
            }
        }
    }
    
    static func GetCommandments(_ completion: @escaping(([Commandment]?) -> Void)) {
        let request = APIRequest(method: .get, path: "app/getcommandments")
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: [Commandment].self) {
                    completion(response.body)
                } else {
                    completion([])
                }
            case .failure:
                completion([])
            }
        }
    }
}
