//
//  VideoPlayer.swift
//
//  Created by Tomas Green on 2020-06-05.
//

import SwiftUI
import AVFoundation

struct PlayerView: UIViewRepresentable {
    var url:URL
    var player:AVQueuePlayer? = nil
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
        
    }
    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(url: url, player: player)
    }
}
struct PlayerViewOptions {
    var isMuted:Bool
    var isPaused:Bool
}

class PlayerUIView: UIView {
    private var playerLayer:AVPlayerLayer
    private var playerLooper: AVPlayerLooper
    private var player: AVQueuePlayer!
    
    var url:URL
    init(url:URL,player:AVQueuePlayer? = nil) {
        self.url = url
        let playerItem = AVPlayerItem(url: url)
        if let player = player {
            self.player = player
        } else {
            self.player = AVQueuePlayer(items: [playerItem])
            self.player.play()
            self.player.isMuted = true
        }
        playerLayer = AVPlayerLayer(player: self.player)
        playerLooper = AVPlayerLooper(player: self.player, templateItem: playerItem)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.player = self.player
        super.init(frame: .zero)
        layer.addSublayer(playerLayer)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
