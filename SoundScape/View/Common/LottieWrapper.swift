//
//  LottieWrapper.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/18.
//

import UIKit
import Lottie

enum LottieJSONType {
    
    case blueStripeLoading
    case whiteStripeLoading
    case greyStripeLoading
    case womanWalking
    case commentLoading
    case waveformBounce
    
    var name: String {
        
        switch self {
        case .blueStripeLoading:
            return "blueStripeLoading"
            
        case .whiteStripeLoading:
            return "whiteStripeLoading"
            
        case .greyStripeLoading:
            return "greyStripeLoading"
        
        case .womanWalking:
            return "lf30_editor_xgoxkd3f"
            
        case .commentLoading:
            return "lf30_editor_r2yecdir"
            
        case .waveformBounce:
            return "lf30_editor_nhixegma"
       
        }
    }
}

class LottieWrapper {
    
    static let shared = LottieWrapper()
    
    private init () {}
    
    func createLottieAnimationView(lottieType: LottieJSONType,
                                   frame: CGRect) -> AnimationView {
        let animationView = AnimationView(name: lottieType.name)
        animationView.frame = frame
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        return animationView
    }
    
}
