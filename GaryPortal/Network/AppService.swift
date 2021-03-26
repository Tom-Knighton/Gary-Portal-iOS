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
}
