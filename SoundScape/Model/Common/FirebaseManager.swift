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
    
    private let storage = Storage.storage().reference()
    
    private let allAudioCollectionRef = Firestore.firestore().collection(CommonUsage.CollectionName.allAudioFiles)
    
    private let allUsersCollectionRef = Firestore.firestore().collection(CommonUsage.CollectionName.allUsers)
    
    // MARK: - init / deinit
    
    private init() {}
    
    deinit {
        postListener?.remove()
        favoriteListener?.remove()
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
    
    func upload(localURL: URL, post: SCPost) {
        
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
    
    // MARK: - member method
    
    
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
    
}
