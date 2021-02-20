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

class GIFPlayerView: UIView {
    private let imageView = UIImageView()
    
    convenience init(url: String) {
        self.init()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            let gif = UIImage.gifImageWithURL(url)
            DispatchQueue.main.async {
                self.imageView.image = gif
                self.imageView.contentMode = .scaleToFill
                self.addSubview(self.imageView)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
}

struct GIFView: UIViewRepresentable {
    var gifUrl: String
    
    func makeUIView(context: Context) -> some UIView {
        return GIFPlayerView(url: gifUrl)
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
