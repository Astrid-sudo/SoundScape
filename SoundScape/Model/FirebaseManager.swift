//
//  FirebaseManager.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

protocol PostsPassableDelegate: AnyObject {
    func passPosts(posts: [SCPost])
}

//enum Category: String, CaseIterable {
//    case nature
//    case city
//    case unique
//    case meaningful
//    case other
//}

enum AudioCategory: String, CaseIterable {
    case nature = "Nature"
    case meaningful = "Meaningful"
    case unique = "Unique"
    case city = "City"
    case animal = "Animal"
    case other = "Other"
}

struct SCUser: Codable {
    let userID: String
    let provider: String
    let username: String
    let userEmail: String
    let userPic: URL?
}

struct SCFollow {
    let userID: String
    let provider: String
}

struct SCFavorite {
    let documentID: String
}

struct SCPost: Codable {
    var documentID: String
    var authorID: String
    var authIDProvider: String
    var authorName: String
    var title: String
    var content: String
    var createdTime: Timestamp?
    var lastEditedTime: Timestamp?
    var imageURL: URL?
    var audioURL: URL?
    //    var audioBase64: String?
    var category: String
    var audioLocation: GeoPoint?
    var duration: Double
}

struct SCComment: Codable {
    let documentID: String
    let userID: String
    let userName: String
    let userImage: URL?
    let createdTime: Timestamp
    var comment: String
    var atTimeCode: String?
}

struct SCLocation {
    let audioLocation: GeoPoint
    let audioDocumentID: String
    let authorID: String
    let authIDProvider: String
    let locationDocumentID: String
}

class FirebaseManager {
    
    // MARK: - properties
    
    static let shared = FirebaseManager()
    
    weak var delegate: PostsPassableDelegate?
    
    private var postListener: ListenerRegistration?
    
    private let storage = Storage.storage().reference()
    
    private let allAudioCollectionRef = Firestore.firestore().collection(CommonUsage.CollectionName.allAudioFiles)
    
    // MARK: - init / deinit
    
    private init () {}
    
    deinit {
        postListener?.remove()
    }
    
    // MARK: - method
    
    func fetchPost() {
        
        allAudioCollectionRef.order(by: "createdTime").getDocuments { [weak self] snapshot, error in
            guard let self = self,
                  let snapshot = snapshot else { return }
            let posts = snapshot.documents.compactMap { snapshot in
                try? snapshot.data(as: SCPost.self)
            }
            self.delegate?.passPosts(posts: posts.reversed())
        }
    }
    
    func checkPostChange() {
        
        postListener = allAudioCollectionRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            snapshot.documentChanges.forEach { documentChange in
                switch documentChange.type {
                case .added:
                    self.fetchPost()
                    print("added")
                case .modified:
                    self.fetchPost()
                    print("modified")
                case .removed:
                    self.fetchPost()
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
    
}

