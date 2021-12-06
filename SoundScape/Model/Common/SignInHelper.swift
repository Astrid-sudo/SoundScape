//
//  SignInHelper.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/3.
//

import UIKit
import AuthenticationServices
import CryptoKit
import FirebaseAuth

class SignInHelper: NSObject {
    
    static let shared = SignInHelper()
    
    private override init() {}
    
    fileprivate var currentNonce: String?
    
    lazy var logInWithAppeButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(signInWithApple), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    // MARK: - action
    
    @objc func signInWithApple() {
        performAppleSignIn()
    }
    
    // MARK: - sign out firebase auth
    
    func signOutAuth(completion: @escaping() -> Void) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            completion()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    // MARK: - sign in with Apple method
    
    func performAppleSignIn() {
        let request = createAppleIDRequest()
        let authorizartionController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizartionController.delegate = self
        authorizartionController.presentationContextProvider = self
        
        authorizartionController.performRequests()
    }
    
    func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        return request
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
}

// MARK: - apple signIn

extension SignInHelper: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            
            var userName = "無名用戶"
            if let givenName = appleIDCredential.fullName?.givenName {
                userName = givenName
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error.localizedDescription)
                    return
                }
                
                if let authResult = authResult,
                   let _ = Auth.auth().currentUser {
                    
                    print("--------Sucessfully SignIn to firebase--------")
                    
                    LoggedInUserManager.shared.checkUserInFirebase(userID: authResult.user.uid,
                                                             userProvider: authResult.credential?.provider ?? "dont know" ,
                                                             userEmail: authResult.user.email ,
                                                             userName: userName)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    guard let tabBarController = storyboard.instantiateViewController(withIdentifier: SCTabBarController.reuseIdentifier) as? SCTabBarController else { return }
                    
                    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                    
                    sceneDelegate?.changeRootViewController(tabBarController)
                    
                }
                
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
}

// MARK: - conform ASAuthorizationControllerPresentationContextProviding

extension SignInHelper: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let sceneDelegate = UIApplication.shared.delegate as? SceneDelegate
        guard let window = sceneDelegate?.window else { return ASPresentationAnchor() }
        return window
    }
}
