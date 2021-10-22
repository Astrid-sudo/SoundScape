//
//  MediaResource.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/22.
//

import AVFoundation
import ModernAVPlayer

enum MediaResource: CustomStringConvertible {
    case live
    case remote
    case local
    case invalid
    case custom(String)

    var description: String {
        switch self {
        case .live:
            return "Live MP3"
        case .local:
            return "Local MP3"
        case .remote:
            return "Remote MP3"
        case .invalid:
            return "Invalid file - txt"
        case .custom:
            return "Custom url"
        }
    }

    var type: MediaType {
        switch self {
        case .live:
            return .stream(isLive: true)
        case .local, .remote, .invalid, .custom:
            return .clip
        }
    }
    /*
     "http://media.radiofrance-podcast.net/podcast09/13100-17.01.2017-ITEMA_21199585-0.mp3"
     */

    var url: URL {
        switch self {
        case .live:
            return URL(string: "http://direct.franceinter.fr/live/franceinter-midfi.mp3")!
        case .local:
            return URL(fileURLWithPath: Bundle.main.path(forResource: "AllNew", ofType: "mp3")!)
        case .remote:
                    // swiftlint:disable line_length

            return URL(string: "https://firebasestorage.googleapis.com/v0/b/mydiary-firebase.appspot.com/o/astridtingan@gmail.com%2F2HdDtNIFBDpiWJw1tFTS%2FEA753BF8-5BE5-4D98-8AF2-0840D1259D44.wav?alt=media&token=b274473c-7d84-4891-bcb4-8be7cf30aa85")!
                // swiftlint:enable line_length

        case .invalid:
            return URL(fileURLWithPath: Bundle.main.path(forResource: "noreason", ofType: "txt")!)
        case .custom(let customUrl):
            return URL(string: customUrl)!
        }
    }

    var metadata: ModernAVPlayerMediaMetadata? {
        switch self {
        case .live:
            return ModernAVPlayerMediaMetadata(title: "Le live",
                                               albumTitle: "Album0",
                                               artist: "Artist0",
                                               image: UIImage(named: "sennaLive")?.jpegData(compressionQuality: 1.0))
        case .local:
            return ModernAVPlayerMediaMetadata(title: "Local clip",
                                               albumTitle: "Album2",
                                               artist: "Artist2",
                                               image: UIImage(named: "ankierman")?.jpegData(compressionQuality: 1.0),
                                               remoteImageUrl: URL(string: "https://goo.gl/U4QoQj"))
        case .remote:
            return ModernAVPlayerMediaMetadata(title: "Remote clip",
                                               albumTitle: "Album1",
                                               artist: "Artist1",
                                               image: nil)
        case .invalid, .custom:
            return nil
        }
    }

    var item: AVPlayerItem {
        return AVPlayerItem(url: url)
    }

    var playerMedia: ModernAVPlayerMedia {
        return ModernAVPlayerMedia(url: url, type: type, metadata: metadata)
    }

    var playerMediaFromItem: ModernAVPlayerMediaItem? {
        return ModernAVPlayerMediaItem(item: item, type: type, metadata: metadata)
    }
}
