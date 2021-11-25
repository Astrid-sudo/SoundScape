//
//  PlayerUIProtocol.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/24.
//

import Foundation
import UIKit

protocol PlayerUIProtocol: AnyObject {
    
    // UI
    
    var playButton: UIButton { get }
    
    var caDisplayLink: CADisplayLink? { get set }
    
    var playButtonImagePlay: UIImage { get } // default
    
    var playButtonImagePause: UIImage { get } // default
    
    var progressView: UIView { get }
    
    // method
    
    func manipulatePlayer() // default
    
    func updatePlaybackTime(notification: Notification) // default
    
    func updatePlayInfo(notification: Notification) // default
    
    func changeButtonImage() // default
    
}

//    default setting

extension PlayerUIProtocol {
    
    // model
    var audioPlayHelper: AudioPlayHelper {
        return AudioPlayHelper.shared
    }
    
    // UI
    var playButtonImagePlay: UIImage {
        let image = UIImage(systemName: CommonUsage.SFSymbol.play) ?? UIImage()
        return image
    }
    
    var playButtonImagePause: UIImage {
        let image = UIImage(systemName: CommonUsage.SFSymbol.pause) ?? UIImage()
        return image
    }
    
    func manipulatePlayer() {
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
        if audioPlayHelper.isPlaying {
            DispatchQueue.main.async {
                self.playButton.isHidden = false
                self.playButton.setImage(self.playButtonImagePause, for: .normal)
            }
        }
        if !audioPlayHelper.isPlaying {
            DispatchQueue.main.async {
                self.playButton.isHidden = false
                self.playButton.setImage(self.playButtonImagePlay, for: .normal)
            }
        }
    }
    
}

