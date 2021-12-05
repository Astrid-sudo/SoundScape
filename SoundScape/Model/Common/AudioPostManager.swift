//
//  AudioPostManager.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/11.
//

import Foundation

class AudioPostManager {
    
    static let shared = AudioPostManager()
    
    let firebaseManager = FirebaseManager.shared
    
    var allAudioFiles = [SCPost]() {
        didSet {
            filterBlackList()
        }
    }
    
    var currentUserBlacklist: [SCBlockUser]? {
        didSet {
            filterBlackList()
        }
    }
    
    var filteredAudioFiles = [SCPost]() {
        didSet {
            NotificationCenter.default.post(name: .allAudioPostChange, object: nil, userInfo: nil)
        }
    }
    
    // MARK: - init / deinit
    
    private  init () {
        addObserver()
        fetchDataFromFirebase()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - method
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(currentUserBlacklistChange),
                                               name: .currentUserBlacklistChange ,
                                               object: nil)
    }
    
    private func filterBlackList() {
        
        if let currentUserBlacklist = currentUserBlacklist {
            
            let blockedIDs = currentUserBlacklist.map({$0.userID})
            var shouldDisplayPosts = [SCPost]()
            
            for id in blockedIDs {
                let shouldDisplayPost = allAudioFiles.filter({$0.authorID != id })
                shouldDisplayPosts.append(contentsOf: shouldDisplayPost)
            }
            
            filteredAudioFiles = shouldDisplayPosts
            
        } else {
            
            filteredAudioFiles = allAudioFiles
        }
    }
    
    @objc func currentUserBlacklistChange() {
        currentUserBlacklist = LoggedInUserManager.shared.currentUserBlacklist
    }
    
    private func fetchDataFromFirebase() {
        _ = firebaseManager.collectionAddListener(collectionType: .allAudioFiles) { (result: Result<[SCPost], Error>) in
            
            switch result {
            case .success(let posts):
                self.allAudioFiles = posts
                
            case.failure(let error):
                print(error.localizedDescription)
                let errorMessage = error.localizedDescription
                let userInfoKey = "UserInfo"
                let userInfo: [AnyHashable: Any] = [userInfoKey: errorMessage]
                
                //Home VC will observe
                NotificationCenter.default.post(name: .fetchAudioPostError, object: nil, userInfo: userInfo)
            }
        }
    }
    
}

// MARK: - extention Notification

extension Notification.Name {
    static let allAudioPostChange = Notification.Name("allAudioPostChange")
    static let fetchAudioPostError = Notification.Name("fetchAudioPostError")
}
