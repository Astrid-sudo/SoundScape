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
                        preset: AlertIcon,
                        completion: (() -> Void)?) {

        // SPAlert 5.x uses AlertKit API
        AlertKitAPI.present(
            title: title,
            subtitle: message,
            icon: preset,
            style: .iOS17AppleMusic,
            haptic: .success
        )
        completion?()
    }

}
