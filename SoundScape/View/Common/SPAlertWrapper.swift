//
//  SPAlertWrapper.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/19.
//

import UIKit
import SPAlert

class SPAlertWrapper {
    
    static let shared = SPAlertWrapper()
    
    private init() {}
    
    func presentSPAlert(title: String,
                        message: String?,
                        preset: SPAlertIconPreset,
                        completion: (() -> Void)?) {
        
        SPAlert.present(title: title,
                        message: message,
                        preset: preset,
                        completion: completion)
    }
    
    
    
    
}
