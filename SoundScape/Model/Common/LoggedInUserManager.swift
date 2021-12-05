//
//  LoggedInUserManager.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/31.
//

import Foundation

class LoggedInUserManager {
    
    let firebaseManager = FirebaseManager.shared
    
    static let shared = LoggedInUserManager()
    
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
                let errorMessage = error.localizedDescription
                let userInfoKey = "UserInfo"
                let userInfo: [AnyHashable: Any] = [userInfoKey: errorMessage]
                
                //Home VC will observe
                NotificationCenter.default.post(name: .fetchLoginUserError, object: nil, userInfo: userInfo)
                
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
        
        self.firebaseManager.documentFetchData(documentType: .userInfoDoc(userInfoDocumentID: userID)) { (result: Result<SCUser, Error>)  in
            switch result {
                
            case .success(let userInfo):
                
                self.currentUserInfoFirebase = userInfo
                
            case.failure(let error):
                print("fetchUserInfo failed\(error)")
                let errorMessage = error.localizedDescription
                let userInfoKey = "UserInfo"
                let userInfo: [AnyHashable: Any] = [userInfoKey: errorMessage]
                
                //Home VC will observe
                NotificationCenter.default.post(name: .fetchLoginUserError, object: nil, userInfo: userInfo)
            }
            
        }
    }
    
    private func checkUserFavoriteList() {
        guard let currentUserInfoDocumentID = currentUserInfoFirebase?.userInfoDoumentID else {
            print("LoggedInUserManager: Failed to get currentUserInfoDocumentID. ")
            return }
        _ = firebaseManager.collectionAddListener(collectionType: .myFavorite(userInfoDocumentID: currentUserInfoDocumentID)) { (result: Result<[SCFavorite], Error>) in
            
            switch result {
                
            case .success(let scFavorites):
                self.currentUserFavoriteDocumentIDs = scFavorites.map({$0.favoriteDocumentID})
                
            case .failure(let error):
                print("LoggedInUserManager: Failed to get favoriteDocumentID \(error)")
                let errorMessage = error.localizedDescription
                let userInfoKey = "UserInfo"
                let userInfo: [AnyHashable: Any] = [userInfoKey: errorMessage]
                
                //Home VC will observe
                NotificationCenter.default.post(name: .failedFetchFavorite, object: nil, userInfo: userInfo)
            }
        }
    }
    
    private func checkCurrentUserFollowingList() {
        guard let currentUserInfoDocumentID = currentUserInfoFirebase?.userInfoDoumentID else {
            print("LoggedInUserManager: Failed to get currentUserInfoDocumentID. ")
            return }
        _ = firebaseManager.collectionAddListener(collectionType: .following(userInfoDocumentID: currentUserInfoDocumentID)) { (result: Result<[SCFollow], Error>) in
            
            switch result {
            case .success(let followers):
                
                self.currentUserFollowingList = followers
                
            case .failure(let error):
                let errorMessage = error.localizedDescription
                let userInfoKey = "UserInfo"
                let userInfo: [AnyHashable: Any] = [userInfoKey: errorMessage]
                
                //Home VC will observe
                NotificationCenter.default.post(name: .failedFetchFollowingList, object: nil, userInfo: userInfo)
            }
        }
    }
    
    private func checkCurrentUserFollowerList() {
        guard let currentUserInfoDocumentID = currentUserInfoFirebase?.userInfoDoumentID else {
            print("LoggedInUserManager: Failed to get currentUserInfoDocumentID. ")
            return }
        _ = firebaseManager.collectionAddListener(collectionType: .followedBy(userInfoDocumentID: currentUserInfoDocumentID)) { (result: Result<[SCFollow], Error>) in
            
            switch result {
            case .success(let followers):
                
                self.currentUserFollowerList = followers
                
            case .failure(let error):
                let errorMessage = error.localizedDescription
                let userInfoKey = "UserInfo"
                let userInfo: [AnyHashable: Any] = [userInfoKey: errorMessage]
                
                //Home VC will observe
                NotificationCenter.default.post(name: .failedFetchFollowerList, object: nil, userInfo: userInfo)
            }
        }
    }
    
    func checkUserPicFromFirebase() {
        
        guard let userID = currentUserInfoFirebase?.userInfoDoumentID else { return }
        
        firebaseManager.documentAddListener(documentType: .userPicDoc(userInfoDocumentID: userID)) { (result: Result<SCPicture, Error>) in
            switch result {
            case .success(let picture):
                self.currentUserPic = picture.picture
            case .failure(let error):
                let errorMessage = error.localizedDescription
                let userInfoKey = "UserInfo"
                let userInfo: [AnyHashable: Any] = [userInfoKey: errorMessage]
                
                //Profile VC will observe
                NotificationCenter.default.post(name: .failedFetchUserProfilePic, object: nil, userInfo: userInfo)
            }
        }
    }
    
    func fetchUserPicFromFirebase() {
        guard let userID = currentUserInfoFirebase?.userInfoDoumentID else { return }
        firebaseManager.documentFetchData(documentType: .userPicDoc(userInfoDocumentID: userID)) { (result: Result<SCPicture, Error>)  in
            switch result {
            case .success(let picture):
                self.currentUserPic = picture.picture
            case .failure(let error):
                let errorMessage = error.localizedDescription
                let userInfoKey = "UserInfo"
                let userInfo: [AnyHashable: Any] = [userInfoKey: errorMessage]
                
                // Profile VC will observe
                NotificationCenter.default.post(name: .failedFetchUserProfilePic, object: nil, userInfo: userInfo)
            }
        }
    }
    
    func checkCoverPicFromFirebase() {
        
        guard let userID = currentUserInfoFirebase?.userInfoDoumentID else { return }
        firebaseManager.documentAddListener(documentType: .userCoverDoc(userInfoDocumentID: userID)) { (result: Result<SCPicture, Error>)  in
            switch result {
            case .success(let picture):
                self.currentUserCover = picture.picture
            case .failure(let error):
                let errorMessage = error.localizedDescription
                let userInfoKey = "UserInfo"
                let userInfo: [AnyHashable: Any] = [userInfoKey: errorMessage]
                
                // Profile VC will observe
                NotificationCenter.default.post(name: .failedFetchUserCoverPic, object: nil, userInfo: userInfo)
            }
        }
    }
    
    func fetchCoverPicFromFirebase() {
        guard let userID = currentUserInfoFirebase?.userInfoDoumentID else { return }
        firebaseManager.documentFetchData(documentType: .userCoverDoc(userInfoDocumentID: userID)) { (result: Result<SCPicture, Error>)  in
            switch result {
            case .success(let picture):
                self.currentUserCover = picture.picture
            case .failure(let error):
                let errorMessage = error.localizedDescription
                let userInfoKey = "UserInfo"
                let userInfo: [AnyHashable: Any] = [userInfoKey: errorMessage]
                
                //Profile VC will observe
                NotificationCenter.default.post(name: .failedFetchUserCoverPic, object: nil, userInfo: userInfo)
            }
        }
    }
    
    
    func checkBlackListFromFirebase() {
        guard let userID = currentUserInfoFirebase?.userInfoDoumentID else { return }
        _ = firebaseManager.collectionAddListener(collectionType: .blackList(userInfoDocumentID: userID)) { (result: Result<[SCBlockUser], Error>) in
            switch result {
            case .success(let users):
                self.currentUserBlacklist = users
            case .failure(let error):
                let errorMessage = error.localizedDescription
                let userInfoKey = "UserInfo"
                let userInfo: [AnyHashable: Any] = [userInfoKey: errorMessage]
                
                //Home VC will observe
                NotificationCenter.default.post(name: .failedFetchBlackList, object: nil, userInfo: userInfo)
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
    static let fetchLoginUserError = Notification.Name("fetchLoginUserError")
    static let failedFetchFavorite = Notification.Name("failedFetchFavorite")
    static let failedFetchFollowingList = Notification.Name("failedFetchFollowingList")
    static let failedFetchFollowerList = Notification.Name("failedFetchFollowerList")
    static let failedFetchUserProfilePic = Notification.Name("failedFetchUserProfilePic")
    static let failedFetchUserCoverPic = Notification.Name("failedFetchUserCoverPic")
    static let failedFetchBlackList = Notification.Name("failedFetchBlackList")
}
