//
//  PlayerConfigurationExample.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/22.
//

import AVFoundation
import ModernAVPlayer

struct PlayerConfigurationExample: PlayerConfiguration {
    
    // Buffering State
    let rateObservingTimeout: TimeInterval = 3
    let rateObservingTickTime: TimeInterval = 0.3

    // General Audio preferences
    let preferredTimescale = CMTimeScale(NSEC_PER_SEC)
    let periodicPlayingTime: CMTime
    let audioSessionCategory = AVAudioSession.Category.playback

    // Reachability Service
    let reachabilityURLSessionTimeout: TimeInterval = 3
    //swiftlint:disable:next force_unwrapping
    let reachabilityNetworkTestingURL = URL(string: "https://www.google.com")!
    let reachabilityNetworkTestingTickTime: TimeInterval = 3
    let reachabilityNetworkTestingIteration: UInt = 10

    var useDefaultRemoteCommand = false
    
    let allowsExternalPlayback = false

    // AVPlayerItem Init Service
    let itemLoadedAssetKeys = ["playable", "duration"]

    init() {
        periodicPlayingTime = CMTime(seconds: 0.1, preferredTimescale: preferredTimescale)
    }
}
