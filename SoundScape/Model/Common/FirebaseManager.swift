//
//  FirebaseManager.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/21.
//

import Foundation
import Firebase

class FirebaseManager {
    
    // MARK: - properties
    
    static let shared = FirebaseManager()
    
    //    weak var delegate: PostsPassableDelegate?
    
    private var postListener: ListenerRegistration?
    
    private var favoriteListener: ListenerRegistration?
    
    private var followersListenser: ListenerRegistration?
    
    private var followingsListenser: ListenerRegistration?
    
    private var commentListenser: ListenerRegistration?
    
    private let storage = Storage.storage().reference()
    
    private let allAudioCollectionRef = Firestore.firestore().collection(CommonUsage.CollectionName.allAudioFiles)
    
    private let allUsersCollectionRef = Firestore.firestore().collection(CommonUsage.CollectionName.allUsers)
    
    // MARK: - init / deinit
    
    private init() {}
    
    deinit {
        postListener?.remove()
        favoriteListener?.remove()
        followersListenser?.remove()
        followingsListenser?.remove()
        commentListenser?.remove()
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
    
    func upload(localURL: URL, post: SCPost, completion: @escaping () -> Void) {
        
        var fullPost = post
        
        let metadata = StorageMetadata()
        metadata.contentType = "audio/m4a"
        let audioName = NSUUID().uuidString + ".m4a"
        
        let audioReference = storage.child("\(audioName)")
        let uploadTask = audioReference.putFile(from: localURL, metadata: nil) { metadata, error in
            if error != nil {
                print(String(describing: error))
                return
            }
            
            completion()
            print("Upload audio suceeded from localUrl:\(localURL)")
            
            audioReference.downloadURL { [weak self] (url, error) in
                
                guard let self = self else { return }
                
                if error != nil {
                    print("Failed to get audio remote URL")
                    return
                }
                
                let document = self.allAudioCollectionRef.document()
                
                fullPost.audioURL = url
                fullPost.createdTime = Timestamp(date: Date())
                fullPost.documentID = document.documentID
                
                do {
                    try document.setData(from: fullPost)
                } catch {
                    print("Failed add data to firestire \(error)")
                }
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            print("Audio upload progress \(String(describing: snapshot.progress))")
        }
    }
    
    // MARK: - temporary fake member method
    
    func checkUsers(provider: String, userID: String, completion: @escaping (Result<[SCUser], Error>) -> Void) {
        
        allUsersCollectionRef.whereField("provider", isEqualTo: provider).whereField("userID", isEqualTo: userID).getDocuments { [weak self] snapshot, error in
            
            if let error = error {
                completion(Result.failure(error))
                return
            }
            
            if let snapshot = snapshot {
                
                let users = snapshot.documents.compactMap({ snapshot in
                    try? snapshot.data(as: SCUser.self)
                })
                
                completion(Result.success(users))
            }
        }
    }
    
    func fetchUsers(completion: @escaping (Result<[SCUser], Error>) -> Void) {
        
        allUsersCollectionRef.getDocuments { snapshot, error in
            
            if let error = error {
                completion(Result.failure(error))
                return
            }
            
            if let snapshot = snapshot {
                let users = snapshot.documents.compactMap({ snapshot in
                    try? snapshot.data(as: SCUser.self)
                })
                
                completion(Result.success(users))
                
            }
        }
    }
    
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
    
    func uploadUserInfo(userInfo: SCUser) {
        
        var userInfo = userInfo
        let document = allUsersCollectionRef.document()
        userInfo.userInfoDoumentID = document.documentID
        
        do {
            
            try document.setData(from: userInfo)
            
        } catch {
            print(error)
        }
    }
    
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
                            removeCompletion: @escaping () -> Void) {
        
        let myFavoriteSubCollectionRef = allUsersCollectionRef.document(userProfileDocumentID).collection("myFavorite")
        
        myFavoriteSubCollectionRef.whereField("favoriteDocumentID", isEqualTo: documendID).getDocuments { snapshot, error in
            
            if let error = error {
                print("Failed to fetch myFavorite collection \(error)")
                return
            }
            
            if let snapshot = snapshot {
                
                if snapshot.documents.isEmpty {
                    let favorite = SCFavorite(favoriteDocumentID: documendID)
                    do {
                        try myFavoriteSubCollectionRef.addDocument(from: favorite)
                        addCompletion()
                    } catch {
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
                          unfollowCompletion: @escaping () -> Void) {
        
        let myFollowingSubCollectionRef = allUsersCollectionRef.document(loggedInUserInfoDocumentID).collection("following")
        
        let othersFollowedBySubCollectionRef = allUsersCollectionRef.document(userInfoDoumentID).collection("followedBy")
        
        myFollowingSubCollectionRef.whereField("userID", isEqualTo: userInfo.userID).whereField("provider", isEqualTo: userInfo.provider).getDocuments { snapshot, error in
            
            if let error = error {
                print("Failed to fetch myFollowing subCollection collection \(error)")
                return
            }
            //找自己的following名單 如果沒有這個人的話，把它加入到我的following，把我加到它的follower，改變follow顏色
            
            if let snapshot = snapshot {
                
                if snapshot.documents.isEmpty {
                    
                    let logginUserInfo = loggedInUserInfo
                    let userInfo = userInfo
                    
                    do {
                        try myFollowingSubCollectionRef.addDocument(from: userInfo)
                        try othersFollowedBySubCollectionRef.addDocument(from: loggedInUserInfo)
                        followCompletion()
                        
                    } catch {
                        print(error)
                    }
                    
                } else {
                    //如果有的話，把它從我的following移除，把我從它的follower移除，改變follow顏色
                    //它在我collection中的documentID
                    guard let othersDocIDInMyCollec = snapshot.documents.first?.documentID else {
                        print("failed to get othersDocIDInMyCollec ref")
                        return
                    }
                    //把它從我的collection移除
                    myFollowingSubCollectionRef.document(othersDocIDInMyCollec).delete() { [weak self] error in
                        guard let self = self else { return }
                        
                        if let error = error {
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
    
    func removeFollowersDocID(userInfoDoumentID: String,
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
                    
                    //我在它的collection的ID
                    
                    guard let meInOthersCollection = snapshot.documents.first?.documentID else {
                        print("failed to get meInOthersCollection ref")
                        return
                    }
                    //把我從他的移除
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
    
    func addComment(to documentID: String, with comment: SCComment, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        
        let commentSubCollectionRef = db.collection(CommonUsage.CollectionName.allAudioFiles).document(documentID).collection(CommonUsage.CollectionName.comments)
        
        
        let document = commentSubCollectionRef.document()
        
        let newComment = SCComment(commentDocumentID: document.documentID,
                                   userID: comment.userID,
                                   userName: comment.userName,
                                   userImage: comment.userImage,
                                   createdTime: Timestamp(date:Date()),
                                   lastEditedTime: nil,
                                   comment: comment.comment)
        
        do {
            try document.setData(from: newComment)
            completion()
        } catch {
            print("FirebaseManager:mfailed to add comment")
        }
    }
    
    func fetchComment(from documentID: String, completion: @escaping (Result<[SCComment], Error>) -> Void) {
        
        let db = Firestore.firestore()
        
        let commentSubCollectionRef = db.collection(CommonUsage.CollectionName.allAudioFiles).document(documentID).collection(CommonUsage.CollectionName.comments)
        
        commentSubCollectionRef.getDocuments { snapshot, error in
            
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
    
    func checkCommentChange(from documentID: String, completion: @escaping (Result<[SCComment], Error>) -> Void) {
        
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
    
}
