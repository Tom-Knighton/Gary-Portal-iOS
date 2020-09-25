//
//  APISession.swift
//  AlMurray
//
//  Created by Tom Knighton on 19/08/2020.
//  Copyright © 2020 Tom Knighton. All rights reserved.
//

import Foundation
enum Result<T> {
    case success(T)
    case error(APIError)
}

extension APIResponse where Body == Data? {
    func decode<BodyType: Decodable>(to type: BodyType.Type) throws -> APIResponse<BodyType> {
        guard let data = body else {
            throw APIError.codingFailure
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        // swiftlint:disable:next force_try
        let decoded = try! decoder.decode(BodyType.self, from: data)
        return APIResponse<BodyType>(statusCode: self.statusCode, body: decoded)
        
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
    
    init(method: HttpMethod, path: String) {
        self.method = method; self.path = path
    }
}

struct APIClient {
    
    typealias APIClientCompletion = (APIResult<Data?>) -> Void
    private let session = URLSession.shared
    private let BASEURL = URL(string: "https://us-central1-gary-portal.cloudfunctions.net/api/")!
    
    func perform(_ request: APIRequest, _ completion: @escaping APIClientCompletion) {
        var urlComponents = URLComponents()
        urlComponents.scheme = BASEURL.scheme; urlComponents.host = BASEURL.host
        urlComponents.path = BASEURL.path; urlComponents.queryItems = request.queryItems
        
        guard let url = urlComponents.url?.appendingPathComponent(request.path) else {
            completion(.failure(.invalidUrl))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        request.headers?.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.field) }
        
        let task = session.dataTask(with: url) { (data, response, _) in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.networkFail))
                return
            }
            completion(.success(APIResponse<Data?>(statusCode: httpResponse.statusCode, body: data)))
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
