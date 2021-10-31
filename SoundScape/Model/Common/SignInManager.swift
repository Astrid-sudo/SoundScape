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
    
    private init() {}
    
    var currentUserID = "yaheyyodude"
    
    var provider = "Appple"
    
    var userName = "厘題恩"
    
    var userEmail = "yaheyyodude@gmail.com"
    
    var userPic = CommonUsage.profilePic
    
    var profileCover = CommonUsage.profileCover
    
    var currentUserInfo: SCUser?
    
    // MARK: - another user
    
    //        var currentUserID = "astridtingan"
    //
    //        var provider = "Google"
    //
    //        var userName = "Astrid"
    //
    //        var userEmail = "astridtingan@gmail.com"
    //
    //        var userPic = CommonUsage.profilePic2
    //
    //        var profileCover = CommonUsage.profileCover2
    
    // MARK: - method
    
    func fetchUserInfo(completion: @escaping() -> Void) {
        
        firebaseManager.fetchUsers { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let userInfo):
                
                self.currentUserInfo = userInfo.first
                completion()
                
            case.failure(let error):
                print("fetchUserInfo failed\(error)")
            }
        }
    }
    
    
    func checkUser(completion: @escaping()->Void) {
        //去firebase找資料如果沒有這個人(userID + provider) 就幫他註冊，如果有，就顯把他的資料存在這
        
        firebaseManager.checkUsers(provider: provider, userID: currentUserID) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let userInfo):
                
                if userInfo.isEmpty {
                    self.uploadUserInfo(userPic: nil, userProfileCover: nil, userInfoDocumentID: nil)
                    self.fetchUserInfo(completion: completion)
                } else {
                    self.currentUserInfo = userInfo.first
                    completion()
                }
                
            case.failure(let error):
                print(error)
            }
        }
    }
    
    func uploadUserInfo(userPic: URL?, userProfileCover: URL?, userInfoDocumentID: String?) {
        
        firebaseManager.uploadUserInfo(userInfo: SCUser(userID: currentUserID,
                                                        provider: provider,
                                                        username: userName,
                                                        userEmail: userEmail,
                                                        userPic: userPic,
                                                        userProfileCover: userProfileCover,
                                                        userInfoDoumentID: userInfoDocumentID))
        
    }
    
}
