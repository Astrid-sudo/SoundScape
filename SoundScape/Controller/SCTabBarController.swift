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
    
    let audioPlayerWindow = AudioPlayerWindow()
    
    private var dontShowDetailConstraint = NSLayoutConstraint()
    
    private var showDetailConstraint = NSLayoutConstraint()
    
    var soundDetailVC: SoundDetailVC?

    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .orange
        audioPlayerWindow.delegate = self
//        showAudioPlayer()
        addDetailPage()
    }
    
    // MARK: - method
    
    func showAudioPlayer() {
        
        if let audioPlayerWindow = audioPlayerWindow.window {
            view.addSubview(audioPlayerWindow)
        }
    }
    
    private func addDetailPage() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SoundDetailVC") as? SoundDetailVC else { return }

        self.soundDetailVC = vc
        guard let soundDetailVC = soundDetailVC else { return }
        soundDetailVC.delegate = self
        
      view.addSubview(soundDetailVC.view)
        soundDetailVC.view.translatesAutoresizingMaskIntoConstraints = false
      
        dontShowDetailConstraint = soundDetailVC.view.topAnchor.constraint(equalTo: view.bottomAnchor)
        showDetailConstraint = soundDetailVC.view.topAnchor.constraint(equalTo: view.topAnchor)
      
      NSLayoutConstraint.activate([
        soundDetailVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        soundDetailVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        soundDetailVC.view.heightAnchor.constraint(equalToConstant: CommonUsage.screenHeight),
        dontShowDetailConstraint
      ])
      
        soundDetailVC.view.isHidden = true
    }

}

extension SCTabBarController: DetailPageShowableDelegate {
    
    func showDetailPage() {
        
        guard let soundDetailVC = soundDetailVC else { return }
        
        audioPlayerWindow.vc.timer?.invalidate()
        
        soundDetailVC.updateUI()

        dontShowDetailConstraint.isActive = false
        showDetailConstraint.isActive = true

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
          soundDetailVC.view.isHidden = false
            self.view.layoutIfNeeded()
        }
        
        
        
    }
    
    func leaveDetailPage() {
        
        audioPlayerWindow.vc.updateUI()
        
        showDetailConstraint.isActive = false

        dontShowDetailConstraint.isActive = true

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
            self.view.layoutIfNeeded()
        }
    }
    
}

