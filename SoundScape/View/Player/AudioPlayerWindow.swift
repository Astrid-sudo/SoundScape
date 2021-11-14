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
    
    let windowSmallSizeHeight: CGFloat = 60.adjusted

    lazy var windowSmallSizeY: CGFloat = {
        let safeAreaHeight = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 45.adjusted
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let sCTabBarController = storyboard.instantiateViewController(identifier: "SCTabBarController") as? SCTabBarController else { return 41.0 }
        let tabBarHeight = sCTabBarController.tabBar.frame.size.height


        let windowSmallSizeY = CommonUsage.screenHeight - safeAreaHeight - tabBarHeight - windowSmallSizeHeight + 1
        return windowSmallSizeY
    }()
    
    private lazy var windowSmallFrame: CGRect = CGRect(x: 0, y: windowSmallSizeY, width: CommonUsage.screenWidth, height: windowSmallSizeHeight)
    
    private let windowFullFrame: CGRect = CGRect(x: 0, y: 0, width: CommonUsage.screenWidth, height: CommonUsage.screenHeight)

    // MARK: - properties
    
    // MARK: - init
    
    private init() {
        window = UIWindow(frame: windowSmallFrame)
        
        guard let scene = UIApplication.shared
                .connectedScenes.filter({ $0.activationState == .foregroundActive }).first as? UIWindowScene else { return }
        guard let window = window else { return }
        window.windowScene = scene

        window.windowLevel = .statusBar - 1
        window.rootViewController = vc
        window.isHidden = true
        window.makeKeyAndVisible()
        vc.delegate = self
    }
    
    // MARK: - method
    
    func show() {
        window?.isHidden = false
    }
    
    func showVC() {
        window?.rootViewController?.view.isHidden = false
    }
    
    func hide() {
        window?.isHidden = true
    }

    func makeSmallFrame() {
        window?.frame =  windowSmallFrame
    }
    
    func makeFullFrame() {
        window?.frame =  windowFullFrame
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
            
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn) { [weak self] in
                guard let self = self else { return }

                window.frame = self.windowFullFrame
                window.layoutIfNeeded()
            }

        }
        
    }
    
}
