//
//  Common.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/19.
//

import Foundation
import UIKit
import AVFoundation

struct CommonUsage {
    
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
    static let base: CGFloat = 375
    static var ratio: CGFloat {
        return screenWidth / base
    }
    
    static let safeAreaHeight = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 45.adjusted
    
    static var tabBarHeight: CGFloat {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let sCTabBarController = storyboard.instantiateViewController(identifier: "SCTabBarController") as? SCTabBarController else { return 0 }
        let tabBarHeight = sCTabBarController.tabBar.frame.size.height
        return tabBarHeight
    }
    
    static var audioImages: [UIImage?] = [UIImage(named: CommonUsage.animalDog),
                                          UIImage(named: CommonUsage.animalCat),
                                          UIImage(named: CommonUsage.animalCatPaw),
                                          UIImage(named: CommonUsage.animalDuck),
                                          UIImage(named: CommonUsage.city),
                                          UIImage(named: CommonUsage.meaningfulCake),
                                          UIImage(named: CommonUsage.meaningfulFlower),
                                          UIImage(named: CommonUsage.meaningfulWine),
                                          UIImage(named: CommonUsage.natureMountain),
                                          UIImage(named: CommonUsage.natureOcean),
                                          UIImage(named: CommonUsage.natureRiver),
                                          UIImage(named: CommonUsage.uniqueRice),
                                          UIImage(named: CommonUsage.untitledArtwork),
                                          UIImage(named: CommonUsage.cityCafe)
    ]
    
    static let privacyPolicyURL = "https://www.privacypolicies.com/live/441a63bf-7dcb-427a-8f2c-c13a9a69e488"
    static let LAEUURL = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
    
    static let fontBungee = "Bungee-Regular"
    static let font = "PingFang TC"
    static let fontSemibold = "PingFangTC-Semibold"
    
    static let profileCover4 = "profileCover4"
    static let yeh1024 = "yeh1024"
    static let launchScreen1 = "launchScreen1"
    
    static let animalDog = "Animal_Dog"
    static let animalCat = "Animal_Cat"
    static let animalCatPaw = "Animal_CatPaw"
    static let animalDuck = "Animal_Duck"
    static let city = "City"
    static let cityCafe = "City_Cafe"
    static let meaningfulCake = "Meaningful_cake"
    static let meaningfulFlower = "Meaningful_Flower"
    static let meaningfulWine = "Meaningful_Wine"
    static let natureMountain = "Nature_Mountain"
    static let natureOcean = "Nature_Ocean"
    static let natureRiver = "Nature_River"
    static let uniqueRice = "Unique_Rice"
    static let untitledArtwork = "Untitled_Artwork 4"
    
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
    
    static let logInBlue = "logInBlue"
    
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
        static let back = "chevron.backward"
        static let paperplaneFill = "paperplane.fill"
        static let photo = "photo"
        static let map = "map"
        static let headphonesCircleFill = "headphones.circle.fill"
        static let ellipsis = "ellipsis"
        static let comment = "text.bubble.fill"
        static let trim = "timeline.selection"
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
        static let appName = "SoundScape_"
        static let searchPlace = "Search Place"
        static let audioImage = "Pick a cover"
        static let logInNotice = "By using SoundScape you agree to accept our"
        static let privacyPolicy = "Privacy Policy"
        static let audioLengthNotice = "Only support upload audio file between 5 to 60 seconds."
        static let audioLengthNoticeWhenRecord = "Only support upload audio file between 5 to 60 seconds. You may edit audio on next page."
        static let noResultTitle =  "No result."
        static let searchHintLabel = "Search by title, author, or content."
        static let block = "block"
        static let myProfile = "My Profile"
        static let record = "Record"
        static let selectFile = "Select File"
        static let trim = "Trim"
        static let deleteAudioMessage = "Long press on image to delete the audio."
        static let laeuButton = "LICENSED APPLICATION END USER LICENSE AGREEMENT"
        static let and = "and"
        static let recordAgain = "(record again)"
        static let pinOnMapHint = "Tap to add location"
        static let finish = "Finish adding marker"
        static let loading = "loading..."
    }
    
}

struct Constant {
    static let allUsers = "AllUsers"
    static let allAudioFiles = "AllAudioFiles"
    static let allLocations = "AllLocations"
    static let comments = "Comments"
    static let followedBy = "followedBy"
    static let following = "following"
    static let myFavorite = "myFavorite"
    static let profilePicture = "profilePicture"
    static let blackList = "blackList"
    static let userPic = "userPic"
    static let coverPic = "coverPic"
    
    static let createdTime = "createdTime"
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

extension CGFloat {
    
    var adjusted: CGFloat {
        
        return self * CommonUsage.ratio
    }
}

extension Double {
    
    var adjusted: CGFloat {
        
        return CGFloat(self) * CommonUsage.ratio
    }
}
extension Int {
    
    var adjusted: CGFloat {
        
        return CGFloat(self) * CommonUsage.ratio
    }
}

extension UIViewController {
    
    func popErrorAlert(title: String?, message: String?) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert )
        
        let okButton = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
    
}

extension Notification.Name {
    static let playingAudioChange = Notification.Name("playingAudioChange")
    static let didItemPlayToEndTime = Notification.Name("didItemPlayToEndTime")
    static let didCurrentTimeChange = Notification.Name("didCurrentTimeChange")
    static let didStateChange = Notification.Name("didStateChange")
    static let remoteURLDidSelect = Notification.Name("remoteURLDidSelect")
    static let didItemDurationChange = Notification.Name("didItemDurationChange")
}
