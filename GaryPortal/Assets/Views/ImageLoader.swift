//
//  ImageLoader.swift
//  GaryPortal
//
//  Created by Tom Knighton on 14/01/2021.
//

import SwiftUI
import Combine
import Foundation

final class Loader: ObservableObject {
    
    var task: URLSessionDataTask?
    @Published var data: Data? = nil
    
    func setup(_ url: URL) {
        task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
            DispatchQueue.main.async {
                self.data = data
            }
        })
        task?.resume()
    }
    
    deinit {
        task?.cancel()
    }
}

let placeholder = UIImage()

struct AsyncImage: View {
    init(url: String) {
        if let url = URL(string: url) {
            self.imageLoader.setup(url)
        }
    }
    
    @ObservedObject private var imageLoader: Loader = Loader()
    
    var image: UIImage? {
        imageLoader.data.flatMap(UIImage.init)
    }
    
    var body: Image {
        return Image(uiImage: image ?? placeholder)
            .resizable()
    }
}
