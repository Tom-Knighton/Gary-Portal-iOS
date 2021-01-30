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
    
    var task: URLSessionDataTask!
    @Published var data: Data? = nil
    
    init(_ url: URL) {
        task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
            DispatchQueue.main.async {
                self.data = data
            }
        })
        task.resume()
    }
    deinit {
        task.cancel()
    }
}

let placeholder = UIImage(named: "IconSprite")!

struct AsyncImage: View {
    init(url: String) {
        if let url = URL(string: url) {
            self.imageLoader = Loader(url)
        } else {
            self.imageLoader = Loader(URL(string: "https://cdn.tomk.online/GaryPortal/AppLogo.png")!)
        }
    }
    
    @ObservedObject private var imageLoader: Loader
    var image: UIImage? {
        imageLoader.data.flatMap(UIImage.init)
    }
    
    
    var body: Image {
        return Image(uiImage: image ?? placeholder)
            .resizable()
    }
}
