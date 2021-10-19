//
//  AudioPlayerWindow.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/19.
//

import UIKit

class AudioPlayerWindow {
    
    // MARK: - UI properties
    
    var window: UIWindow?
    
    let vc = AudioPlayerVC()
    
    // MARK: - properties
    
    // MARK: - init
    
    init() {
        window = UIWindow(frame: CGRect(x: 0, y: CommonUsage.screenHeight - 140,
                                        width: CommonUsage.screenWidth, height: 60))
        window?.windowLevel = .alert
        window?.rootViewController = vc
        window?.isHidden = true
        window?.makeKeyAndVisible()
    }
    
    // MARK: - method
}
