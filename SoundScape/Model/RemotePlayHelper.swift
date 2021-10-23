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

struct PlayInfo {
    let title: String
    let author: String
    let content: String
    let duration: Double
}

struct PlayProgress {
    let currentTime: Double
    let duration: Double
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
    
    
    var currentPlayInfo: PlayInfo? {
        didSet {
            guard let currentPlayInfo = currentPlayInfo else { return }
            
            let userInfoKey = "UserInfo"
            let userInfo: [AnyHashable: Any] = [userInfoKey: currentPlayInfo]
            NotificationCenter.default.post(name: .playingAudioChange, object: nil, userInfo: userInfo)
        }
    }
    
    var url: URL? {
        
        didSet {
            guard let url = url else { return }
            playerMedia = ModernAVPlayerMedia(url: url, type: .clip, metadata: metadata)
            
            guard let playerMedia = playerMedia else {
                return
            }
            
            let userInfoKey = "UserInfo"
            let userInfo: [AnyHashable: Any] = [userInfoKey: url]
            NotificationCenter.default.post(name: .remoteURLDidSelect, object: nil, userInfo: userInfo)

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
    
    // MARK: - method
    
    // Consider whether keep this method or not
    func setMetadata(title: String, author: String, content: String) {
        let matadata = ModernAVPlayerMediaMetadata(title: title, artist: author)
        self.metadata = matadata
    }
    
    func setPlayInfo(title: String, author: String, content: String, duration: Double) {
        currentPlayInfo = PlayInfo(title: title, author: author, content: content, duration: duration)
    }
    
}
// MARK: - conform to ModernAVPlayerDelegate

extension RemotePlayHelper: ModernAVPlayerDelegate {
    
    func modernAVPlayer(_ player: ModernAVPlayer, didStateChange state: ModernAVPlayer.State) {
        self.state = state
        print("Message from RemotePlayHelper: didStataChange_ \(state.description)")
        
        let userInfoKey = "UserInfo"
        let userInfo: [AnyHashable: Any] = [userInfoKey: ModernAVPlayer.State.self]
        NotificationCenter.default.post(name: .didStateChange, object: nil, userInfo: userInfo)

    }
    
    func modernAVPlayer(_ player: ModernAVPlayer, didCurrentTimeChange currentTime: Double) {
        print("Message from RemotePlayHelper: didCurrentTimeChange_ \(currentTime)")
//        delegate?.getCurrentTime(current: currentTime, duration: 100000.0)
        
        guard let currentPlayInfo = currentPlayInfo else { return }
        
        let playProgress = PlayProgress(currentTime: currentTime, duration: currentPlayInfo.duration)
        
        let userInfoKey = "UserInfo"
        let userInfo: [AnyHashable: Any] = [userInfoKey: playProgress]
        NotificationCenter.default.post(name: .didCurrentTimeChange, object: nil, userInfo: userInfo)

    }
    
    func modernAVPlayer(_ player: ModernAVPlayer, didItemPlayToEndTime endTime: Double) {
        print("Message from RemotePlayHelper: didItemPlayToEndTime_ \(endTime)")
//        delegate?.didPlayEnd()
        NotificationCenter.default.post(name: .didItemPlayToEndTime, object: nil, userInfo: nil)
    }
}

extension Notification.Name {
    static let playingAudioChange = Notification.Name("playingAudioChange")
    static let didItemPlayToEndTime = Notification.Name("didItemPlayToEndTime")
    static let didCurrentTimeChange = Notification.Name("didCurrentTimeChange")
    static let didStateChange = Notification.Name("didStateChange")
    static let remoteURLDidSelect = Notification.Name("remoteURLDidSelect")

}
