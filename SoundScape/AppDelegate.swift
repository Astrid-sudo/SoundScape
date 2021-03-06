//
//  AppDelegate.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/18.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import GoogleMaps

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        IQKeyboardManager.shared.enable = true
        
        if let user = Auth.auth().currentUser {
            print("You're sign in as \(user.uid), email: \(user.email), from provider: \(user.providerID)")
        }
        
        var googleApiKey: String?
        
        if let url = Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") {
            if let data = try? Data(contentsOf: url),
               let googleServices = try? PropertyListDecoder().decode(GoogleService.self, from: data) {
                print(googleServices)
                googleApiKey = googleServices.apiKey
            }
        }
        
        if let googleApiKey = googleApiKey {
            GMSServices.provideAPIKey(googleApiKey)
        }
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            return .portrait
        }

    
    
}

