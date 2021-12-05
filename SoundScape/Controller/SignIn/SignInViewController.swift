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
        setAndLabel()
        setLAEUButton()
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
        image.image = UIImage(named: "signInPic")
        return image
    }()
    
    private lazy var appNamelabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: Constant.scRed)
        label.layer.cornerRadius = 10
        label.textAlignment = .center
        label.font = UIFont(name: Constant.fontBungee, size: 40)
        label.text = Constant.Text.appName
        return label
    }()
    
    private lazy var noticeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: Constant.scWhite)
        label.textAlignment = .center
        label.font = UIFont(name: Constant.fontSemibold, size: 12)
        label.text = Constant.Text.logInNotice
        return label
    }()
    
    private lazy var viewPolicyButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constant.Text.privacyPolicy, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(presentPolicy), for: .touchUpInside)
        return button
    }()
    
    private lazy var andLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: Constant.scWhite)
        label.textAlignment = .center
        label.font = UIFont(name: Constant.fontSemibold, size: 12)
        label.text = Constant.Text.and
        return label
    }()
    
    private lazy var LAEUButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constant.Text.laeuButton, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(presentLAEU), for: .touchUpInside)
        button.titleLabel?.font = UIFont(name: Constant.font, size: 10)
        return button
    }()

    // MARK: - action
    
    @objc func presentPolicy() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let policyVc = storyboard.instantiateViewController(withIdentifier: String(describing: PrivacyPolicyViewController.self)) as? PrivacyPolicyViewController else { return }
        
        present(policyVc, animated: true, completion: nil)
    }
    
    @objc func presentLAEU() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let lAEUViewController = storyboard.instantiateViewController(withIdentifier: String(describing: LAEUViewController.self)) as? LAEUViewController else { return }
        
        present(lAEUViewController, animated: true, completion: nil)
    }
    
}

// MARK: - extension UI method

extension SignInViewController {
    
    private func setBackgroundColor() {
        view.backgroundColor = UIColor(named: Constant.logInBlue)
    }
    
    private func setAppImageView() {
        view.addSubview(appImageView)
        appImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            appImageView.heightAnchor.constraint(equalToConstant: 300),
            appImageView.widthAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setAppNamelabel() {
        view.addSubview(appNamelabel)
        appNamelabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appNamelabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appNamelabel.topAnchor.constraint(equalTo: appImageView.bottomAnchor, constant: -60)
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
    
    private func setAndLabel() {
        view.addSubview(andLabel)
        andLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            andLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            andLabel.topAnchor.constraint(equalTo: viewPolicyButton.bottomAnchor, constant: 4)
        ])
    }
    
    private func setLAEUButton() {
        view.addSubview(LAEUButton)
        LAEUButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            LAEUButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            LAEUButton.topAnchor.constraint(equalTo: andLabel.bottomAnchor, constant: 4)
        ])
    }
    
    private func setLogInWithAppeButton() {
        let logInWithAppeButton = signInHelper.logInWithAppeButton
        view.addSubview(logInWithAppeButton)
        logInWithAppeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logInWithAppeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logInWithAppeButton.topAnchor.constraint(equalTo: LAEUButton.bottomAnchor, constant: 16),
            logInWithAppeButton.widthAnchor.constraint(equalToConstant: 200),
            logInWithAppeButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
}
