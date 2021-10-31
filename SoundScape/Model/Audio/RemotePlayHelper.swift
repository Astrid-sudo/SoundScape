//
//  RemotePlayHelper.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/20.
//

import Foundation
import AVFoundation
import ModernAVPlayer

struct PlayInfo {
    let title: String
    let author: String
    let content: String
    let duration: Double
    let documentID: String
}

struct PlayProgress {
    let currentTime: Double
    let duration: Double
}

class RemotePlayHelper {
    
    /*
     Must set url first, then set playInfo. (Because in class RemotePlayHelper, set url will make playinfo be nil.)
     */
    
    // MARK: - properties
    
    static let shared = RemotePlayHelper()
    
    private let player: ModernAVPlayer = {
        let conf = SCRemotePlayerConfig()
        let player = ModernAVPlayer(config: conf, loggerDomains: [.error, .unavailableCommand])
        return player
    }()
    
    var playerMedia: PlayerMedia?
    
    var metadata: ModernAVPlayerMediaMetadata?
    
    var state: ModernAVPlayer.State?
    
    var url: URL? {
        
        didSet {
            
            currentPlayInfo = nil
            
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
    
    var currentPlayInfo: PlayInfo? {
        didSet {
            
            guard let currentPlayInfo = currentPlayInfo else { return }
            
            let userInfoKey = "UserInfo"
            let userInfo: [AnyHashable: Any] = [userInfoKey: currentPlayInfo]
            NotificationCenter.default.post(name: .playingAudioChange, object: nil, userInfo: userInfo)
        }
    }
    
    
    // MARK: - init
    
    private init() {
        player.delegate = self
    }
    
    // MARK: - action
    
    func play() {
        DispatchQueue.main.async { [weak self] in
            self?.player.play()
        }
    }
    
    func pause() {
        DispatchQueue.main.async { [weak self] in
            self?.player.pause()
        }
    }
    
    func stop() {
        DispatchQueue.main.async { [weak self] in
            self?.player.stop()
        }
    }
    
    func seek(offset: Double) {
        player.seek(offset: offset)
    }
    
    func seek(position: Double) {
        player.seek(position: position)
    }
    
    func limitCurrentTime(head: Double, tail: Double) {
        
        
        if player.currentTime < head {
            if player.state == .playing {
                pause()
            }
            seek(position: head)
        }
        
        if player.currentTime > tail {
            if player.state == .playing {
                pause()
            }
            seek(position: head)
        }
        
    }
    // MARK: - method
    
    // Consider whether keep this method or not
    func setMetadata(title: String, author: String, content: String) {
        let matadata = ModernAVPlayerMediaMetadata(title: title, artist: author)
        self.metadata = matadata
    }
    
    func setPlayInfo(title: String, author: String, content: String, duration: Double, documentID: String) {
        currentPlayInfo = PlayInfo(title: title, author: author, content: content, duration: duration, documentID: documentID)
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
        
        // play audio from firebase (SoundDetailVC and AudioPlayerVC will get this Notification)
        if let currentPlayInfo = currentPlayInfo {
            
            let playProgress = PlayProgress(currentTime: currentTime, duration: currentPlayInfo.duration)
            let userInfoKey = "UserInfo"
            let userInfo: [AnyHashable: Any] = [userInfoKey: playProgress]
            
            NotificationCenter.default.post(name: .didCurrentTimeChange, object: nil, userInfo: userInfo)
            
        } else { //play audio from local url (EditVC will get this Notification)
            
            let userInfoKey = "UserInfo"
            let userInfo: [AnyHashable: Any] = [userInfoKey: currentTime]
            NotificationCenter.default.post(name: .didCurrentTimeChange, object: nil, userInfo: userInfo)
            
            
        }
        
    }
    
    func modernAVPlayer(_ player: ModernAVPlayer, didItemPlayToEndTime endTime: Double) {
        print("Message from RemotePlayHelper: didItemPlayToEndTime_ \(endTime)")
        NotificationCenter.default.post(name: .didItemPlayToEndTime, object: nil, userInfo: nil)
    }
    
    func modernAVPlayer(_ player: ModernAVPlayer, didItemDurationChange itemDuration: Double?) {
        
        //EditVC is observing this Notification
        print("Message from RemotePlayHelper: didItemDurationChange \(itemDuration)")
        let userInfoKey = "UserInfo"
        let userInfo: [AnyHashable: Any] = [userInfoKey: itemDuration]
        NotificationCenter.default.post(name: .didItemDurationChange, object: nil, userInfo: userInfo)
        
    }
}

extension Notification.Name {
    static let playingAudioChange = Notification.Name("playingAudioChange")
    static let didItemPlayToEndTime = Notification.Name("didItemPlayToEndTime")
    static let didCurrentTimeChange = Notification.Name("didCurrentTimeChange")
    static let didStateChange = Notification.Name("didStateChange")
    static let remoteURLDidSelect = Notification.Name("remoteURLDidSelect")
    static let didItemDurationChange = Notification.Name("didItemDurationChange")
    
    
}
