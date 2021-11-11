//
//  SignInViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/3.
//

import UIKit

class SignInViewController: UIViewController {
    
    let signInHelper = SignInHelper.shared
    
    // MARK: - life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundColor()
        setAppImageView()
        setAppNamelabel()
        setNoticeLabel()
        setViewPolicyButton()
        setLogInWithAppeButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.setHidesBackButton(true, animated: true)
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - action
    
    @objc func pressAppleSignIn() {
        signInHelper.performAppleSignIn()
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
    
    private lazy var noticeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scWhite)
        label.textAlignment = .center
        label.font = UIFont(name: CommonUsage.fontSemibold, size: 12)
        label.text = CommonUsage.Text.logInNotice
        return label
    }()
    
    private lazy var viewPolicyButton: UIButton = {
        let button = UIButton()
        button.setTitle(CommonUsage.Text.privacyPolicy, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(presentPolicy), for: .touchUpInside)
        return button
    }()
    
    // MARK: - action
    
    @objc func presentPolicy() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let policyVc = storyboard.instantiateViewController(withIdentifier: String(describing: PrivacyPolicyViewController.self)) as? PrivacyPolicyViewController else { return }
        
        present(policyVc, animated: true, completion: nil)
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
    
    private func setNoticeLabel() {
        view.addSubview(noticeLabel)
        noticeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noticeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noticeLabel.topAnchor.constraint(equalTo: appNamelabel.bottomAnchor, constant: 16)
        ])
    }
    
    private func setViewPolicyButton() {
        view.addSubview(viewPolicyButton)
        viewPolicyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewPolicyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewPolicyButton.topAnchor.constraint(equalTo: noticeLabel.bottomAnchor, constant: 4)
        ])
    }
    
    private func setLogInWithAppeButton() {
        let logInWithAppeButton = signInHelper.logInWithAppeButton
        view.addSubview(logInWithAppeButton)
        logInWithAppeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logInWithAppeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logInWithAppeButton.topAnchor.constraint(equalTo: viewPolicyButton.bottomAnchor, constant: 32),
            logInWithAppeButton.widthAnchor.constraint(equalToConstant: 200),
            logInWithAppeButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    

}
