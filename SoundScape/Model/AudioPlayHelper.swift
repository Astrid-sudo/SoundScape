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
    
    //    var avPlayer: AVPlayer?
    //
    //    var playerItem: AVPlayerItem?
    //
    //    var timeObserverToken: Any?
    
    var timer: Timer?
    
    var isPlaying = false {
        
        didSet {
            if isPlaying == false {
                timer?.invalidate()
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
            guard let url = url else { return }
            
            //            avPlayer =  AVPlayer(url: url)
            //            guard let avPlayer = avPlayer else { return }
            //            playerItem = avPlayer.currentItem
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
            } catch {
                print("fail to create AVAudioPlayer")
            }
            
            //            addPeriodicTimeObserver()
        }
    }
    
    // MARK: - init
    
    private override init() {
        super.init()
    }
    
    deinit {
        //        removePeriodicTimeObserver()
    }
    
    // MARK: - method
    
    @objc func postNotification() {
        let userInfoKey = "UserInfo"
        let userInfo: [AnyHashable: Any] = [userInfoKey: currentTime]
        NotificationCenter.default.post(name: .audioPlayHelperUpdateTime, object: nil, userInfo: userInfo)
    }
    
    func play() {
        
        guard let audioPlayer = audioPlayer else {
            return
        }

        
        audioPlayer.play()
        isPlaying = true
        
        timer = Timer.scheduledTimer(timeInterval: 0.5,
                                     target: self,
                                     selector: #selector(postNotification),
                                     userInfo: nil,
                                     repeats: true)
        
        
        //        avPlayer?.play()
        //        addPeriodicTimeObserver()
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
        
        //        avPlayer?.pause()
        //        removePeriodicTimeObserver()
    }
    
    //    func addPeriodicTimeObserver() {
    //        // Notify every half second
    //        let timeScale = CMTimeScale(NSEC_PER_SEC)
    //        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
    //        guard let avPlayer = avPlayer,
    //        let playerItem = playerItem else {
    //            return
    //        }
    
    //        timeObserverToken = avPlayer.addPeriodicTimeObserver(forInterval: time,
    //                                                             queue: .main) { [weak self]
    //            time in
    //            // update player transport UI
    //            let currentTime = playerItem.currentTime()
    //            let userInfoKey = "UserInfo"
    //            let userInfo: [AnyHashable: Any] = [userInfoKey: time]
    //            NotificationCenter.default.post(name: .audioPlayHelperUpdateTime, object: nil, userInfo: userInfo)
    //        }
    //    }
    
    //    func removePeriodicTimeObserver() {
    //        guard let avPlayer = avPlayer else {
    //            return
    //        }
    //
    //        if let timeObserverToken = timeObserverToken {
    //            avPlayer.removeTimeObserver(timeObserverToken)
    //            self.timeObserverToken = nil
    //        }
    //    }
}

extension AudioPlayHelper: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        NotificationCenter.default.post(name: .audioPlayHelperDidPlayEnd, object: nil, userInfo: nil)
        isPlaying = false
    }
}

extension Notification.Name {
    static let audioPlayHelperUpdateTime = Notification.Name("audioPlayHelperUpdateTime")
    static let audioPlayHelperDidPlayEnd = Notification.Name("audioPlayHelperDidPlayEnd")
}
