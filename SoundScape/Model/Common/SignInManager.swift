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
    
    var currentUserInfo: SCUser?
    
    private init() {}
    
    // MARK: - user 1
    
    //    var currentUserID = "yaheyyodude"
    //
    //    var provider = "Appple"
    //
    //    var userName = "厘題恩"
    //
    //    var userEmail = "yaheyyodude@gmail.com"
    //
    //    var userPic = CommonUsage.profilePic
    //
    //    var profileCover = CommonUsage.profileCover
    
    
    // MARK: - user 2
    
    //            var currentUserID = "astridtingan"
    //
    //            var provider = "Google"
    //
    //            var userName = "Astrid"
    //
    //            var userEmail = "astridtingan@gmail.com"
    //
    //            var userPic = CommonUsage.profilePic2
    //
    //            var profileCover = CommonUsage.profileCover2
    
    // MARK: - user 3
    
//                var currentUserID = "tinganl.1216"
//
//                var provider = "Google"
//
//                var userName = "林庭安"
//
//                var userEmail = "tinganl.1216@gmail.com"
//
//                var userPic = CommonUsage.profilePic3
//
//                var profileCover = CommonUsage.profileCover3
    
    // MARK: - user 4
    
//        var currentUserID = "ta811216"
//
//        var provider = "Google"
//
//        var userName = "安安"
//
//        var userEmail = "tina811216@gmail.com"
//
//        var userPic = CommonUsage.profilePic4
//
//        var profileCover = CommonUsage.profileCover4
//
    // MARK: - user 5
    
    var currentUserID = "water"

    var provider = "Google"

    var userName = "A水"

    var userEmail = "water@gmail.com"

    var userPic = CommonUsage.profilePic5

    var profileCover = CommonUsage.profileCover5
    
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
    
    
    func checkUser(completion: @escaping() -> Void) {
        
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
