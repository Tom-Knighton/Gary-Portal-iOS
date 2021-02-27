//
//  ChatService.swift
//  GaryPortal
//
//  Created by Tom Knighton on 31/01/2021.
//

import Foundation
import UIKit

struct ChatService {
    
    static func getChats(for userUUID: String, completion: @escaping(([Chat]?, APIError?) -> Void)) {
        let request = APIRequest(method: .get, path: "chat/chats/\(userUUID)")
        APIClient.shared.perform(request) { (result) in
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
    
    static func getChat(by chatUUID: String, _ completion: @escaping ((Chat?, APIError?) -> Void)) {
        let request = APIRequest(method: .get, path: "chat/\(chatUUID)")
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: Chat.self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }
    
    static func getChatMessage(by messageUUID: String, completion: @escaping ((ChatMessage?, APIError?) -> Void)) {
        let request = APIRequest(method: .get, path: "chat/message/\(messageUUID)")
        APIClient.shared.perform(request) { (result) in
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
    
    static func getChatMessages(for chatUUID: String, startingFrom: Date? = Date(), limit: Int = 10, completion: @escaping (([ChatMessage]?, APIError?) -> Void)) {
        let timefrom = String(describing: Int((startingFrom?.timeIntervalSince1970.rounded() ?? 0) * 1000) + 60000)
        let request = APIRequest(method: .get, path: "chat/messages/\(chatUUID)")
        request.queryItems = [URLQueryItem(name: "startfrom", value: timefrom), URLQueryItem(name: "limit", value: String(describing: limit))]
        APIClient.shared.perform(request) { (result) in
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
        APIClient.shared.perform(request) { (result) in
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
    
    static func createChat(chat: Chat, _ completion: @escaping ((Chat?, APIError?) -> Void)) {
        let request = APIRequest(method: .post, path: "chat")
        request.body = chat.jsonEncode()
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: Chat.self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }
    
    static func markChatAsRead(for uuid: String, chatUUID: String) {
        let request = APIRequest(method: .put, path: "chat/chats/\(chatUUID)/markasread")
        APIClient.shared.perform(request, nil)
    }
    
    static func markMessageAsDeleted(messageUUID: String) {
        let request = APIRequest(method: .put, path: "chat/messages/delete/\(messageUUID)")
        APIClient.shared.perform(request, nil)
    }
    
    static func reportMessage(_ messageUUID: String, from uuid: String, for reason: String) {
        let report = ChatMessageReport(chatMessageReportId: 0, chatMessageUUID: messageUUID, reportReason: reason, reportIssuedAt: Date(), reportByUUID: uuid, isDeleted: false, reportedMessage: nil, reporter: nil)
        let request = APIRequest(method: .post, path: "chat/reportmessage/\(messageUUID)")
        request.body = report.jsonEncode()
        APIClient.shared.perform(request, nil)
    }
    
    static func editChatName(_ chat: Chat, newName: String, completion: @escaping((Chat?, APIError?) -> Void)) {
        let chatDetails = ChatEditDetails(chatUUID: chat.chatUUID ?? "", chatName: newName, chatIsProtected: chat.chatIsProtected, chatIsPublic: chat.chatIsPublic, chatIsDeleted: chat.chatIsDeleted)
        let request = APIRequest(method: .put, path: "chat")
        request.body = chatDetails.jsonEncode()
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: Chat.self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }
    
    static func addUserToChat(_ username: String, chatUUID: String, completion: @escaping((ChatMember?, APIError?) -> Void)) {
        let request = APIRequest(method: .put, path: "chat/Chats/AddUserByUsername/\(username)/\(chatUUID)")
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: ChatMember.self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }
    
    static func addUserToChatByUUID(_ userUUID: String, chatUUID: String, completion: @escaping((ChatMember?, APIError?) -> Void)) {
        let request = APIRequest(method: .put, path: "chat/Chats/AddUser/\(userUUID)/\(chatUUID)")
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: ChatMember.self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }
    
    static func leaveChat(userUUID: String, chatUUID: String) {
        let request = APIRequest(method: .put, path: "chat/chats/removeuser/\(userUUID)/\(chatUUID)")
        APIClient.shared.perform(request, nil)
    }
    
    static func uploadAttachment(to chatUUUID: String, videoURL: String? = "", photoURL: String? = "", completion: @escaping((String?, APIError?) -> Void)) {
        let request = APIRequest(method: .post, path: "chat/\(chatUUUID)/Attachment")
        var boundary = ""
        if let url = videoURL, let videoURL = URL(string: url) {
            do {
                let videoData = try Data(contentsOf: videoURL)
                boundary = "Boundary-\(UUID().uuidString)"
                let paramName = "video"
                let fileName = "video.mp4"
                var data = Data()
                data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
                data.append("Content-Type: video/mp4\r\n\r\n".data(using: .utf8)!)
                data.append(videoData)
                data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
                request.body = data
            } catch {
                completion(nil, .dataNotFound)
                return
            }
        } else if let url = photoURL, let photoURL = URL(string: url) {
            do {
                let photoData = try Data(contentsOf: photoURL)
                let image = UIImage(data: photoData)
                let imgData = image?.jpegData(compressionQuality: 0.5)
                boundary = "Boundary-\(UUID().uuidString)"
                let paramName = "image"
                let fileName = "image.jpg"
                var data = Data()
                data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
                data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                data.append(imgData!)
                data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
                request.body = data
            } catch {
                completion(nil, .dataNotFound)
                return
            }
            
        } else {
            completion(nil, .dataNotFound)
            return
        }
        
        APIClient.shared.perform(request, contentType: "multipart/form-data; boundary=\(boundary)") { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: String.self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, .codingFailure)
                }
            case .failure:
                completion(nil, .networkFail)
            }
        }
    }
    
    static func getBotMessageResponse(for input: String, _ completion: @escaping ((String?, APIError?) -> Void)) {
        let request = APIRequest(method: .post, path: "chat/botmessage")
        let botmessage = BotMessageRequest(input: input, version: "4.0.0")
        request.body = botmessage.jsonEncode()
        APIClient.shared.perform(request) { (result) in
            switch result {
            case .success(let response):
                if let response = try? response.decode(to: String.self) {
                    completion(response.body, nil)
                } else {
                    completion("API ERROR", .codingFailure)
                }
            case .failure:
                completion("API ERROR", .networkFail)
            }
        }
    }
    
    static func postNotification(to chatUUID: String, from senderUUID: String, content: String) {
        let request = APIRequest(method: .post, path: "chat/notification/\(chatUUID)/\(senderUUID)")
        request.body = content.jsonEncode()
        APIClient.shared.perform(request, nil)
    }
}
