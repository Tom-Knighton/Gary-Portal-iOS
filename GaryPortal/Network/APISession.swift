//
//  APISession.swift
//  AlMurray
//
//  Created by Tom Knighton on 19/08/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

extension Encodable {
    
    func jsonEncode() -> Data? {
        let encoder = JSONEncoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        encoder.dateEncodingStrategy = .formatted(formatter)
        let encoded = try? encoder.encode(self)
        return encoded
    }
    
    func encodeToJSONObject() -> JSON? {
        guard let data = self.jsonEncode() else { return nil }
        
        return JSON.convertFromData(data)
    }
}

extension JSON {
    func decode<BodyType: Decodable>(to type: BodyType.Type) throws -> BodyType? {
        guard let data = self.asData() else { return nil; }
        
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        decoder.dateDecodingStrategy = .formatted(formatter)
        let decoded = try decoder.decode(BodyType.self, from: data)
        return decoded
    }
}

extension APIResponse where Body == Data? {
    func decode<BodyType: Decodable>(to type: BodyType.Type) throws -> APIResponse<BodyType> {
        guard let data = body else {
            throw APIError.codingFailure
        }
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        decoder.dateDecodingStrategy = .formatted(formatter)
        let decoded = try decoder.decode(BodyType.self, from: data)
        return APIResponse<BodyType>(statusCode: self.statusCode, body: decoded)
        
    }
}

extension String {
    func jsonDecode<BodyType: Decodable>(to type: BodyType.Type) -> BodyType? {
        guard !self.isEmpty else { return nil }
        
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        decoder.dateDecodingStrategy = .formatted(formatter)
        let decoded = try? decoder.decode(BodyType.self, from: self.asData())
        return decoded
    }
}

enum HttpMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
    case head = "HEAD"
    case connect = "CONNECT"
}

struct HttpHeader {
    
    let field: String
    let value: String
}

enum APIError: Error {
    case networkFail
    case dataNotFound
    case codingFailure
    case invalidUrl
    case notAuthorized
    case invalidUserDetails
    case chatBan
    case feedBan
    case globalBan
    case badRequest
}

enum APIResult<Body> {
    case success(APIResponse<Body>)
    case failure(APIError)
}

struct APIResponse<Body> {
    let statusCode: Int
    let body: Body
}

class APIRequest {
    
    let method: HttpMethod
    let path: String
    var queryItems: [URLQueryItem]?
    var headers: [HttpHeader]?
    var body: Data?
    var contentType: String = "application/json"
    
    init(method: HttpMethod, path: String) {
        self.method = method; self.path = path
    }
}

protocol TokenRefreshing {
    func refreshAccessToken(_ refreshToken: String, completion: @escaping (Result<UserAuthenticationTokens, Error>) -> Void)
}
protocol AuthenticationInfoStorage {
    var userAuthInfo: UserAuthenticationTokens? { get set }
    func persistUserAuthInfo(_ authInfo: UserAuthenticationTokens?)
    func wipeUserAuthInfo()
}

final class APIClient {
    
    typealias APIClientCompletion = (APIResult<Data?>) -> Void
    private let session = URLSession.shared
    private let BASEURL = URL(string: GaryPortalConstants.APIBaseUrl)
    
    private var isRefreshingToken = false
    private var savedRequests: [DispatchWorkItem] = []
    
    static let shared = APIClient()
    
    private func saveRequest(_ block: @escaping () -> Void) {
        // Save request to DispatchWorkItem array
        savedRequests.append( DispatchWorkItem {
          block()
        })
    }
    
    private func executeAllSavedRequests() {
       savedRequests.forEach({ DispatchQueue.global().async(execute: $0) })
       savedRequests.removeAll()
    }
    
    
    func perform(_ request: APIRequest, _ completion: APIClientCompletion?) {
        if isRefreshingToken && !request.path.contains("refresh") {
            if !request.path.contains("refresh") {
                self.saveRequest {
                    self.perform(request, completion)
                }
            }
            return
        }
        
        var urlComponents = URLComponents()
        guard let BASEURL = BASEURL else { return }
        
        urlComponents.scheme = BASEURL.scheme; urlComponents.host = BASEURL.host
        urlComponents.path = BASEURL.path; urlComponents.queryItems = request.queryItems
        
        guard let url = urlComponents.url?.appendingPathComponent(request.path) else {
            completion?(.failure(.invalidUrl))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue(request.contentType, forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Bearer \(String(describing: GaryPortal.shared.getTokens().authenticationToken ?? ""))", forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        
        request.headers?.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.field) }
        
        let task = session.dataTask(with: urlRequest) { (data, response, _) in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion?(.failure(.networkFail))
                return
            }
            
            if httpResponse.statusCode == 401 && request.path.contains("refresh") == false { // Unauthorised
                if self.isRefreshingToken { // If already refreshing
                    self.saveRequest { // Save request to stack
                        self.perform(request, completion)
                    }
                    return
                } else { // Else
                    self.isRefreshingToken = true // Set refresh to true
                    self.saveRequest {
                        self.perform(request, completion)
                    }
                    AuthService.refreshTokens(uuid: KeychainWrapper.standard.string(forKey: "UUID") ?? "", currentTokens: GaryPortal.shared.getTokens()) { (newTokens, error) in // Call Refresh
                        if let newTokens = newTokens { // If tokens received
                            GaryPortal.shared.updateTokens(tokens: newTokens)
                            self.isRefreshingToken = false
                            self.executeAllSavedRequests()
                            return
                        } else {
                            self.isRefreshingToken = false
                            GaryPortal.shared.logoutUser()
                            return
                        }
                    }
                }
                return
            } else if (httpResponse.statusCode == 400) { // Bad Request
                if let data = data {
                    if String(data: data, encoding: .utf8) == "Invalid login attempt" {
                        completion?(.failure(.invalidUserDetails))
                    } else if String(data: data, encoding: .utf8) == "User has been banned from Chat" {
                        completion?(.failure(.chatBan))
                    } else if String(data: data, encoding: .utf8) == "User has been banned from Feed" {
                        completion?(.failure(.feedBan))
                    } else {
                        completion?(.failure(.badRequest))
                    }
                }
                return
            }
            
            completion?(.success(APIResponse<Data?>(statusCode: httpResponse.statusCode, body: data)))
        }
        task.resume()
        
    }
}

protocol ClassFamily: Decodable {
    
    static var discriminator: Discriminator { get }
    func getType() -> AnyObject.Type
}

enum Discriminator: String, CodingKey {
    case type = "postType"
}

class ClassWrapper<T: ClassFamily, U: Decodable>: Decodable {
    let family: T
    let object: U?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Discriminator.self)
        family = try container.decode(T.self, forKey: T.discriminator)
        if let type = family.getType() as? U.Type {
            object = try type.init(from: decoder)
        } else {
            object = nil
        }
    }
}
