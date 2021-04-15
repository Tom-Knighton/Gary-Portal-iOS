//
//  GameService.swift
//  GaryPortal
//
//  Created by Tom Knighton on 12/04/2021.
//

import Foundation

struct GameService {
    
    static func getGameTypes(for teamId: Int = 0, completion: @escaping (([GameType]?, APIError?) -> Void)) {
        let request = APIRequest(method: .get, path: "game/gametypes")
        request.queryItems = [URLQueryItem(name: "teamId", value: String(describing: teamId))]
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: [GameType].self) {
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
