//
//  Notification+Extension.swift
//  SoundScape
//
//  Created by Astrid on 2021/12/5.
//

import Foundation

extension Notification.Name {
    
    // player
    static let playingAudioChange = Notification.Name("playingAudioChange")
    static let didItemPlayToEndTime = Notification.Name("didItemPlayToEndTime")
    static let didCurrentTimeChange = Notification.Name("didCurrentTimeChange")
    static let didStateChange = Notification.Name("didStateChange")
    static let remoteURLDidSelect = Notification.Name("remoteURLDidSelect")
    static let didItemDurationChange = Notification.Name("didItemDurationChange")
    static let audioPlayHelperUpdateTime = Notification.Name("audioPlayHelperUpdateTime")
    static let audioPlayHelperDidPlayEnd = Notification.Name("audioPlayHelperDidPlayEnd")
    static let audioPlayHelperError = Notification.Name("audioPlayHelperError")
    
    // user info
    static let currentUserFavDocIDChange = Notification.Name("currentUserFavDocIDChange")
    static let currentUserFollowingsChange = Notification.Name("currentUserFollowingsChange")
    static let currentUserFollowersChange = Notification.Name("currentUserFollowersChange")
    static let currentUserPicChange = Notification.Name("currentUserPicChange")
    static let currentUserCoverChange = Notification.Name("currentUserCoverChange")
    static let currentUserBlacklistChange = Notification.Name("currentUserBlacklistChange")
    static let fetchLoginUserError = Notification.Name("fetchLoginUserError")
    static let failedFetchFavorite = Notification.Name("failedFetchFavorite")
    static let failedFetchFollowingList = Notification.Name("failedFetchFollowingList")
    static let failedFetchFollowerList = Notification.Name("failedFetchFollowerList")
    static let failedFetchUserProfilePic = Notification.Name("failedFetchUserProfilePic")
    static let failedFetchUserCoverPic = Notification.Name("failedFetchUserCoverPic")
    static let failedFetchBlackList = Notification.Name("failedFetchBlackList")
    
    // post
    static let allAudioPostChange = Notification.Name("allAudioPostChange")
    static let fetchAudioPostError = Notification.Name("fetchAudioPostError")
}
