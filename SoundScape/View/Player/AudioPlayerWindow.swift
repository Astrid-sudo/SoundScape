//
//  AudioPlayerWindow.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/19.
//

import UIKit

@objc protocol DetailPageShowableDelegate: AnyObject {
    @objc optional func showDetailPage()
    @objc optional func leaveDetailPage()
}

class AudioPlayerWindow {
    
    // MARK: - UI properties
    
    static let shared = AudioPlayerWindow()
    
    var window: UIWindow?
    
    let vc = AudioPlayerVC()
    
    weak var delegate: DetailPageShowableDelegate?
    
    // MARK: - properties
    
    // MARK: - init
    
    private init() {
        window = UIWindow(frame: CGRect(x: 0, y: CommonUsage.screenHeight - 110,
                                        width: CommonUsage.screenWidth, height: 60))
        guard let scene = UIApplication.shared
                .connectedScenes.filter({ $0.activationState == .foregroundActive }).first as? UIWindowScene else { return }
        guard let window = window else { return }
        window.windowScene = scene

        window.windowLevel = .alert
        window.rootViewController = vc
        window.isHidden = true
        window.makeKeyAndVisible()
        vc.delegate = self
    }
    
    // MARK: - method
    
    func show() {
        window?.isHidden = false

    }
    
//    func resizeFrame(newWidth: CGFloat, newHeight: CGFloat) {
//        if let originalFrame = window?.frame {
//            let newSize = CGSize(width: newWidth, height: newHeight)
//            window?.setFrame(CGRect(origin: originalFrame.origin, size: newSize), display: true, animate: true)
//        }
//    }
    
    
}

extension AudioPlayerWindow: DetailPageShowableDelegate {
    
    func showDetailPage() {
        
        delegate?.showDetailPage?()

        if let window = window {
            
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn) {
                window.frame = CGRect(x: 0, y: 0, width: CommonUsage.screenWidth, height: CommonUsage.screenHeight)
                window.layoutIfNeeded()
            }

            
        }
        
    }
    
}
