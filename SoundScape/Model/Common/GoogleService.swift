//
//  GoogleService.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/6.
//

import Foundation

struct GoogleService: Decodable {
    
    enum CodingKeys: String, CodingKey {
        
        case clientId = "CLIENT_ID"
        case reversedClientId = "REVERSED_CLIENT_ID"
        case apiKey = "API_KEY"
        case gcmSenderId = "GCM_SENDER_ID"
        case plistVersion = "PLIST_VERSION"
        case bundleId = "BUNDLE_ID"
        case projectId = "PROJECT_ID"
        case storageBucket = "STORAGE_BUCKET"
        case isAdsEnabled = "IS_ADS_ENABLED"
        case isAnalyticsEnabled = "IS_ANALYTICS_ENABLED"
        case isAppInviteEnabled = "IS_APPINVITE_ENABLED"
        case isGcmEnabled = "IS_GCM_ENABLED"
        case isSignInEnabled = "IS_SIGNIN_ENABLED"
        case googleAppId = "GOOGLE_APP_ID"
    }

    
    let clientId: String
    let reversedClientId: String
    let apiKey: String
    let gcmSenderId: String
    let plistVersion: String
    let bundleId: String
    let projectId: String
    let storageBucket: String
    let isAdsEnabled: Bool
    let isAnalyticsEnabled: Bool
    let isAppInviteEnabled: Bool
    let isGcmEnabled: Bool
    let isSignInEnabled: Bool
    let googleAppId: String
}
