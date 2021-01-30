//
//  ApiClient.swift
//  GaryPortal
//
//  Created by Tom Knighton on 13/01/2021.
//

import Foundation
import Combine

struct Endpoint {
    
    let path: String
    let queryItems: [URLQueryItem]
}

extension URLSession {
    
    func request(_ endpoint: Endpoint) -> Future<Data, Error> {
        // Start by constructing a Promise, that will later be
        // returned as a Future
        let promise = Promise<Data>()

        // Immediately reject the promise in case the passed
        // endpoint can't be converted into a valid URL
        guard let url = endpoint.url else {
            promise.reject(with: Endpoint.Error.invalidURL)
            return promise
        }

        let task = dataTask(with: url) { data, _, error in
            // Reject or resolve the promise, depending on the result
            if let error = error {
                promise.reject(with: error)
            } else {
                promise.resolve(with: data ?? Data())
            }
        }

        task.resume()

        return promise
    }
}


