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
    
    func blueStripeLoadingView(frame: CGRect) -> AnimationView {
        let animationView = AnimationView(name: "blueStripeLoading")
        animationView.frame = frame
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        return animationView
    }
    
    func whiteStripeLoadingView(frame: CGRect) -> AnimationView {
        let animationView = AnimationView(name: "whiteStripeLoading")
        animationView.frame = frame
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        return animationView
    }

    func greyStripeLoadingView(frame: CGRect) -> AnimationView {
        let animationView = AnimationView(name: "greyStripeLoading")
        animationView.frame = frame
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        return animationView
    }
    
    func womanWalkingAnimationView(frame: CGRect) -> AnimationView {
        let animationView = AnimationView(name: "lf30_editor_xgoxkd3f")
        animationView.frame = frame
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        return animationView
    }


    
    
    
    
}
