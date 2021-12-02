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
    
    static let reuseIdentifier = String(describing: SCTabBarController.self)
    
    private var dontShowDetailConstraint = NSLayoutConstraint()
    
    private var showDetailConstraint = NSLayoutConstraint()
    
//    var soundDetailVC: SoundDetailVC?
    
    var soundDetailVC: SoundDetailViewController?

    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        tabBar.barTintColor = UIColor(named: CommonUsage.scBlue)
        tabBar.tintColor = UIColor(named: CommonUsage.scWhite)
    }
    
    // MARK: - method
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
      
        if item.tag == 2 && AudioPlayHelper.shared.isPlaying {
            popStopPlayingAlert()
     }
    }
    
    private func popStopPlayingAlert() {

        let alert = UIAlertController(title: "Audio will stop playing.",
                                      message: "Navigate to upload flow will stop the audio you are listening. Do you still like to proceed?",
                                      preferredStyle: .alert )
        let okButton = UIAlertAction(title: "Go upload", style: .default) {[weak self] _ in
            guard let self = self else { return }
            self.selectedIndex = 2
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func addDetailPage() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        guard let vc = storyboard.instantiateViewController(withIdentifier: "SoundDetailVC") as? SoundDetailVC else { return }
        
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SoundDetailViewController") as? SoundDetailViewController else { return }


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

// MARK: - conform to UITabBarControllerDelegate

extension SCTabBarController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
      guard let viewControllers = self.viewControllers else { return true }

      if viewController == viewControllers[2] {

          if !AudioPlayHelper.shared.isPlaying {
          return true

        } else {
          return false
        }
      }

      return true
    }
}

// MARK: - conform to DetailPageShowableDelegate

extension SCTabBarController: DetailPageShowableDelegate {
    
    func showDetailPage() {
        
        guard let soundDetailVC = soundDetailVC else { return }
        
        dontShowDetailConstraint.isActive = false
        showDetailConstraint.isActive = true

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
          soundDetailVC.view.isHidden = false
            self.view.layoutIfNeeded()
        }
        
    }
    
    func leaveDetailPage() {
        
        showDetailConstraint.isActive = false

        dontShowDetailConstraint.isActive = true

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
            self.view.layoutIfNeeded()
        }
    }
    
}
