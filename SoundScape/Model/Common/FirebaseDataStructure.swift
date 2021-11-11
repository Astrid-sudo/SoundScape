//
//  FirebaseDataStructure.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/31.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import CoreLocation

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
    let userProfileCover: URL?
    var userInfoDoumentID: String?
}

struct SCPicture: Codable {
    var picture: String
}

struct SCBlockUser: Codable {
    let userID: String
}

struct SCFollow: Codable {
    let userID: String
    let provider: String
}

struct SCFavorite: Codable {
    let favoriteDocumentID: String
}

struct SCPost: Codable, Hashable {
    var documentID: String
    var authorID: String
    var authIDProvider: String
    var authorName: String
    var title: String
    var content: String
    var createdTime: Timestamp?
    var lastEditedTime: Timestamp?
    var audioURL: URL?
    var imageNumber: Int
    var category: String
    var audioLocation: GeoPoint?
    var duration: Double
}

struct SCComment: Codable {
    let commentDocumentID: String?
    let userID: String
    let userName: String
    var userImage: URL?
    var createdTime: Timestamp?
    var lastEditedTime: Timestamp?
    var comment: String
}

struct SCLocation: Codable {
    let audioLocation: GeoPoint
    let audioDocumentID: String
    let authorID: String
    let authIDProvider: String
    let locationDocumentID: String
}

func clLocationToGepPoint(cl: CLLocationCoordinate2D?) -> GeoPoint? {
    guard let cl = cl else { return nil }
    let latitude = cl.latitude
    let longitude = cl.longitude
    return GeoPoint(latitude: latitude, longitude: longitude)
}
