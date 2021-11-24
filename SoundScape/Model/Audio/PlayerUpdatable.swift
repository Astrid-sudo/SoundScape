//
//  PlayerUpdatable.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/24.
//

import Foundation
import UIKit

protocol PlayerUpdatable: AnyObject {
    
    // model
    
    var audioPlayHelper: AudioPlayHelper { get } // default
    
    //    var nowPlayingURL: URL? { get set }
    
    // UI
    
    //    var playButtonColor: UIColor { get set } // default
    
    var playButton: UIButton { get } // default
    
    var caDisplayLink: CADisplayLink? { get set }
    
    var playButtonImagePlay: UIImage { get } // default
    
    var playButtonImagePause: UIImage { get } // default
    
    var playButtonImageStop: UIImage { get } // default
    
    // method
    
    func manipulatePlayer()
    
    func updatePlaybackTime(notification: Notification)
    
    func updatePlayInfo(notification: Notification)
    
    func changeButtonImage() // default
    
}

//    default setting

extension PlayerUpdatable {
    
    // model
    var audioPlayHelper: AudioPlayHelper {
        return AudioPlayHelper.shared
    }
    
    // UI
    var playButtonImagePlay: UIImage {
        get {
            let image = UIImage(systemName: CommonUsage.SFSymbol.play) ?? UIImage()
            return image
        }
    }
    
    var playButtonImagePause: UIImage {
        get {
            let image = UIImage(systemName: CommonUsage.SFSymbol.pause) ?? UIImage()
            return image
        }
    }
    
    var playButtonImageStop: UIImage {
        let image = UIImage(systemName: CommonUsage.SFSymbol.stopPlay) ?? UIImage()
        return image
    }
    
}

