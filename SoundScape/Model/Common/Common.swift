//
//  Common.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/19.
//

import Foundation
import UIKit

struct CommonUsage {
    
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
    
    static let fontBungee = "Bungee-Regular"
    static let font = "PingFang TC"
    static let fontSemibold = "PingFangTC-Semibold"

    static let fakeMap = "fakeMap"
    static let audioImage = "audioImage"
    static let audioImage2 = "audioImage2"
    static let profileCover = "profileCover"
    static let profileCover2 = "profileCover2"
    static let profileCover3 = "profileCover3"
    static let profileCover4 = "profileCover4"
    static let profileCover5 = "profileCover5"

    static let profilePic = "profilePic"
    static let profilePic2 = "profilePic2"
    static let profilePic3 = "profilePic3"
    static let profilePic4 = "profilePic4"
    static let profilePic5 = "profilePic5"

    static let line = "line"
    
    static let scDarkGreen = "scDarkGreen"
    static let scGreen = "scGreen"
    static let scLightGreen = "scLightGreen"
    
    static let scBlue = "scBlue"
    static let scLightBlue = "scLightBlue"
    static let scSuperLightBlue = "scSuperLightBlue"
    
    static let scDarkYellow = "scDarkYellow"
    static let scYellow = "scYellow"
    
    static let scOrange = "scOrange"
    static let scRed = "scRed"
    
    static let scWhite = "scWhite"
    static let scGray = "scGray"
    
    struct SFSymbol {
        static let play = "play.fill"
        static let stopPlay = "stop.fill"
        static let pause = "pause.fill"
        static let record = "record.circle"
        static let stopRecord = "stop.circle"
        static let edit = "scissors"
        static let heart = "heart.fill"
        static let heartEmpty = "heart"
        static let right = "chevron.right"
        static let chevronDown = "chevron.down"
        static let paperplaneFill = "paperplane.fill"

    }
    
    struct Text {
        static let title = "Title"
        static let description = "Description"
        static let category = "Category"
        static let pinOnMap = "Pin On Map"
        static let upload = "UPLOAD"
        static let searchResult = "Search Result"
        static let search = "Search"
        static let followers = "followers"
        static let followings = "followings"
        static let settings = "settings"
        static let follow = "follow"
        static let unfollow = "unfollow"
        static let comments = "Comments"
        static let addComment = "Add comment..."

    }
    
    struct CollectionName {
        static let allUsers = "AllUsers"
        static let allAudioFiles = "AllAudioFiles"
        static let allLocations = "AllLocations"
        static let comments = "Comments"
    }
    
}

extension UITextField {
    
    func setLeftPaddingPoints(amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UIView {
    func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}

extension UIImageView {
    func applyBlurEffect() {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }
}
