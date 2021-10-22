//
//  RemotePlayHelper.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/20.
//

import Foundation
import AVFoundation
import ModernAVPlayer

protocol MetadataDisplayableDelegate: AnyObject {
    func display(title: String?, author: String?)
    func getCurrentTime(current: Double, duration: Double)
    func didPlayEnd()
}

class RemotePlayHelper {
    
    // MARK: - properties

    static let shared = RemotePlayHelper()
    
    private let player: ModernAVPlayer = {
        let conf = SCRemotePlayerConfig()
        let player = ModernAVPlayer(config: conf, loggerDomains: [.error, .unavailableCommand])
        return player
    }()
    
    weak var delegate: MetadataDisplayableDelegate?
    
    var playerMedia: PlayerMedia?
    
    var metadata: ModernAVPlayerMediaMetadata?
    
    var state: ModernAVPlayer.State?
    
    var currentPlayTitle: String? {
        didSet {
            delegate?.display(title: currentPlayTitle, author: nil)
        }
    }
    
    var currentAuthor: String? {
        didSet {
            delegate?.display(title: nil, author: currentAuthor)
        }
    }
    
    var url: URL? {
        
        didSet {
            guard let url = url else { return }
            playerMedia = ModernAVPlayerMedia(url: url, type: .clip, metadata: metadata)
            
            guard let playerMedia = playerMedia else {
                return
            }

            player.load(media: playerMedia, autostart: false)
        }
        
    }
    
    // MARK: - init
    
    private init() {
        player.delegate = self
    }
    
    // MARK: - action
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func stop() {
        player.stop()
    }
    
}
    // MARK: - conform to ModernAVPlayerDelegate
    
extension RemotePlayHelper: ModernAVPlayerDelegate {
    
    func modernAVPlayer(_ player: ModernAVPlayer, didStateChange state: ModernAVPlayer.State) {
        self.state = state
        print("Message from RemotePlayHelper: didStataChange_ \(state.description)")
    }
    
    func modernAVPlayer(_ player: ModernAVPlayer, didCurrentTimeChange currentTime: Double) {
        print("Message from RemotePlayHelper: didCurrentTimeChange_ \(currentTime)")
        delegate?.getCurrentTime(current: currentTime, duration: 100000.0)
    }
    
    func modernAVPlayer(_ player: ModernAVPlayer, didItemPlayToEndTime endTime: Double) {
        print("Message from RemotePlayHelper: didItemPlayToEndTime_ \(endTime)")
        delegate?.didPlayEnd()
    }
    
}
    
    
    
    
    
    


