//
//  try.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/21.
//

import UIKit
import AVFoundation
import ModernAVPlayer

class TryClass: UIViewController, AVAudioPlayerDelegate {
    
    enum InputSource {
        case URL
        case AVPlayerItem
    }
    
    // MARK: - Inputs
    
    private let player: ModernAVPlayer = {
        let conf = PlayerConfigurationExample()
        return ModernAVPlayer(config: conf, loggerDomains: [.error, .unavailableCommand])
    }()
    private let dataSource: [MediaResource] = [.live, .remote, .local, .invalid]
    //    var inputSource: InputSource!
    var inputSource = InputSource.URL
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func loadRemoteURL(_ sender: Any) {
        loadRemoteModern()
        //        playApple()
    }
    
    @IBAction func playLoaded(_ sender: Any) {
        playModern()
    }
    
    
    func playApple() {
        
        // swiftlint:disable line_length
        guard let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/mydiary-firebase.appspot.com/o/astridtingan@gmail.com%2F2HdDtNIFBDpiWJw1tFTS%2FEA753BF8-5BE5-4D98-8AF2-0840D1259D44.wav?alt=media&token=b274473c-7d84-4891-bcb4-8be7cf30aa85") else { print("failed url")
            return
        }
        
        //        guard let url = URL(string: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview18/v4/9c/db/54/9cdb54b3-5c52-3063-b1ad-abe42955edb5/mzaf_520282131402737225.plus.aac.p.m4a") else { print("failed url")
        //            return
        //        }
        // swiftlint:enable line_length
        
        //        let playerItem = AVPlayerItem(url: url)
        //        let avplayer = AVPlayer(playerItem: playerItem)
        let avplayer = AVPlayer(url: url)
        DispatchQueue.main.async {
            avplayer.play()
            //            avplayer.playImmediately(atRate: 1.0)
        }
        
    }
    
    func loadRemoteModern() {
        // swiftlint:disable line_length
        guard let url = URL(string: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview18/v4/9c/db/54/9cdb54b3-5c52-3063-b1ad-abe42955edb5/mzaf_520282131402737225.plus.aac.p.m4a") else {
            print("failed url")
            return
        }
        // swiftlint:enable line_length
        
        
//        let player = ModernAVPlayer()
//        let media = ModernAVPlayerMedia(url: url, type: .clip)
//        player.load(media: media, autostart: true)
        
                let media =  getMedia(index: 1)
                player.load(media: media, autostart: true)
        
    }
    
    func playModern() {
        player.play()
    }
    
    
    private func getMedia(index: Int) -> PlayerMedia {
        switch inputSource {
        case .URL:
            return dataSource[index].playerMedia
        case .AVPlayerItem:
            return dataSource[index].playerMediaFromItem!
        default:
            preconditionFailure()
        }
    }
    
    
}
