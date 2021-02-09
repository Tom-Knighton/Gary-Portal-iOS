//
//  ChatService.swift
//  GaryPortal
//
//  Created by Tom Knighton on 31/01/2021.
//

import Foundation

struct ChatService {
    
    static func getChats(for userUUID: String, completion: @escaping(([Chat]?, APIError?) -> Void)) {
        let request = APIRequest(method: .get, path: "chat/chats/\(userUUID)")
        APIClient().perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: [Chat].self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }
    
    static func getChatMessages(for chatUUID: String, startingFrom: Date? = Date(), limit: Int = 10, completion: @escaping (([ChatMessage]?, APIError?) -> Void)) {
        let timefrom = String(describing: Int((startingFrom?.timeIntervalSince1970.rounded() ?? 0) * 1000) + 60000)
        let request = APIRequest(method: .get, path: "chat/messages/\(chatUUID)")
        request.queryItems = [URLQueryItem(name: "startfrom", value: timefrom), URLQueryItem(name: "limit", value: String(describing: limit))]
        APIClient().perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: [ChatMessage].self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }
    
    static func postNewMessage(_ message: ChatMessage, to chatUUID: String, completion: @escaping((ChatMessage?, APIError?) -> Void)) {
        let request = APIRequest(method: .post, path: "chat/\(chatUUID)/newmessage")
        request.body = message.jsonEncode()
        APIClient().perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: ChatMessage.self) {
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
