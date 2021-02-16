//
//  PlayerView.swift
//  GaryPortal
//
//  Created by Tom Knighton on 22/01/2021.
//

import Foundation
import SwiftUI
import AVKit

class PlayerUIView: UIView {
    private var avPlayer = AVPlayer()
    private let playerLayer = AVPlayerLayer()
    
    @AppStorage(GaryPortalConstants.UserDefaults.autoPlayVideos) var autoPlayVideos = false
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setup(url: String, gravity: PlayerViewGravity? = .fit) {
        if let url = URL(string: url) {
            self.avPlayer = AVPlayer(url: url)
            
            do {
               try AVAudioSession.sharedInstance().setCategory(.playback)
            } catch let error {
                print(error.localizedDescription)
            }
            self.avPlayer.isMuted = false
            
            if autoPlayVideos {
                self.avPlayer.play()
                _ = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.avPlayer.currentItem, queue: nil) { _ in
                    self.avPlayer.seek(to: CMTime.zero)
                    self.avPlayer.play()
                }
            }
            
            self.playerLayer.player = self.avPlayer
            self.playerLayer.videoGravity = gravity?.avGravity ?? .resizeAspect
            layer.addSublayer(playerLayer)
        } else {
            print("fail")
        }
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func togglePlay(play: Bool) {
        self.avPlayer.seek(to: CMTime.zero)
        play ? self.avPlayer.play() : self.avPlayer.pause()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
}


public enum PlayerViewGravity {
    case fit
    case fill
    case stretch
    
    var avGravity: AVLayerVideoGravity {
        switch self {
        case .fit:
            return .resizeAspect
        case .fill:
            return .resizeAspectFill
        case .stretch:
            return .resize
        }
    }
}

struct PlayerView: UIViewRepresentable {
    var url: String
    @Binding var play: Bool
    var gravity: PlayerViewGravity = .fill
    
    func updateUIView(_ uiView: PlayerUIView, context: UIViewRepresentableContext<PlayerView>) {
        uiView.togglePlay(play: play)
    }
    
    func makeUIView(context: Context) -> PlayerUIView {
        let playerview = PlayerUIView(frame: .zero)
        playerview.setup(url: url, gravity: gravity)
        return playerview
    }

}
