//
//  AudioDownloadManager.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/16.
//

import UIKit

class AudioDownloadManager {
    
    static let shared = AudioDownloadManager()
    
    private init() {}
    
    func downloadRemoteURL(documentID: String,
                           remoteURL: URL,
                           completion: @escaping (_ localURL: URL) -> Void,
                           errorCompletion: @escaping (_ errorMessage: String) -> Void) {
        // swiftlint:disable line_length
        let cachesFolderURL = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        // swiftlint:enable line_length

        let audioFileURL = cachesFolderURL?.appendingPathComponent("\(documentID).m4a")
        guard let localURL = audioFileURL else {
            errorCompletion("Cant find this audio file.")
            return
        }

        guard !localFileExists(documentID: documentID) else {
            print("File \(documentID) already downloaded before")
            completion(localURL)
            return }
        
        let task = URLSession.shared.downloadTask(with: remoteURL) { downloadedURL, _, error in
            
            if let error = error {
                errorCompletion(error.localizedDescription)
            }
            
            guard let downloadedURL = downloadedURL else { return }
            try? FileManager.default.copyItem(at: downloadedURL, to: localURL)
            completion(localURL)
            print("----------------download and save to  \(localURL) ------------------------")
        }
        task.resume()
    }
    
    private func localFileExists(documentID: String) -> Bool {
        // swiftlint:disable line_length
         let cachesFolderURL = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        // swiftlint:enable line_length
         let audioFileURL = cachesFolderURL?.appendingPathComponent("\(documentID).m4a")
         guard let localURL = audioFileURL else { return false }
        if FileManager.default.fileExists(atPath: localURL.path) {
            return true
        } else {
            return false
        }
    }
    
}

