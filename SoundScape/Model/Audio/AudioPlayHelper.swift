//
//  AudioHelper.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/18.
//

import Foundation
import AVFoundation

class AudioPlayHelper: NSObject {
    
    // MARK: - properties
    
    static let shared = AudioPlayHelper()
    
    var audioPlayer: AVAudioPlayer?
    
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
        
        guard let audioPlayer = audioPlayer else {
            return 0.0
        }
        return audioPlayer.currentTime
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
            }
            
            let userInfoKey = "UserInfo"
            let userInfo: [AnyHashable: Any] = [userInfoKey: url]
            NotificationCenter.default.post(name: .remoteURLDidSelect, object: nil, userInfo: userInfo)
            
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
        
        if let currentPlayInfo = currentPlayInfo {
            
            let playProgress = PlayProgress(currentTime: currentTime, duration: currentPlayInfo.duration)
            let userInfoKey = "UserInfo"
            let userInfo: [AnyHashable: Any] = [userInfoKey: playProgress]
            
            NotificationCenter.default.post(name: .didCurrentTimeChange, object: nil, userInfo: userInfo)
            
        } else { // play audio from local url (EditVC will get this Notification)
            
            let userInfoKey = "UserInfo"
            let userInfo: [AnyHashable: Any] = [userInfoKey: currentTime]
            NotificationCenter.default.post(name: .didCurrentTimeChange, object: nil, userInfo: userInfo)
        }

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
        audioPlayer?.currentTime = position
    }
    
    func limitCurrentTime(head: Double, tail: Double) {
        
        guard let audioPlayer = audioPlayer else { return }
        
        if audioPlayer.currentTime < head {
            if isPlaying == true {
                pause()
            }
            seek(position: head)
        }
        
        if audioPlayer.currentTime > tail {
            if isPlaying == true {
                pause()
            }
            seek(position: head)
        }
    }
    
    func setPlayInfo(playInfo: PlayInfo) {
        currentPlayInfo = playInfo
    }

}

extension AudioPlayHelper: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        NotificationCenter.default.post(name: .didItemPlayToEndTime, object: nil, userInfo: nil)
    }
}

extension Notification.Name {
    static let audioPlayHelperUpdateTime = Notification.Name("audioPlayHelperUpdateTime")
    static let audioPlayHelperDidPlayEnd = Notification.Name("audioPlayHelperDidPlayEnd")
}
