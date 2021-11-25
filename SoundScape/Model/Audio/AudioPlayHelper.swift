//
//  AudioHelper.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/18.
//

import Foundation
import AVFoundation

struct PlayInfo {
    let title: String
    let author: String
    let content: String
    let duration: Double
    let documentID: String
    let authorUserID: String
    let audioImageNumber: Int
    let authorAccountProvider: String
}

struct PlayProgress {
    let currentTime: Double
    let duration: Double
}

class AudioPlayHelper: NSObject {
    
    // MARK: - properties
    
    static let shared = AudioPlayHelper()
    
    private var audioPlayer: AVAudioPlayer?
    
    var displayLink: CADisplayLink?
    
    var isPlaying = false {
        
        didSet {
            NotificationCenter.default.post(name: .didItemPlayToEndTime, object: nil, userInfo: nil)
            if isPlaying == false {
                displayLink?.invalidate()
            }
        }
    }
    
    var currentTime: Double {
        
        set {
            audioPlayer?.currentTime = newValue
            postNotification()
        }
        
        get {
            guard let audioPlayer = audioPlayer else {
                return 0.0
            }
            return audioPlayer.currentTime
        }
        
        
    }
    
    var duration: Double {
        guard let audioPlayer = audioPlayer else {
            return 0.0
        }
        return audioPlayer.duration
    }
    
    var url: URL? {
        didSet {
            
            stop()
            currentPlayInfo = nil
            
            guard let url = url else { return }
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
            } catch {
                print("fail to create AVAudioPlayer")
                NotificationCenter.default.post(name: .audioPlayHelperError, object: nil, userInfo: nil)
                
            }
            
            let userInfoKey = "UserInfo"
            let userInfo: [AnyHashable: Any] = [userInfoKey: duration]
            NotificationCenter.default.post(name: .didItemDurationChange, object: nil, userInfo: userInfo)
            
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
    
    private override init() {
        super.init()
    }
    
    // MARK: - method
    
    @objc func postNotification() {
        let playProgress = PlayProgress(currentTime: currentTime, duration: duration)
        let userInfoKey = "UserInfo"
        let userInfo: [AnyHashable: Any] = [userInfoKey: playProgress]
        NotificationCenter.default.post(name: .didCurrentTimeChange, object: nil, userInfo: userInfo)
    }
    
    func play() {
        guard let audioPlayer = audioPlayer else {
            return
        }
        audioPlayer.play()
        isPlaying = true
        displayLink = CADisplayLink(target: self, selector: #selector(postNotification))
        displayLink?.add(to: RunLoop.main, forMode: .common)
    }
    
    func stop() {
        audioPlayer?.stop()
        isPlaying = false
        audioPlayer?.currentTime = 0
    }
    
    func pause() {
        guard let audioPlayer = audioPlayer else {
            return
        }
        audioPlayer.pause()
        isPlaying = false
    }
    
    func seek(position: Double) {
        currentTime = position * duration
        print(audioPlayer?.currentTime)
        print(currentTime)
    }
    
    func setPlayInfo(playInfo: PlayInfo) {
        currentPlayInfo = playInfo
    }
    
}

// MARK: - conform to AVAudioPlayerDelegate

extension AudioPlayHelper: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        NotificationCenter.default.post(name: .didItemPlayToEndTime, object: nil, userInfo: nil)
    }
}

// MARK: - extension Notification.Name

extension Notification.Name {
    static let audioPlayHelperUpdateTime = Notification.Name("audioPlayHelperUpdateTime")
    static let audioPlayHelperDidPlayEnd = Notification.Name("audioPlayHelperDidPlayEnd")
    static let audioPlayHelperError = Notification.Name("audioPlayHelperError")
}
