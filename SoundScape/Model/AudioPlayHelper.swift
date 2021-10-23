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
    
    var isPlaying = false
    
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
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
            } catch {
                print("fail to create AVAudioPlayer")
            }
        }
    }
    
    // MARK: - init
    
    private override init() {
        super.init()
    }
    
    // MARK: - method
    
    func play() {
        audioPlayer?.play()
        isPlaying = true
    }
    
    func stop() {
        audioPlayer?.stop()
        isPlaying = false
        audioPlayer?.currentTime = 0
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
}
