//
//  LottieWrapper.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/18.
//

import UIKit
import Lottie

class LottieWrapper {
    
    static let shared = LottieWrapper()
    
    private init () {}
    
    func webLoadingLottie(frame: CGRect) -> AnimationView {
        let animationView = AnimationView(name: "blueStripeLoading")
        animationView.frame = frame
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        return animationView
    }
    
    
    
    
    
    
}
