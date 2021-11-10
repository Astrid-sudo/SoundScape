//
//  SignInManager.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/31.
//

import Foundation

class SignInManager {
    
    let firebaseManager = FirebaseManager.shared
    
    static let shared = SignInManager()
    
    var currentUserInfoFirebase: SCUser? {
        
        didSet {
            fetchUserPicFromFirebase()
            fetchCoverPicFromFirebase()
            checkUserFavoriteList()
            checkCurrentUserFollowingList()
            checkCurrentUserFollowerList()
            checkUserPicFromFirebase()
            checkCoverPicFromFirebase()
            checkBlackListFromFirebase()
        }
    }
    
    var currentUserFavoriteDocumentIDs: [String]? {
        didSet {
            NotificationCenter.default.post(name: .currentUserFavDocIDChange, object: nil, userInfo: nil)
        }
    }
    
    var currentUserFollowingList: [SCFollow]? {
        didSet {
            NotificationCenter.default.post(name: .currentUserFollowingsChange, object: nil, userInfo: nil)
        }
    }
    
    var currentUserFollowerList: [SCFollow]? {
        didSet {
            NotificationCenter.default.post(name: .currentUserFollowersChange, object: nil, userInfo: nil)
        }
    }
    
    var currentUserPic: String? {
        didSet {
            NotificationCenter.default.post(name: .currentUserPicChange, object: nil, userInfo: nil)
        }
    }
    
    var currentUserCover: String? {
        didSet {
            NotificationCenter.default.post(name: .currentUserCoverChange, object: nil, userInfo: nil)
        }
    }
    
    var currentUserBlacklist: [SCBlockUser]? {
        didSet {
            NotificationCenter.default.post(name: .currentUserBlacklistChange, object: nil, userInfo: nil)
        }
    }

    private init() {}
    
    // MARK: - user 2
    
    var currentUserID = "astridtingan"
    
    var provider = "Google"
    
    var userName = "Astrid"
    
    var userEmail = "astridtingan@gmail.com"
    
    var userPic = CommonUsage.profilePic2
    
    var profileCover = CommonUsage.profileCover2
    
    // MARK: - real user method
    
    func checkUserInFirebase(userID: String,
                             userProvider: String,
                             userEmail: String?,
                             userName: String?) {
        
        firebaseManager.checkUsersInFirebase(userID: userID) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                
            case .success(let userInfo):
                
                if userInfo.userInfoDoumentID == nil,
                   let userEmail = userEmail {
                    
                    let newUser = SCUser(userID: userID,
                                         provider: userProvider,
                                         username: userName ?? userID,
                                         userEmail: userEmail,
                                         userPic: nil,
                                         userProfileCover: nil,
                                         userInfoDoumentID: userID)
                    
                    self.firebaseManager.uploadUserToFirebase(userInfo: newUser)
                    self.currentUserInfoFirebase = newUser
                    
                } else {
                    
                    self.currentUserInfoFirebase = userInfo
                    
                }
                
            case.failure(let error):
                print("fetchUserInfo failed\(error)")
            }
        }
    }
    
    func uploadNewUserToFirebase(userID: String, provider: String, userEmail: String, userName: String) {
        
        let newUser = SCUser(userID: userID,
                             provider: provider,
                             username: userName,
                             userEmail: userEmail,
                             userPic: nil,
                             userProfileCover: nil,
                             userInfoDoumentID: userID)
        
        self.firebaseManager.uploadUserToFirebase(userInfo: newUser)
        self.currentUserInfoFirebase = newUser
        
    }
    
    func fetchUserInfoFromFirebase(userID: String) {
        
        self.firebaseManager.fetchUserInfoFromFirebase(userID: userID) { [weak self] result in
           
            guard let self = self else { return }
            
            switch result {
                
            case .success(let userInfo):
                
                self.currentUserInfoFirebase = userInfo
                
            case.failure(let error):
                print("fetchUserInfo failed\(error)")
            }
        }
    }
    
    private func checkUserFavoriteList() {
        
        guard let userProfileDocumentID = currentUserInfoFirebase?.userInfoDoumentID else { return }
        firebaseManager.checkFavoriteChange(userProfileDocumentID: userProfileDocumentID) { [weak self]
            result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let scFavorites):
                self.currentUserFavoriteDocumentIDs = scFavorites.map({$0.favoriteDocumentID})
                
            case .failure(let error):
                print("SignInManager: Failed to get favoriteDocumentID \(error)")
                
            }
        }
    }
    
    private func checkCurrentUserFollowingList() {
        guard let currentUserInfoDocumentID = currentUserInfoFirebase?.userInfoDoumentID else {
            print("SignInManager: Failed to get currentUserInfoDocumentID. ")
            return }
        firebaseManager.checkFollowingsChange(userInfoDoumentID: currentUserInfoDocumentID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let followings):
                
                self.currentUserFollowingList = followings
                
            case .failure(let error): print(error)
            }
        }
    }
    
    private func checkCurrentUserFollowerList() {
        guard let currentUserInfoDocumentID = currentUserInfoFirebase?.userInfoDoumentID else {
            print("SignInManager: Failed to get currentUserInfoDocumentID. ")
            return }
        firebaseManager.checkFollowersChange(userInfoDoumentID: currentUserInfoDocumentID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let followers):
                
                self.currentUserFollowerList = followers
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func checkUserPicFromFirebase() {
        
        guard let userID = currentUserInfoFirebase?.userInfoDoumentID else { return }
        
        self.firebaseManager.checkUserPicChange(userInfoDoumentID: userID) { result in
            switch result {
            case .success(let picture):
                self.currentUserPic = picture.picture
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchUserPicFromFirebase() {
        guard let userID = currentUserInfoFirebase?.userInfoDoumentID else { return }
        firebaseManager.fetchUserPicFromFirebase(userID: userID) { result in
            switch result {
            case .success(let picture):
                self.currentUserPic = picture.picture
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func checkCoverPicFromFirebase() {
        
        guard let userID = currentUserInfoFirebase?.userInfoDoumentID else { return }
        
        self.firebaseManager.checkCoverPicChange(userInfoDoumentID: userID) { result in
            switch result {
            case .success(let picture):
                self.currentUserCover = picture.picture
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchCoverPicFromFirebase() {
        guard let userID = currentUserInfoFirebase?.userInfoDoumentID else { return }
        firebaseManager.fetchCoverPicFromFirebase(userID: userID) { result in
            switch result {
            case .success(let picture):
                self.currentUserCover = picture.picture
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func checkBlackListFromFirebase() {
        guard let userID = currentUserInfoFirebase?.userInfoDoumentID else { return }
        firebaseManager.checkBlackListChange(userInfoDoumentID: userID) { result in
            switch result {
            case .success(let users):
                self.currentUserBlacklist = users
            case .failure(let error):
                print(error)
            }
        }
    }

}

extension Notification.Name {
    static let currentUserFavDocIDChange = Notification.Name("currentUserFavDocIDChange")
    static let currentUserFollowingsChange = Notification.Name("currentUserFollowingsChange")
    static let currentUserFollowersChange = Notification.Name("currentUserFollowersChange")
    static let currentUserPicChange = Notification.Name("currentUserPicChange")
    static let currentUserCoverChange = Notification.Name("currentUserCoverChange")
    static let currentUserBlacklistChange = Notification.Name("currentUserBlacklistChange")
}
