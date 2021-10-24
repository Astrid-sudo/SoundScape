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
    
    static let font = "PingFang TC"
    static let fakeMap = "fakeMap"
    static let audioImage = "audioImage"
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
        static let right = "chevron.right"
        
    }
    
    struct Text {
        static let title = "Title"
        static let description = "Description"
        static let category = "Category"
        static let pinOnMap = "Pin On Map"
        static let upload = "UPLOAD"
    }
    
    struct CollectionName {
        static let allUsers = "AllUsers"
        static let allAudioFiles = "AllAudioFiles"
        static let allLocations = "AllLocations"
    }
    
}
