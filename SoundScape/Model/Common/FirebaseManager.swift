//
//  FirebaseManager.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/21.
//

// swiftlint:disable file_length

import Foundation
import Firebase

struct FirebaseListenser {
    var registration: ListenerRegistration?
}

enum FirebaseCollection {
    
    case allAudioFiles
    case comments(audioDocumentID: String)
    
    case allLocations
    
    case allUsers
    case followedBy(userInfoDocumentID: String)
    case following(userInfoDocumentID: String)
    case myFavorite(userInfoDocumentID: String)
    case blackList(userInfoDocumentID: String)
    case profilePicture(userInfoDocumentID: String)
    
    var db: Firestore {
        return Firestore.firestore()
    }
    
    var reference: CollectionReference {
        
        switch self {
            
        case .allAudioFiles:
            return  db.collection(CommonUsage.CollectionName.allAudioFiles)
            
        case .allLocations:
            return db.collection(CommonUsage.CollectionName.allLocations)
            
        case .allUsers:
            return  db.collection(CommonUsage.CollectionName.allUsers)
            
        case .comments(let audioDocumentID):
            return db.collection(CommonUsage.CollectionName.allAudioFiles).document(audioDocumentID).collection(CommonUsage.CollectionName.comments)
            
        case .followedBy(let userInfoDocumentID):
            return db.collection(CommonUsage.CollectionName.allUsers).document(userInfoDocumentID).collection("followedBy")
            
        case .following(let userInfoDocumentID):
            return db.collection(CommonUsage.CollectionName.allUsers).document(userInfoDocumentID).collection("following")
            
        case .myFavorite(let userInfoDocumentID):
            return db.collection(CommonUsage.CollectionName.allUsers).document(userInfoDocumentID).collection("myFavorite")
            
        case .profilePicture(let userInfoDocumentID):
            return db.collection(CommonUsage.CollectionName.allUsers).document(userInfoDocumentID).collection("profilePicture")
            
        case .blackList(let userInfoDocumentID):
            return db.collection(CommonUsage.CollectionName.allUsers).document(userInfoDocumentID).collection("blackList")
        }
    }
}

enum FirebaseDocument {
    
    var db: Firestore {
        return Firestore.firestore()
    }

    case userInfoDoc(userInfoDocumentID: String)
    case userPicDoc(userInfoDocumentID: String)
    case userCoverDoc(userInfoDocumentID: String)

    var reference: DocumentReference {
        
        switch self {
        
        case .userInfoDoc(let userInfoDocumentID):
            return db.collection(CommonUsage.CollectionName.allUsers).document(userInfoDocumentID)
            
        case .userPicDoc(let userInfoDocumentID):
            return   db.collection(CommonUsage.CollectionName.allUsers).document(userInfoDocumentID).collection("profilePicture").document("userPic")
        case .userCoverDoc(let userInfoDocumentID):
            return db.collection(CommonUsage.CollectionName.allUsers).document(userInfoDocumentID).collection("profilePicture").document("coverPic")
        }
    }
}


class FirebaseManager {
    
    // MARK: - properties
    
    static let shared = FirebaseManager()
    
    var favoriteListener: ListenerRegistration?
    var followersListenser: ListenerRegistration?
    var followingsListenser: ListenerRegistration?
    var commentListenser: ListenerRegistration?
    var userPicListenser: ListenerRegistration?
    var coverPicListenser: ListenerRegistration?
    var locationsListenser: ListenerRegistration?
    var blackListListenser: ListenerRegistration?
    
    private let storage = Storage.storage().reference()
    
    // MARK: - init / deinit
    
    private init() {}
    
    deinit {
        favoriteListener?.remove()
        followersListenser?.remove()
        followingsListenser?.remove()
        commentListenser?.remove()
        userPicListenser?.remove()
        coverPicListenser?.remove()
        locationsListenser?.remove()
    }
    
    // MARK: - post method
    
    func upload(localURL: URL, post: SCPost,
                completion: @escaping () -> Void,
                errorCompletion:@escaping (_ errorMessage: String) -> Void) {
        
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
                
                let document = FirebaseCollection.allAudioFiles.reference.document(audioString)
                
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
    
    func deletePostInAllAudio(documentID: String,
                              errorCompletion: @escaping (_ errorMessage:String) -> Void,
                              succeededCompletion: @escaping () -> Void) {
        
        FirebaseCollection.allAudioFiles.reference.document(documentID).delete() { error in
            if let error = error {
                errorCompletion(error.localizedDescription)
                print("Error remove post in AllAudioCollection \(documentID), error: \(error)")
            } else {
                print("\(documentID) in AllAudioCollection successfully removed.")
                self.deletePostInAllLocation(documentID: documentID,
                                             errorCompletion: errorCompletion,
                                             succeededCompletion: succeededCompletion)
            }
        }
    }
    
    private func deletePostInAllLocation(documentID: String,
                                         errorCompletion: @escaping (_ errorMessage:String) -> Void, succeededCompletion: @escaping () -> Void) {
        
        FirebaseCollection.allLocations.reference.document(documentID).delete() { error in
            if let error = error {
                print("Error remove post \(documentID), error: \(error)")
                errorCompletion(error.localizedDescription)
            } else {
                print("\(documentID) in AllLocationCollection successfully removed.")
                self.deleteAudioInStorage(documentID: documentID,
                                          errorCompletion: errorCompletion,
                                          succeededCompletion: succeededCompletion)
            }
        }
    }
    
    private func deleteAudioInStorage(documentID: String,
                                      errorCompletion: @escaping (_ errorMessage:String) -> Void,
                                      succeededCompletion: @escaping () -> Void) {
        let audioName = documentID + ".m4a"
        let audioReference = storage.child("\(audioName)")
        
        audioReference.delete { error in
            if let error = error {
                print("Error remove audio \(audioReference), error: \(error)")
                errorCompletion(error.localizedDescription)
            } else {
                print("\(audioReference) in Storage successfully removed.")
                succeededCompletion()
            }
        }
        
    }
    
    func fetchUser(userID: String,
                   userIDProvider: String,
                   completion: @escaping (Result<SCUser, Error>) -> Void) {
        
        FirebaseCollection.allUsers.reference.whereField("userID", isEqualTo: userID).whereField("provider", isEqualTo: userIDProvider).getDocuments { snapshot, error in
            
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
    
    // MARK: - real member method
    
    func checkUsersInFirebase(userID: String, completion: @escaping (Result<SCUser, Error>) -> Void) {
        
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
                            documendID: String,
                            addCompletion: @escaping () -> Void,
                            removeCompletion: @escaping () -> Void,
                            errorCompletion: @escaping (_ errorMessage: String) -> Void) {
        
        let myFavoriteSubCollectionRef = FirebaseCollection.myFavorite(userInfoDocumentID: userProfileDocumentID).reference
        
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
    
    func collectionfetchData<T: Codable>(collectionType: FirebaseCollection,
                                         completion: @escaping (Result<[T], Error>) -> Void) {
        
        switch collectionType {
            
        case .allAudioFiles:
            collectionType.reference.order(by: "createdTime", descending: true).getDocuments { snapshot, error in
                if let error = error {
                    completion(Result.failure(error))
                    return
                }
                if let snapshot = snapshot {
                    let data = snapshot.documents.compactMap({ snapshot in
                        try? snapshot.data(as: T.self)
                    })
                    completion(Result.success(data))
                }
            }
            
        case .comments:
            collectionType.reference.order(by: "createdTime", descending: false).getDocuments { snapshot, error in
                if let error = error {
                    completion(Result.failure(error))
                    return
                }
                if let snapshot = snapshot {
                    let data = snapshot.documents.compactMap({ snapshot in
                        try? snapshot.data(as: T.self)
                    })
                    completion(Result.success(data))
                }
            }

        default:
            collectionType.reference.getDocuments { snapshot, error in
                if let error = error {
                    completion(Result.failure(error))
                    return
                }
                if let snapshot = snapshot {
                    let data = snapshot.documents.compactMap({ snapshot in
                        try? snapshot.data(as: T.self)
                    })
                    completion(Result.success(data))
                }
            }
        }
    }
    
    func collectionAddListener<T: Codable>(collectionType: FirebaseCollection,
                                           completion: @escaping (Result<[T],
                                                                  Error>) -> Void) -> ListenerRegistration? {
        
        let listener = collectionType.reference.addSnapshotListener { [weak self] snapshot, error in
            
            guard error == nil,
                  let self = self,
                  let snapshot = snapshot else { return }
            
            snapshot.documentChanges.forEach { documentChange in
                self.collectionfetchData(collectionType: collectionType,
                                         completion: completion)
            }
        }
        
        return listener
        
    }
    
    func documentFetchData<T: Codable>(documentType: FirebaseDocument,
                                         completion: @escaping (Result<T, Error>) -> Void){
        documentType.reference.getDocument { document, error in
            if let error = error {
                completion(Result.failure(error))
                return
            }
            
            if let document = document,
               document.exists {
                let data = try? document.data(as: T.self)
                if let data = data {
                    completion(Result.success(data))
                }
                
            } else {
                
                print("Document does not exist")
                
            }
        }
    }
    
    func documentAddListener<T: Codable>(documentType: FirebaseDocument,
                                           completion: @escaping (Result<T,
                                                                  Error>) -> Void) -> ListenerRegistration? {
        let listener = documentType.reference.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot,
                  snapshot.exists else { return }
            self.documentFetchData(documentType: documentType, completion: completion)
        }
        return listener
    }
    
    func manipulateFollow(userInfoDoumentID: String,
                          userInfo: SCFollow,
                          loggedInUserInfoDocumentID: String,
                          loggedInUserInfo: SCFollow,
                          followCompletion: @escaping () -> Void,
                          unfollowCompletion: @escaping () -> Void,
                          errorCompletion: @escaping (_ errorMessage:String) -> Void) {
        
        let myFollowingSubCollectionRef = FirebaseCollection.following(userInfoDocumentID: loggedInUserInfoDocumentID).reference
        
        let othersFollowedBySubCollectionRef = FirebaseCollection.followedBy(userInfoDocumentID: userInfoDoumentID).reference
        
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
        
        let othersFollowedBySubCollectionRef = FirebaseCollection.followedBy(userInfoDocumentID: userInfoDoumentID).reference
        
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
    
    // MARK: - comment
    
    func deleteComment(audioDocumentID: String,
                       commentDocumentID: String,
                       errorCompletion: @escaping (_ errorMessage:String) -> Void,
                       successedCompletion: @escaping() -> Void) {
        let db = Firestore.firestore()
        let commentRef = db.collection(CommonUsage.CollectionName.allAudioFiles).document(audioDocumentID).collection(CommonUsage.CollectionName.comments).document(commentDocumentID)
        
        commentRef.delete { error in
            if let error = error {
                print("Failed to delete comment \(commentRef), error: \(error)")
                errorCompletion(error.localizedDescription)
            } else {
                print("Succeffully delete comment \(commentRef)")
                successedCompletion()
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
    
    func uploadPicToFirebase(userDocumentID: String,
                             picString:String,
                             picType: PicType,
                             errorCompletion: @escaping (_ errorMessage:String) -> Void,
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
    
    // MARK: - Location
    
    func uploadGeoPointToAllLocations(audioDocumentID: String,
                                      locationData: SCLocation,
                                      completion: () -> Void,
                                      errorCompletion:@escaping (_ errorMessage:String) -> Void) {
        
        do {
            try FirebaseCollection.allLocations.reference.document(audioDocumentID).setData(from: locationData)
            completion()
        } catch {
            errorCompletion(error.localizedDescription)
            print("Failed to upload locationData to allLocations collection \(error)")
        }
        
    }
    
    // MARK: - Black List
    
    func addToBlackList(loggedInUserInfoDocumentID: String, toBeBlockedID: String, completion: (() -> Void)?) {
        
        let myBlackListSubCollectionRef = FirebaseCollection.blackList(userInfoDocumentID: loggedInUserInfoDocumentID).reference
        
        let user = SCBlockUser(userID: toBeBlockedID)
        
        do {
            
            try myBlackListSubCollectionRef.document(toBeBlockedID).setData(from: user)
            
            completion?()
            
        } catch {
            
            print("Failed to add black list")
        }
    }
    
}


// swiftlint:enable file_length
