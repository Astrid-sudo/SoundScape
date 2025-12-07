//
//  SettingViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/2.
//

import UIKit
import Firebase

class SettingViewController: UIViewController {
    
    // MARK: - properties
    
    var settingsOptions = ["Privacy Policy", "Delete Account", "About", "Log Out"]
    
    let signInHelper = SignInHelper.shared
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        addLottie()
        setBackgroundColor()
        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        AudioPlayerWindow.shared.window?.isHidden = true
        animationView.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        animationView.stop()
    }
    
    // MARK: - UI properties
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor(named: CommonUsage.scBlue)
        table.dataSource = self
        table.delegate = self
        table.allowsSelection = true
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.reuseIdentifier)
        return table
    }()
    
    private let animationView = LottieWrapper.shared.createLottieAnimationView(lottieType: .womanWalking,
                                                                               frame: CGRect(x: 0,
                                                                                             y: 80,
                                                                                             width: CommonUsage.screenWidth,
                                                                                             height: CommonUsage.screenHeight / 3))
    
    // MARK: - action
    
    @objc func backToLastPage() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - method
    
    private func navigateToSignInPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let signInViewController = storyboard.instantiateViewController(withIdentifier: String(describing: SignInViewController.self)) as? SignInViewController else { return }
        navigationController?.pushViewController(signInViewController, animated: true)
    }
    
    private func popSignOutAlert() {
        
        let alert = UIAlertController(title: "Are you sure ?",
                                      message: "Looking forward to hearing from you again.",
                                      preferredStyle: .alert )
        
        let okButton = UIAlertAction(title: "Log out", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.signInHelper.signOutAuth {
                self.navigateToSignInPage()
            }
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(cancelButton)
        alert.addAction(okButton)
        
        self.present(alert, animated: true, completion: nil)

    }

    private func popDeleteAccountAlert() {
        let message = """
        ⚠️ This action cannot be undone.

        All of your data will be permanently deleted:
        • All your audio posts
        • All comments
        • Profile information
        • Followers and following lists
        • All uploaded files

        Are you sure you want to delete your account?
        """

        let alert = UIAlertController(
            title: "Delete Account",
            message: message,
            preferredStyle: .alert
        )

        let deleteButton = UIAlertAction(title: "Delete Account", style: .destructive) { [weak self] _ in
            self?.performAccountDeletion()
        }

        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(cancelButton)
        alert.addAction(deleteButton)

        self.present(alert, animated: true, completion: nil)
    }

    private func performAccountDeletion() {
        // Get current user info
        guard let currentUser = Auth.auth().currentUser else {
            showErrorAlert(message: "No user is currently signed in.")
            return
        }

        let userID = currentUser.uid
        let userDocumentID = userID

        print("🗑️ Starting account deletion for userID: \(userID)")

        // Clear SignInManager image cache
        print("🧹 Clearing SignInManager image cache...")
        SignInManager.shared.currentUserPic = nil
        SignInManager.shared.currentUserCover = nil

        // Show loading indicator
        let loadingAlert = UIAlertController(title: "Deleting Account", message: "Please wait...", preferredStyle: .alert)
        present(loadingAlert, animated: true)

        // Perform deletion
        FirebaseManager.shared.deleteUserAccount(
            userDocumentID: userDocumentID,
            userID: userID,
            progressHandler: { [weak self] progressMessage in
                print("🗑️ Progress: \(progressMessage)")
                DispatchQueue.main.async {
                    loadingAlert.message = progressMessage
                }
            },
            errorCompletion: { [weak self] errorMessage in
                print("❌ Deletion failed: \(errorMessage)")
                DispatchQueue.main.async {
                    loadingAlert.dismiss(animated: true) {
                        self?.showErrorAlert(message: "Failed to delete account: \(errorMessage)")
                    }
                }
            },
            successCompletion: { [weak self] in
                print("✅ Account deletion completed successfully")
                DispatchQueue.main.async {
                    loadingAlert.dismiss(animated: true) {
                        // Sign out locally before navigating
                        try? Auth.auth().signOut()
                        self?.navigateToSignInPage()
                    }
                }
            }
        )
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
    
    // MARK: - UI method
    
    private func setBackgroundColor() {
        view.backgroundColor = UIColor(named: CommonUsage.scBlue)
    }
    
    private func setNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.title = CommonUsage.Text.settings
        navigationController?.navigationBar.barTintColor = UIColor(named: CommonUsage.scBlue)
        let font = UIFont(name: CommonUsage.fontBungee, size: 28)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font,
                                                                   NSAttributedString.Key.foregroundColor: UIColor(named: CommonUsage.scWhite)]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: self,action: #selector(backToLastPage))
        navigationItem.leftBarButtonItem?.image = UIImage(systemName: CommonUsage.SFSymbol.back)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: CommonUsage.scWhite)
    }
    
    private func setTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.centerYAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func addLottie() {
        view.addSubview(animationView)
    }
    
}

// MARK: - conform to UITableViewDataSource

extension SettingViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingsOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.reuseIdentifier, for: indexPath) as? SettingTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.configCell(content: settingsOptions[indexPath.row])
        return cell
    }
}

// MARK: - conform to UITableViewDelegate

extension SettingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 3 {
            popSignOutAlert()
        }
        
        if indexPath.row == 0 {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let privacyPolicyVC = storyboard.instantiateViewController(withIdentifier: String(describing: PrivacyPolicyViewController.self)) as? PrivacyPolicyViewController else { return }
            
            navigationController?.pushViewController(privacyPolicyVC, animated: true)
            
        }
        
        if indexPath.row == 1 {
            popDeleteAccountAlert()
        }
    }
    
}
