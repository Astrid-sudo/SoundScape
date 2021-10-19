//
//  SCTabBarController.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/19.
//

import UIKit

class SCTabBarController: UITabBarController {
    
    // MARK: - properties
    
    // MARK: - UI properties
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .orange
        showAudioPlayer()
    }
    
    // MARK: - method
    var audioPlayerWindow: UIWindow?
    
    func showAudioPlayer() {
        audioPlayerWindow = AudioPlayerWindow().window
        
        if let audioPlayerWindow = audioPlayerWindow {
            view.addSubview(audioPlayerWindow)
        }
    }
    
}
