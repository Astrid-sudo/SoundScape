//
//  FirebaseManager.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/21.
//

import Foundation
import Firebase

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
            return  db
                .collection(Constant.allAudioFiles)
            
        case .allLocations:
            return db
                .collection(Constant.allLocations)
            
        case .allUsers:
            return  db
                .collection(Constant.allUsers)
            
        case .comments(let audioDocumentID):
            return db
                .collection(Constant.allAudioFiles)
                .document(audioDocumentID)
                .collection(Constant.comments)
            
        case .followedBy(let userInfoDocumentID):
            return db
                .collection(Constant.allUsers)
                .document(userInfoDocumentID)
                .collection(Constant.followedBy)
            
        case .following(let userInfoDocumentID):
            return db
                .collection(Constant.allUsers)
                .document(userInfoDocumentID)
                .collection(Constant.following)
            
        case .myFavorite(let userInfoDocumentID):
            return db
                .collection(Constant.allUsers)
                .document(userInfoDocumentID)
                .collection(Constant.myFavorite)
            
        case .profilePicture(let userInfoDocumentID):
            return db
                .collection(Constant.allUsers)
                .document(userInfoDocumentID)
                .collection(Constant.profilePicture)
            
        case .blackList(let userInfoDocumentID):
            return db
                .collection(Constant.allUsers)
                .document(userInfoDocumentID)
                .collection(Constant.blackList)
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
            return db
                .collection(Constant.allUsers)
                .document(userInfoDocumentID)
            
        case .userPicDoc(let userInfoDocumentID):
            return db
                .collection(Constant.allUsers)
                .document(userInfoDocumentID)
                .collection(Constant.profilePicture)
                .document(Constant.userPic)
            
        case .userCoverDoc(let userInfoDocumentID):
            return db
                .collection(Constant.allUsers)
                .document(userInfoDocumentID)
                .collection(Constant.profilePicture)
                .document(Constant.coverPic)
        }
    }
}

class FirebaseManager {
    
    // MARK: - properties
    
    static let shared = FirebaseManager()
    
    private let storage = Storage.storage().reference()
    
    // MARK: - init
    
    private init() {}
    
    // MARK: - generic methods
    
    func collectionfetchData<T: Codable>(collectionType: FirebaseCollection,
                                         completion: @escaping (Result<[T], Error>) -> Void) {
        
        switch collectionType {
            
        case .allAudioFiles:
            collectionType.reference.order(by: Constant.createdTime,
                                           descending: true).getDocuments { snapshot, error in
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
            collectionType.reference.order(by: Constant.createdTime,
                                           descending: false).getDocuments { snapshot, error in
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
            snapshot.documentChanges.forEach { _ in
                self.collectionfetchData(collectionType: collectionType,
                                         completion: completion)
            }
        }
        return listener
    }
    
    func documentFetchData<T: Codable>(documentType: FirebaseDocument,
                                       completion: @escaping (Result<T, Error>) -> Void) {
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
            guard error == nil,
                  let snapshot = snapshot,
                  snapshot.exists else { return }
            self.documentFetchData(documentType: documentType, completion: completion)
        }
        return listener
    }
    
    // MARK: - post methods
    
    func upload(localURL: URL,
                post: SCPost,
                completion: @escaping () -> Void,
                errorCompletion: @escaping (_ errorMessage: String) -> Void) {
        
        var fullPost = post
        let metadata = StorageMetadata()
        metadata.contentType = "audio/m4a"
        let audioString =  NSUUID().uuidString
        let audioName = audioString + ".m4a"
        
        let audioReference = storage.child("\(audioName)")
        let uploadTask = audioReference.putFile(from: localURL, metadata: nil) { _, error in
            if let error = error {
                errorCompletion(error.localizedDescription)
                return
            }
            
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
                                                      authIDProvider: fullPost.authIDProvider,
                                                      locationDocumentID: fullPost.documentID)
                        
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
                              errorCompletion: @escaping (_ errorMessage: String) -> Void,
                              succeededCompletion: @escaping () -> Void) {
        FirebaseCollection.allAudioFiles.reference.document(documentID).delete() { error in
            if let error = error {
                errorCompletion(error.localizedDescription)
            } else {
                self.deletePostInAllLocation(documentID: documentID,
                                             errorCompletion: errorCompletion,
                                             succeededCompletion: succeededCompletion)
            }
        }
    }
    
    private func deletePostInAllLocation(documentID: String,
                                         errorCompletion: @escaping (_ errorMessage: String) -> Void,
                                         succeededCompletion: @escaping () -> Void) {
        FirebaseCollection.allLocations.reference.document(documentID).delete() { error in
            if let error = error {
                errorCompletion(error.localizedDescription)
            } else {
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
    
    // MARK: - comment methods
    
    func deleteComment(audioDocumentID: String,
                       commentDocumentID: String,
                       errorCompletion: @escaping (_ errorMessage:String) -> Void,
                       successedCompletion: @escaping () -> Void) {
        let commentRef = FirebaseCollection.comments(audioDocumentID: audioDocumentID).reference.document(commentDocumentID)
        commentRef.delete { error in
            if let error = error {
                errorCompletion(error.localizedDescription)
            } else {
                successedCompletion()
            }
        }
    }
    
    func addComment(to documentID: String,
                    with comment: SCComment,
                    completion: @escaping () -> Void,
                    errorCompletion: @escaping (String) -> Void) {
        let commentSubCollectionRef = FirebaseCollection.comments(audioDocumentID: documentID).reference
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
        }
    }
    
    // MARK: - location methods
    
    func uploadGeoPointToAllLocations(audioDocumentID: String,
                                      locationData: SCLocation,
                                      completion: () -> Void,
                                      errorCompletion: @escaping (_ errorMessage:String) -> Void) {
        do {
            try FirebaseCollection.allLocations.reference
                .document(audioDocumentID).setData(from: locationData)
            completion()
        } catch {
            errorCompletion(error.localizedDescription)
        }
    }
    
}
