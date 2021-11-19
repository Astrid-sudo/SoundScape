//
//  FirebaseManager.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/21.
//

import Foundation
import Firebase

// swiftlint:disable file_length

class FirebaseManager {
    
    // MARK: - properties
    
    static let shared = FirebaseManager()
    
    private var postListener: ListenerRegistration?
    private var favoriteListener: ListenerRegistration?
    private var followersListenser: ListenerRegistration?
    private var followingsListenser: ListenerRegistration?
    private var commentListenser: ListenerRegistration?
    private var userPicListenser: ListenerRegistration?
    private var coverPicListenser: ListenerRegistration?
    private var locationsListenser: ListenerRegistration?
    private var blackListListenser: ListenerRegistration?
    
    private let storage = Storage.storage().reference()
    
    private let allAudioCollectionRef = Firestore.firestore().collection(CommonUsage.CollectionName.allAudioFiles)
    private let allUsersCollectionRef = Firestore.firestore().collection(CommonUsage.CollectionName.allUsers)
    private let allLocationsCollectionRef = Firestore.firestore().collection(CommonUsage.CollectionName.allLocations)
    
    // MARK: - init / deinit
    
    private init() {}
    
    deinit {
        postListener?.remove()
        favoriteListener?.remove()
        followersListenser?.remove()
        followingsListenser?.remove()
        commentListenser?.remove()
        userPicListenser?.remove()
        coverPicListenser?.remove()
        locationsListenser?.remove()
    }
    
    // MARK: - post method
    
    func fetchPosts(completion: @escaping (Result<[SCPost], Error>) -> Void) {
        
        allAudioCollectionRef.order(by: "createdTime").getDocuments { [weak self] snapshot, error in
            
            if let error = error {
                completion(Result.failure(error))
                return
            }
            
            if let snapshot = snapshot {
                let posts = snapshot.documents.compactMap({ snapshot in
                    try? snapshot.data(as: SCPost.self)
                })
                
                completion(Result.success(posts.reversed()))
                
            }
        }
    }
    
    func checkPostsChange(completion: @escaping (Result<[SCPost], Error>) -> Void) {
        
        postListener = allAudioCollectionRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            snapshot.documentChanges.forEach { documentChange in
                switch documentChange.type {
                case .added:
                    self.fetchPosts(completion: completion)
                    print("added")
                case .modified:
                    self.fetchPosts(completion: completion)
                    print("modified")
                case .removed:
                    self.fetchPosts(completion: completion)
                    print("removed")
                }
            }
        }
    }
    
    func upload(localURL: URL, post: SCPost,
                completion: @escaping () -> Void,
                errorCompletion:@escaping (_ errorMessage:String) -> Void) {
        
        var fullPost = post
        
        let metadata = StorageMetadata()
        metadata.contentType = "audio/m4a"
        let audioString =  NSUUID().uuidString
        let audioName = audioString + ".m4a"
        
        let audioReference = storage.child("\(audioName)")
        let uploadTask = audioReference.putFile(from: localURL, metadata: nil) { metadata, error in
            if let error = error {
                errorCompletion(error.localizedDescription)
                return
            }
            print("Upload audio suceeded from localUrl:\(localURL)")
            
            audioReference.downloadURL { [weak self] (url, error) in
                
                guard let self = self else { return }
                
                if let error = error {
                    print("Failed to get audio remote URL")
                    errorCompletion(error.localizedDescription)
                    return
                }
                
                let document = self.allAudioCollectionRef.document(audioString)
                
                fullPost.audioURL = url
                fullPost.createdTime = Timestamp(date: Date())
                fullPost.documentID = audioString
                
                do {
                    try document.setData(from: fullPost)
                    
                    if let geoPoint = fullPost.audioLocation {
                        
                        let locationData = SCLocation(audioLocation: geoPoint,
                                                      audioDocumentID: fullPost.documentID,
                                                      authorID: fullPost.authorID,
                                                      authIDProvider: fullPost.authIDProvider, locationDocumentID: fullPost.documentID)
                        
                        self.uploadGeoPointToAllLocations(audioDocumentID: fullPost.documentID,
                                                          locationData: locationData,
                                                          completion: completion) { errorMessage in
                            errorCompletion(errorMessage)
                        }
                    } else {
                        
                        completion()
                        
                    }
                    
                } catch {
                    print("Failed add data to firestire \(error)")
                    errorCompletion(error.localizedDescription)
                }
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            print("Audio upload progress \(String(describing: snapshot.progress))")
        }
    }
    
    func deletePostInAllAudio(documentID: String, errorCompletion: @escaping (_ errorMessage:String) -> Void) {
       
        allAudioCollectionRef.document(documentID).delete() { error in
            if let error = error {
                errorCompletion(error.localizedDescription)
                print("Error remove post in AllAudioCollection \(documentID), error: \(error)")
            } else {
                print("\(documentID) in AllAudioCollection successfully removed.")
                self.deletePostInAllLocation(documentID: documentID, errorCompletion: errorCompletion)
            }
        }
    }
    
   private func deletePostInAllLocation(documentID: String, errorCompletion: @escaping (_ errorMessage:String) -> Void) {
        
        allLocationsCollectionRef.document(documentID).delete() { error in
            if let error = error {
                print("Error remove post \(documentID), error: \(error)")
                errorCompletion(error.localizedDescription)
            } else {
                print("\(documentID) in AllLocationCollection successfully removed.")
                self.deleteAudioInStorage(documentID: documentID, errorCompletion: errorCompletion)
                
            }
        }
    }
    
    private func deleteAudioInStorage(documentID: String, errorCompletion: @escaping (_ errorMessage:String) -> Void) {
        
        let audioName = documentID + ".m4a"
        let audioReference = storage.child("\(audioName)")
        
        audioReference.delete { error in
            if let error = error {
                print("Error remove audio \(audioReference), error: \(error)")
                errorCompletion(error.localizedDescription)
            } else {
                print("\(audioReference) in Storage successfully removed.")
            }
        }
        
    }
    
    // MARK: - temporary fake member method
    
//    func checkUsers(provider: String, userID: String, completion: @escaping (Result<[SCUser], Error>) -> Void) {
//
//        allUsersCollectionRef.whereField("provider", isEqualTo: provider).whereField("userID", isEqualTo: userID).getDocuments { [weak self] snapshot, error in
//
//            if let error = error {
//                completion(Result.failure(error))
//                return
//            }
//
//            if let snapshot = snapshot {
//
//                let users = snapshot.documents.compactMap({ snapshot in
//                    try? snapshot.data(as: SCUser.self)
//                })
//
//                completion(Result.success(users))
//            }
//        }
//    }
//
//    func fetchUsers(completion: @escaping (Result<[SCUser], Error>) -> Void) {
//
//        allUsersCollectionRef.getDocuments { snapshot, error in
//
//            if let error = error {
//                completion(Result.failure(error))
//                return
//            }
//
//            if let snapshot = snapshot {
//                let users = snapshot.documents.compactMap({ snapshot in
//                    try? snapshot.data(as: SCUser.self)
//                })
//
//                completion(Result.success(users))
//
//            }
//        }
//    }
//
    func fetchUser(userID: String,
                   userIDProvider: String,
                   completion: @escaping (Result<SCUser, Error>) -> Void) {

        allUsersCollectionRef.whereField("userID", isEqualTo: userID).whereField("provider", isEqualTo: userIDProvider).getDocuments { snapshot, error in

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
//
//    func uploadUserInfo(userInfo: SCUser) {
//
//        var userInfo = userInfo
//        let document = allUsersCollectionRef.document()
//        userInfo.userInfoDoumentID = document.documentID
//
//        do {
//
//            try document.setData(from: userInfo)
//
//        } catch {
//            print(error)
//        }
//    }
    
    // MARK: - real member method
    
    func checkUsersInFirebase(userID: String, completion: @escaping (Result<SCUser, Error>) -> Void) {
        
        let docRef = allUsersCollectionRef.document(userID)
        
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
                completion(Result.success(SCUser(userID: "", provider: "", username: "", userEmail: "", userPic: nil, userProfileCover: nil, userInfoDoumentID: nil)))
            }
        }
    }
    
    func fetchUserInfoFromFirebase(userID: String, completion: @escaping (Result<SCUser, Error>) -> Void) {
        
        let docRef = allUsersCollectionRef.document(userID)
        
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
                
            }
        }
    }
    
    func uploadUserToFirebase(userInfo: SCUser) {
        
        let userID = userInfo.userID
        var userInfo = userInfo
        userInfo.userInfoDoumentID = userID
        
        do {
            try allUsersCollectionRef.document(userID).setData(from: userInfo)
        } catch {
            print(error)
        }
    }
    
    func manipulateFavorite(userProfileDocumentID: String,
                            documendID: String,
                            addCompletion: @escaping () -> Void,
                            removeCompletion: @escaping () -> Void,
                            errorCompletion: @escaping (_ errorMessage:String) -> Void) {
        
        let myFavoriteSubCollectionRef = allUsersCollectionRef.document(userProfileDocumentID).collection("myFavorite")
        
        myFavoriteSubCollectionRef.whereField("favoriteDocumentID", isEqualTo: documendID).getDocuments { snapshot, error in
            
            if let error = error {
                print("Failed to fetch myFavorite collection \(error)")
                errorCompletion(error.localizedDescription)
                return
            }
            
            if let snapshot = snapshot {
                
                if snapshot.documents.isEmpty {
                    let favorite = SCFavorite(favoriteDocumentID: documendID)
                    do {
                        try myFavoriteSubCollectionRef.addDocument(from: favorite)
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
                            print("Error removing favorite: \(error)")
                            errorCompletion(error.localizedDescription)
                        } else {
                            print("Document successfully removed favorite!")
                            removeCompletion()
                        }
                    }
                }
            }
        }
    }
    
    func fetchUserFavoriteList(userProfileDocumentID: String, completion: @escaping
                               (Result<[SCFavorite], Error>) -> Void)  {
        
        let myFavoriteSubCollectionRef = allUsersCollectionRef.document(userProfileDocumentID).collection("myFavorite")
        
        myFavoriteSubCollectionRef.getDocuments { [weak self] snapshot, error in
            
            if let error = error {
                completion(Result.failure(error))
                return
            }
            
            if let snapshot = snapshot {
                let posts = snapshot.documents.compactMap({ snapshot in
                    try? snapshot.data(as: SCFavorite.self)
                })
                
                completion(Result.success(posts))
                
            }
        }
    }
    
    func checkFavoriteChange(userProfileDocumentID: String, completion: @escaping (Result<[SCFavorite], Error>) -> Void) {
        
        let myFavoriteSubCollectionRef = allUsersCollectionRef.document(userProfileDocumentID).collection("myFavorite")
        
        favoriteListener = myFavoriteSubCollectionRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            snapshot.documentChanges.forEach { documentChange in
                switch documentChange.type {
                case .added:
                    self.fetchUserFavoriteList(userProfileDocumentID: userProfileDocumentID, completion: completion)
                    print("favorite added")
                case .modified:
                    self.fetchUserFavoriteList(userProfileDocumentID: userProfileDocumentID, completion: completion)
                    print("favorite modified")
                case .removed:
                    self.fetchUserFavoriteList(userProfileDocumentID: userProfileDocumentID, completion: completion)
                    print("favorite removed")
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
                          errorCompletion: @escaping (_ errorMessage:String) -> Void) {
        
        let myFollowingSubCollectionRef = allUsersCollectionRef.document(loggedInUserInfoDocumentID).collection("following")
        
        let othersFollowedBySubCollectionRef = allUsersCollectionRef.document(userInfoDoumentID).collection("followedBy")
        
        myFollowingSubCollectionRef.whereField("userID", isEqualTo: userInfo.userID).whereField("provider", isEqualTo: userInfo.provider).getDocuments { snapshot, error in
            
            if let error = error {
                errorCompletion(error.localizedDescription)
                print("Failed to fetch myFollowing subCollection collection \(error)")
                return
            }
            
            if let snapshot = snapshot {
                
                if snapshot.documents.isEmpty {
                    
                    let logginUserInfo = loggedInUserInfo
                    let userInfo = userInfo
                    
                    do {
                        try myFollowingSubCollectionRef.document(userInfo.userID).setData(from: userInfo)
                        try othersFollowedBySubCollectionRef.document(logginUserInfo.userID).setData(from: loggedInUserInfo)
                        
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
                            print("Error removing favorite: \(error)")
                        } else {
                            print("Person successfully removed from loggedIn's following!")
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
        
        let othersFollowedBySubCollectionRef = allUsersCollectionRef.document(userInfoDoumentID).collection("followedBy")
        
        othersFollowedBySubCollectionRef.whereField("userID", isEqualTo: loggedInUserInfo.userID).whereField("provider", isEqualTo: loggedInUserInfo.provider).getDocuments { snapshot, error in
            
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
                    othersFollowedBySubCollectionRef.document(meInOthersCollection).delete() { error in
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
    
    func fetchFollowers(userInfoDoumentID: String, completion: @escaping (Result<[SCFollow], Error>) -> Void) {
        
        let followedBySubCollectionRef = allUsersCollectionRef.document(userInfoDoumentID).collection("followedBy")
        
        followedBySubCollectionRef.getDocuments { [weak self] snapshot, error in
            
            if let error = error {
                completion(Result.failure(error))
                return
            }
            
            if let snapshot = snapshot {
                let followers = snapshot.documents.compactMap({ snapshot in
                    try? snapshot.data(as: SCFollow.self)
                })
                
                completion(Result.success(followers))
                
            }
        }
    }
    
    func fetchFollowings(userInfoDoumentID: String, completion: @escaping (Result<[SCFollow], Error>) -> Void) {
        
        let followingSubCollectionRef = allUsersCollectionRef.document(userInfoDoumentID).collection("following")
        
        followingSubCollectionRef.getDocuments { [weak self] snapshot, error in
            
            if let error = error {
                completion(Result.failure(error))
                return
            }
            
            if let snapshot = snapshot {
                let followings = snapshot.documents.compactMap({ snapshot in
                    try? snapshot.data(as: SCFollow.self)
                })
                
                completion(Result.success(followings))
                
            }
        }
    }
    
    func checkFollowersChange(userInfoDoumentID: String, completion: @escaping (Result<[SCFollow], Error>) -> Void) {
        
        let followedBySubCollectionRef = allUsersCollectionRef.document(userInfoDoumentID).collection("followedBy")
        
        followersListenser = followedBySubCollectionRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            snapshot.documentChanges.forEach { documentChange in
                switch documentChange.type {
                case .added:
                    self.fetchFollowers(userInfoDoumentID: userInfoDoumentID, completion: completion)
                    print("followers added")
                case .modified:
                    self.fetchFollowers(userInfoDoumentID: userInfoDoumentID, completion: completion)
                    print("followers modified")
                case .removed:
                    self.fetchFollowers(userInfoDoumentID: userInfoDoumentID, completion: completion)
                    print("followers removed")
                }
            }
        }
    }
    
    func checkFollowingsChange(userInfoDoumentID: String, completion: @escaping (Result<[SCFollow], Error>) -> Void) {
        
        let followingSubCollectionRef = allUsersCollectionRef.document(userInfoDoumentID).collection("following")
        
        followingsListenser = followingSubCollectionRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            snapshot.documentChanges.forEach { documentChange in
                switch documentChange.type {
                case .added:
                    self.fetchFollowings(userInfoDoumentID: userInfoDoumentID, completion: completion)
                    print("followings added")
                case .modified:
                    self.fetchFollowings(userInfoDoumentID: userInfoDoumentID, completion: completion)
                    print("followings modified")
                case .removed:
                    self.fetchFollowings(userInfoDoumentID: userInfoDoumentID, completion: completion)
                    print("followings removed")
                }
            }
        }
    }
    
    // MARK: - comment
    
    func deleteComment(audioDocumentID: String, commentDocumentID: String, errorCompletion: @escaping (_ errorMessage:String) -> Void) {
        let db = Firestore.firestore()
        let commentRef = db.collection(CommonUsage.CollectionName.allAudioFiles).document(audioDocumentID).collection(CommonUsage.CollectionName.comments).document(commentDocumentID)
        
        commentRef.delete { error in
            if let error = error {
                print("Failed to delete comment \(commentRef), error: \(error)")
                errorCompletion(error.localizedDescription)
            } else {
                print("Succeffully delete comment \(commentRef)")
            }
        }
    }
    
    func addComment(to documentID: String, with comment: SCComment, completion: @escaping () -> Void, errorCompletion: @escaping (String) -> Void) {
       
        let db = Firestore.firestore()
        let commentSubCollectionRef = db.collection(CommonUsage.CollectionName.allAudioFiles).document(documentID).collection(CommonUsage.CollectionName.comments)
        
        let document = commentSubCollectionRef.document()
        
        let newComment = SCComment(commentDocumentID: document.documentID,
                                   userID: comment.userID,
                                   userName: comment.userName,
                                   userImage: comment.userImage,
                                   createdTime: Timestamp(date: Date()),
                                   lastEditedTime: nil,
                                   comment: comment.comment)
        
        do {
            try document.setData(from: newComment)
            completion()
        } catch {
            errorCompletion(error.localizedDescription)
            print("FirebaseManager:mfailed to add comment")
        }
    }
    
    private func fetchComment(from documentID: String,
                              completion: @escaping (Result<[SCComment], Error>) -> Void) {
        
        let db = Firestore.firestore()
        
        let commentSubCollectionRef = db.collection(CommonUsage.CollectionName.allAudioFiles).document(documentID).collection(CommonUsage.CollectionName.comments)
        
        commentSubCollectionRef.order(by:"createdTime").getDocuments { snapshot, error in
            
            if let error = error {
                completion(Result.failure(error))
                return
            }
            
            if let snapshot = snapshot {
                let posts = snapshot.documents.compactMap({ snapshot in
                    try? snapshot.data(as: SCComment.self)
                })
                
                completion(Result.success(posts))
                
            }
        }
    }
    
    func checkCommentChange(from documentID: String,
                            completion: @escaping (Result<[SCComment], Error>) -> Void) {
        
        let db = Firestore.firestore()
        
        let commentSubCollectionRef = db.collection(CommonUsage.CollectionName.allAudioFiles).document(documentID).collection(CommonUsage.CollectionName.comments)
        
        commentListenser = commentSubCollectionRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            snapshot.documentChanges.forEach { documentChange in
                switch documentChange.type {
                case .added:
                    self.fetchComment(from: documentID, completion: completion)
                    print("comment added")
                case .modified:
                    self.fetchComment(from: documentID, completion: completion)
                    print("comment modified")
                case .removed:
                    self.fetchComment(from: documentID, completion: completion)
                    print("comment removed")
                }
            }
        }
    }
    
    func uploadPicToFirebase(userDocumentID: String,
                             picString:String,
                             picType: PicType,
                             errorCompletion: @escaping (_ errorMessage:String) -> Void) {
        
        let profilePicSubCollection = allUsersCollectionRef.document(userDocumentID).collection("profilePicture")
        let picture = SCPicture(picture: picString)
        do {
            try profilePicSubCollection.document(picType.rawValue).setData(from: picture)
        } catch {
            errorCompletion(error.localizedDescription)
            print(error)
        }
    }
    
    func fetchUserPicFromFirebase(userID: String, completion: @escaping (Result<SCPicture, Error>) -> Void) {
        
        let userPicDoc = allUsersCollectionRef.document(userID).collection("profilePicture").document("userPic")
        
        userPicDoc.getDocument { (document, error) in
            
            if let error = error {
                completion(Result.failure(error))
                return
            }
            
            if let document = document,
               document.exists {
                let picture = try? document.data(as: SCPicture.self)
                if let picture = picture {
                    completion(Result.success(picture))
                }
                
            } else {
                
                print("Document does not exist")
                
            }
        }
    }
    
    func fetchCoverPicFromFirebase(userID: String, completion: @escaping (Result<SCPicture, Error>) -> Void) {
        
        let coverPicDoc = allUsersCollectionRef.document(userID).collection("profilePicture").document("coverPic")
        
        coverPicDoc.getDocument { (document, error) in
            
            if let error = error {
                completion(Result.failure(error))
                return
            }
            
            if let document = document,
               document.exists {
                let picture = try? document.data(as: SCPicture.self)
                if let picture = picture {
                    completion(Result.success(picture))
                }
                
            } else {
                
                print("Document does not exist")
                
            }
        }
    }
    
    func checkUserPicChange(userInfoDoumentID: String, completion: @escaping (Result<SCPicture, Error>) -> Void) {
        
        let userPicRef = allUsersCollectionRef.document(userInfoDoumentID).collection("profilePicture").document("userPic")
        
        userPicListenser = userPicRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot,
                  snapshot.exists else { return }
            
            self.fetchUserPicFromFirebase(userID: userInfoDoumentID, completion: completion)
            
        }
    }
    
    func checkCoverPicChange(userInfoDoumentID: String, completion: @escaping (Result<SCPicture, Error>) -> Void) {
        
        let coverPicRef = allUsersCollectionRef.document(userInfoDoumentID).collection("profilePicture").document("coverPic")
        
        coverPicListenser = coverPicRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot,
                  snapshot.exists else { return }
            
            self.fetchCoverPicFromFirebase(userID: userInfoDoumentID, completion: completion)
        }
    }
    
    // MARK: - Location
    
    func uploadGeoPointToAllLocations(audioDocumentID: String,
                                      locationData: SCLocation,
                                      completion: () -> Void,
                                      errorCompletion:@escaping (_ errorMessage:String) -> Void) {
        
        do {
            try allLocationsCollectionRef.document(audioDocumentID).setData(from: locationData)
            completion()
        } catch {
            errorCompletion(error.localizedDescription)
            print("Failed to upload locationData to allLocations collection \(error)")
        }
        
        
    }
    
    func fetchLocationsFromFirebase(completion: @escaping (Result<[SCLocation], Error>) -> Void) {
        
        allLocationsCollectionRef.getDocuments { [weak self] snapshot, error in
            
            if let error = error {
                completion(Result.failure(error))
                return
            }
            
            if let snapshot = snapshot {
                let locations = snapshot.documents.compactMap({ snapshot in
                    try? snapshot.data(as: SCLocation.self)
                })
                
                completion(Result.success(locations))
            }
        }
    }
    
    func checkLocationChange(completion: @escaping (Result<[SCLocation], Error>) -> Void) {
        locationsListenser = allLocationsCollectionRef.addSnapshotListener{ snapshot, error in
            guard let snapshot = snapshot else { return }
            snapshot.documentChanges.forEach { documentChange in
                switch documentChange.type {
                case .added:
                    self.fetchLocationsFromFirebase(completion: completion)
                    print("location added")
                case .modified:
                    self.fetchLocationsFromFirebase(completion: completion)
                    print("location modified")
                case .removed:
                    self.fetchLocationsFromFirebase(completion: completion)
                    print("location removed")
                }
            }
        }
    }
    
    // MARK: - Black List
    
    func addToBlackList(loggedInUserInfoDocumentID: String, toBeBlockedID: String, completion: (() -> Void)?) {
        
        let myBlackListSubCollectionRef = allUsersCollectionRef.document(loggedInUserInfoDocumentID).collection("blackList")
        
        let user = SCBlockUser(userID: toBeBlockedID)
        
        do {
            
            try myBlackListSubCollectionRef.document(toBeBlockedID).setData(from: user)
            
            completion?()
            
        } catch {
            
            print("Failed to add black list")
        }
    }
    
    func fetchUserBlackList(userProfileDocumentID: String, completion: @escaping
                            (Result<[SCBlockUser], Error>) -> Void)  {
        
        let myBlackListSubCollectionRef = allUsersCollectionRef.document(userProfileDocumentID).collection("blackList")
        
        myBlackListSubCollectionRef.getDocuments { [weak self] snapshot, error in
            
            if let error = error {
                completion(Result.failure(error))
                return
            }
            
            if let snapshot = snapshot {
                let users = snapshot.documents.compactMap({ snapshot in
                    try? snapshot.data(as: SCBlockUser.self)
                })
                
                completion(Result.success(users))
                
            }
        }
    }
    
    func checkBlackListChange(userInfoDoumentID: String, completion: @escaping (Result<[SCBlockUser], Error>) -> Void) {
        
        let myBlackListSubCollectionRef = allUsersCollectionRef.document(userInfoDoumentID).collection("blackList")
        
        blackListListenser = myBlackListSubCollectionRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            snapshot.documentChanges.forEach { documentChange in
                switch documentChange.type {
                case .added:
                    self.fetchUserBlackList(userProfileDocumentID: userInfoDoumentID, completion: completion)
                    print("Blocked users added")
                case .modified:
                    self.fetchUserBlackList(userProfileDocumentID: userInfoDoumentID, completion: completion)
                    print("Blocked users modified")
                case .removed:
                    self.fetchUserBlackList(userProfileDocumentID: userInfoDoumentID, completion: completion)
                    print("Blocked users removed")
                }
            }
        }
    }
    
    
    
}

// swiftlint:enable file_length
