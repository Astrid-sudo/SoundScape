//
//  RemoteAudioManager.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/16.
//

import UIKit

class RemoteAudioManager {
    
    static let shared = RemoteAudioManager()
    
    private init() {}
    
    func downloadRemoteURL(documentID: String, remoteURL: URL, completion: @escaping (_ localURL: URL) -> Void) {
        
        let cachesFolderURL = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let audioFileURL = cachesFolderURL?.appendingPathComponent("\(documentID).m4a")
        guard let localURL = audioFileURL else { return }

        guard !localFileExists(documentID: documentID) else {
            print("File \(documentID) already downloaded before")
            completion(localURL)
            return }
        
        let task = URLSession.shared.downloadTask(with: remoteURL) { downloadedURL, urlResponse, error in
            guard let downloadedURL = downloadedURL else { return }
            try? FileManager.default.copyItem(at: downloadedURL, to: localURL)
            completion(localURL)
            print("----------------download and save to  \(localURL) ------------------------")
        }
        task.resume()
    }
    
    private func localFileExists(documentID: String) -> Bool {
        
         let cachesFolderURL = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
         let audioFileURL = cachesFolderURL?.appendingPathComponent("\(documentID).m4a")
         guard let localURL = audioFileURL else { return false }

        if FileManager.default.fileExists(atPath: localURL.path) {
            return true
        } else {
            return false
        }
    }
    
}

