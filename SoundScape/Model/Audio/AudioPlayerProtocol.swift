//
//  AudioPlayerProtocol.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/24.
//

import Foundation
import UIKit

protocol AudioPlayerProtocol: AnyObject {
    
    // UI
    
    var playButton: UIButton { get }
    
    var progressView: UIView { get }
    
    var caDisplayLink: CADisplayLink? { get set }
    
    var playButtonImagePlay: UIImage? { get } // default
    
    var playButtonImagePause: UIImage? { get } // default
    
    // method
    
    func togglePlayer() // default
    
    func changeButtonImage() // default
    
    func updatePlaybackTime(notification: Notification) // default
    
}

// MARK: - default setting

extension AudioPlayerProtocol {
    
    // model
    
    var audioPlayHelper: AudioPlayHelper {
        return AudioPlayHelper.shared
    }
    
    // UI
    
    var playButtonImagePlay: UIImage? {
        UIImage(systemName: CommonUsage.SFSymbol.play)
    }
    
    var playButtonImagePause: UIImage? {
        UIImage(systemName: CommonUsage.SFSymbol.pause)
    }
    
    // method
    
    func togglePlayer() {
        if audioPlayHelper.isPlaying {
            audioPlayHelper.pause()
        } else {
            audioPlayHelper.play()
        }
    }
    
    func updatePlaybackTime(notification: Notification) {
        guard let playProgress = notification.userInfo?["UserInfo"] as? PlayProgress else { return }
        let currentTime = playProgress.currentTime
        let duration = playProgress.duration
        let timeProgress = currentTime / duration
        updateProgressWaveform(timeProgress)
    }
    
    func updateProgressWaveform(_ progress: Double) {
        let fullRect = progressView.bounds
        let newWidth = Double(fullRect.size.width) * progress
        let maskLayer = CAShapeLayer()
        let maskRect = CGRect(x: 0.0, y: 0.0, width: newWidth, height: Double(fullRect.size.height))
        let path = CGPath(rect: maskRect, transform: nil)
        maskLayer.path = path
        progressView.layer.mask = maskLayer
    }
    
    func changeButtonImage() {
        DispatchQueue.main.async {
            self.playButton.isHidden = false
            let image = self.audioPlayHelper.isPlaying ? self.playButtonImagePause : self.playButtonImagePlay
            self.playButton.setImage(image, for: .normal)
        }
    }
    
}
