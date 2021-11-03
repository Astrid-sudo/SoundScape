//
//  SignInViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/3.
//

import UIKit
import AuthenticationServices
import CryptoKit
import FirebaseAuth

class SignInViewController: UIViewController {
    
    fileprivate var currentNonce: String?
    
    // MARK: - life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundColor()
        setAppImageView()
        setAppNamelabel()
        setLogInWithAppeButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    // MARK: - action
    
    @objc func pressAppleSignIn() {
        performAppleSignIn()
    }
    
    // MARK: - method
    
    private func performAppleSignIn() {
        let request = createAppleIDRequest()
        let authorizartionController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizartionController.delegate = self
        authorizartionController.presentationContextProvider = self
        
        authorizartionController.performRequests()
    }
    
    private func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
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
    
    // MARK: - UI properties
    
    lazy var appImageView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 25
        image.layer.masksToBounds = true
        image.image = UIImage(named: "AppIcon")
        return image
    }()
    
    private lazy var appNamelabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scRed)
        label.layer.cornerRadius = 10
        label.textAlignment = .center
        label.font = UIFont(name: CommonUsage.fontBungee, size: 40)
        label.text = CommonUsage.Text.appName
        return label
    }()

    private lazy var logInWithAppeButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton()
        button.tintColor = .white
        button.addTarget(self, action: #selector(pressAppleSignIn), for: .touchUpInside)
        return button
    }()

}

// MARK: - apple signIn

extension SignInViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
          guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
          }
          guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return
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
            // User is signed in to Firebase with Apple.
            // ...
          }
        }
      }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
      // Handle error.
      print("Sign in with Apple errored: \(error)")
    }

}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        let sceneDelegate = UIApplication.shared.delegate as? SceneDelegate
        
        guard let window = sceneDelegate?.window else { return ASPresentationAnchor() }
        
        return window

    }
}

// MARK: - extension UI method

extension SignInViewController {
    
    private func setBackgroundColor() {
        view.backgroundColor = UIColor(named: CommonUsage.scLightBlue)
    }
    
    private func setAppImageView() {
        view.addSubview(appImageView)
        appImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            appImageView.heightAnchor.constraint(equalToConstant: 80),
            appImageView.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setAppNamelabel() {
        view.addSubview(appNamelabel)
        appNamelabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appNamelabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appNamelabel.topAnchor.constraint(equalTo: appImageView.bottomAnchor, constant: 32)
        ])
    }
    
    private func setLogInWithAppeButton() {
        view.addSubview(logInWithAppeButton)
        logInWithAppeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logInWithAppeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logInWithAppeButton.topAnchor.constraint(equalTo: appNamelabel.bottomAnchor, constant: 32),
            logInWithAppeButton.widthAnchor.constraint(equalToConstant: 200),
            logInWithAppeButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

}
