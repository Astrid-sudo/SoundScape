//
//  FirebaseManager+Extension.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/28.
//

import Foundation

extension FirebaseManager {
    
    // MARK: - user info method
    
    func fetchUser(userID: String,
                   userIDProvider: String,
                   completion: @escaping (Result<SCUser, Error>) -> Void) {
        
        FirebaseCollection.allUsers.reference.whereField("userID",
                                                         isEqualTo: userID)
            .whereField("provider",
                        isEqualTo: userIDProvider)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    completion(Result.failure(error))
                    return
                }
                
                if let snapshot = snapshot {
                    if snapshot.documents.isEmpty {
                        print("Firebase manager: No such user")
                    } else {
                        let users = snapshot.documents.compactMap({ snapshot in
                            try? snapshot.data(as: SCUser.self)
                        })
                        guard let user = users.first else { return }
                        completion(Result.success(user))
                    }
                }
            }
    }
    
    func checkUsersInFirebase(userID: String,
                              completion: @escaping (Result<SCUser, Error>) -> Void) {
        
        let docRef = FirebaseCollection.allUsers.reference.document(userID)
        
        docRef.getDocument { (document, error) in
            
            if let error = error {
                completion(Result.failure(error))
                return
            }
            
            if let document = document,
               document.exists {
                let user = try? document.data(as: SCUser.self)
                if let user = user {
                    completion(Result.success(user))
                }
            } else {
                print("Document does not exist")
                completion(Result.success(SCUser(userID: "",
                                                 provider: "",
                                                 username: "",
                                                 userEmail: "",
                                                 userPic: nil,
                                                 userProfileCover: nil,
                                                 userInfoDoumentID: nil)))
            }
        }
    }
    
    func uploadUserToFirebase(userInfo: SCUser) {
        let userID = userInfo.userID
        var userInfo = userInfo
        userInfo.userInfoDoumentID = userID
        do {
            try FirebaseCollection.allUsers.reference.document(userID).setData(from: userInfo)
        } catch {
            print(error)
        }
    }
    
    func manipulateFavorite(userProfileDocumentID: String,
                            documentID: String,
                            addCompletion: @escaping () -> Void,
                            removeCompletion: @escaping () -> Void,
                            errorCompletion: @escaping (_ errorMessage: String) -> Void) {
        
        let myFavoriteSubCollectionRef = FirebaseCollection
            .myFavorite(userInfoDocumentID: userProfileDocumentID)
            .reference
        
        myFavoriteSubCollectionRef.whereField("favoriteDocumentID",
                                              isEqualTo: documentID)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    errorCompletion(error.localizedDescription)
                    return
                }
                
                if let snapshot = snapshot {
                    
                    if snapshot.documents.isEmpty {
                        let favorite = SCFavorite(favoriteDocumentID: documentID)
                        do {
                            try _ = myFavoriteSubCollectionRef.addDocument(from: favorite)
                            addCompletion()
                        } catch {
                            errorCompletion(error.localizedDescription)
                            print(error)
                        }
                        
                    } else {
                        
                        guard let refDocumentID = snapshot.documents.first?.documentID else {
                            print("failed to get favorite ref documentID")
                            return
                        }
                        
                        myFavoriteSubCollectionRef.document(refDocumentID).delete() { error in
                            if let error = error {
                                errorCompletion(error.localizedDescription)
                            } else {
                                removeCompletion()
                            }
                        }
                    }
                }
            }
    }
    
    func manipulateFollow(userInfoDoumentID: String,
                          userInfo: SCFollow,
                          loggedInUserInfoDocumentID: String,
                          loggedInUserInfo: SCFollow,
                          followCompletion: @escaping () -> Void,
                          unfollowCompletion: @escaping () -> Void,
                          errorCompletion: @escaping (_ errorMessage: String) -> Void) {
        
        let myFollowingSubCollectionRef = FirebaseCollection
            .following(userInfoDocumentID: loggedInUserInfoDocumentID).reference
        
        let othersFollowedBySubCollectionRef = FirebaseCollection
            .followedBy(userInfoDocumentID: userInfoDoumentID).reference
        
        myFollowingSubCollectionRef.whereField("userID",
                                               isEqualTo: userInfo.userID)
            .whereField("provider",
                        isEqualTo: userInfo.provider)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    errorCompletion(error.localizedDescription)
                    return
                }
                
                if let snapshot = snapshot {
                    
                    if snapshot.documents.isEmpty {
                        
                        let logginUserInfo = loggedInUserInfo
                        let userInfo = userInfo
                        
                        do {
                            try myFollowingSubCollectionRef
                                .document(userInfo.userID)
                                .setData(from: userInfo)
                            
                            try othersFollowedBySubCollectionRef
                                .document(logginUserInfo.userID)
                                .setData(from: loggedInUserInfo)
                            
                            followCompletion()
                            
                        } catch {
                            errorCompletion(error.localizedDescription)
                            print(error)
                        }
                        
                    } else {
                        guard let othersDocIDInMyCollec = snapshot.documents.first?.documentID else {
                            print("failed to get othersDocIDInMyCollec ref")
                            return
                        }
                        myFollowingSubCollectionRef.document(othersDocIDInMyCollec).delete() { [weak self] error in
                            guard let self = self else { return }
                            
                            if let error = error {
                                errorCompletion(error.localizedDescription)
                            } else {
                                unfollowCompletion()
                                self.removeFollowersDocID(userInfoDoumentID: userInfoDoumentID,
                                                          userInfo: userInfo,
                                                          loggedInUserInfoDocumentID: loggedInUserInfoDocumentID,
                                                          loggedInUserInfo: loggedInUserInfo)
                            }
                        }
                    }
                }
            }
    }
    
    private func removeFollowersDocID(userInfoDoumentID: String,
                                      userInfo: SCFollow,
                                      loggedInUserInfoDocumentID: String,
                                      loggedInUserInfo: SCFollow) {
        
        let othersFollowedByCollection = FirebaseCollection.followedBy(userInfoDocumentID: userInfoDoumentID).reference
        
        othersFollowedByCollection.whereField("userID",
                                              isEqualTo:
                                                loggedInUserInfo.userID)
            .whereField("provider",
                        isEqualTo: loggedInUserInfo.provider)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("Failed to fetch othersFollowedBy subcollection \(error)")
                    return
                }
                
                if let snapshot = snapshot {
                    
                    if snapshot.documents.isEmpty {
                        print("FirebaseManager: You were no on his followedBy list")
                    } else {
                        
                        guard let meInOthersCollection = snapshot.documents.first?.documentID else {
                            print("failed to get meInOthersCollection ref")
                            return
                        }
                        othersFollowedByCollection.document(meInOthersCollection).delete() { error in
                            if let error = error {
                                print("Error removing you from ex friend: \(error)")
                            } else {
                                print("You've been successfully removed from others followedBy!")
                            }
                        }
                    }
                }
            }
    }
    
    // MARK: - Black List
    
    func addToBlackList(loggedInUserInfoDocumentID: String,
                        toBeBlockedID: String,
                        completion: (() -> Void)?) {
        
        let myBlackListSubCollectionRef = FirebaseCollection.blackList(userInfoDocumentID: loggedInUserInfoDocumentID).reference
        
        let user = SCBlockUser(userID: toBeBlockedID)
        
        do {
            try myBlackListSubCollectionRef.document(toBeBlockedID).setData(from: user)
            completion?()
        } catch {
            print("Failed to add black list")
        }
    }
    
    // MARK: - profile pic
    
    func uploadPicToFirebase(userDocumentID: String,
                             picString: String,
                             picType: PicType,
                             errorCompletion: @escaping (_ errorMessage: String) -> Void,
                             succeededCompletion: @escaping () -> Void) {
        
        let profilePicSubCollection = FirebaseCollection.profilePicture(userInfoDocumentID: userDocumentID).reference
        
        let picture = SCPicture(picture: picString)
        do {
            try profilePicSubCollection.document(picType.rawValue).setData(from: picture)
            succeededCompletion()
        } catch {
            errorCompletion(error.localizedDescription)
            print(error)
        }
    }
    
}
