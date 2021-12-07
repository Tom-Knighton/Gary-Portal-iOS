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
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    private var player = AVQueuePlayer()
    private var url = ""
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(with player: AVQueuePlayer, url: String) {
        super.init(frame: .zero)
        self.player = player
        self.url = url
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setup() {
        
        guard let url = URL(string: self.url) else { return }
        // Load the resource
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        
        // Setup the player
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        // Create a new player looper with the queue player and template item
        playerLooper = AVPlayerLooper(player: player, templateItem: item)
        
        // Start the movie
//        player.play()
        
    }
    
    @objc
    func playerItemDidReachEnd(notification: Notification) {
        playerLayer.player?.seek(to: CMTime.zero)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    func togglePlay(play: Bool) {
        play ? self.player.play() : self.player.pause()
    }
    
    func toggleMute(mute: Bool) {
        self.player.isMuted = mute
        print("setting mute to \(mute )")
    }
    
    public func dismantle() {
        self.playerLayer.player?.replaceCurrentItem(with: nil)
        self.playerLayer.player?.pause()
        self.playerLayer.player = nil
        self.player.pause()
        self.player = AVQueuePlayer()
        self.playerLayer.removeFromSuperlayer()
        self.playerLooper?.disableLooping()
    }
}

struct PlayerView: UIViewRepresentable {
    
    typealias UIViewType = PlayerUIView
    
    
    private var player: AVQueuePlayer
    @Binding private var play: Bool
    @Binding private var isMuted: Bool
    private var url: String
    
    init(player: AVQueuePlayer, url: String, play: Binding<Bool>, isMuted: Binding<Bool>) {
        self.player = player
        self._play = play
        self._isMuted = isMuted
        self.url = url
    }
    
    func makeUIView(context: Context) -> PlayerUIView {
        let player = PlayerUIView(with: player, url: url)
        return player
        
    }
    
    static func dismantleUIView(_ uiView: PlayerUIView, coordinator: ()) {
        uiView.dismantle()
    }
    
    func updateUIView(_ uiView: PlayerUIView, context: Context)
    {
        uiView.toggleMute(mute: isMuted)
        uiView.togglePlay(play: play)
    }
}
