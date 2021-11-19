//
//  HomeVC.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/22.
//

import UIKit

class HomeVC: UIViewController {
    
    // MARK: - properties
    
    let firebaseManager = FirebaseManager.shared
    
    let signInManager = SignInManager.shared
    
    var audioFiles = [SCPost]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - UI properties
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.allowsSelection = false
        table.separatorStyle = .singleLine
        table.showsVerticalScrollIndicator = false
        table.backgroundColor = .clear
        table.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.reuseIdentifier)
        table.register(HomeTableViewHeader.self, forHeaderFooterViewReuseIdentifier: HomeTableViewHeader.reuseIdentifier)
        return table
    }()
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        addObserver()
        fetchAllAudioFile()
        setTableView()
        setViewBackgroundcolor()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - config UI method
    
    private func setViewBackgroundcolor() {
        view.backgroundColor = UIColor(named: CommonUsage.scBlue)
    }
    
    private func setNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for:UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.title = CommonUsage.Text.appName
        navigationController?.navigationBar.barTintColor = UIColor(named: CommonUsage.scBlue)
        let font = UIFont(name: CommonUsage.fontBungee, size: 28)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font,
                                                                   NSAttributedString.Key.foregroundColor: UIColor(named: CommonUsage.scWhite)]
    }
    
    private func setTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - method
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateAllAudioFile),
                                               name: .allAudioPostChange ,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fetchAudioPostError),
                                               name: .fetchAudioPostError ,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fetchLoginUserError),
                                               name: .fetchLoginUserError ,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(failedFetchFavorite),
                                               name: .failedFetchFavorite ,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(failedFetchFollowingList),
                                               name: .failedFetchFollowingList ,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(failedFetchFollowerList),
                                               name: .failedFetchFollowerList ,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(failedFetchBlackList),
                                               name: .failedFetchBlackList ,
                                               object: nil)
    }
    
    @objc func failedFetchBlackList(notification: Notification) {
        guard let error = notification.userInfo?["UserInfo"] as? String else { return }
        popErrorAlert(title: "Failed to fetch loggin user's black list", message: error)
    }
    
    @objc func failedFetchFollowerList(notification: Notification) {
        guard let error = notification.userInfo?["UserInfo"] as? String else { return }
        popErrorAlert(title: "Failed to fetch loggin user's follower list", message: error)
    }
    
    @objc func failedFetchFollowingList(notification: Notification) {
        guard let error = notification.userInfo?["UserInfo"] as? String else { return }
        popErrorAlert(title: "Failed to fetch loggin user's following list", message: error)
    }
    
    @objc func failedFetchFavorite(notification: Notification) {
        guard let error = notification.userInfo?["UserInfo"] as? String else { return }
        popErrorAlert(title: "Failed to fetch loggin user's favorite", message: error)
    }
    
    @objc func fetchLoginUserError(notification: Notification) {
        guard let error = notification.userInfo?["UserInfo"] as? String else { return }
        popErrorAlert(title: "Failed to fetch loggin user's info", message: error)
    }
    
    @objc func fetchAudioPostError(notification: Notification) {
        guard let error = notification.userInfo?["UserInfo"] as? String else { return }
        popErrorAlert(title: "Fetch audio post error", message: error)
    }
    
    @objc func updateAllAudioFile() {
        fetchAllAudioFile()
    }
    
    private func fetchAllAudioFile() {
        audioFiles = AudioPostManager.shared.filteredAudioFiles
    }
    
    private func blockThisUser(toBeBlockedID: String) {
        
        guard let currentUserDocID = signInManager.currentUserInfoFirebase?.userInfoDoumentID else { return }
        
        firebaseManager.addToBlackList(loggedInUserInfoDocumentID: currentUserDocID,
                                       toBeBlockedID: toBeBlockedID, completion: nil)
    }
    
    func deletePost(documentID: String) {
        FirebaseManager.shared.deletePostInAllAudio(documentID: documentID) { [weak self] errorMessage in
            guard let self = self else { return }
            self.popErrorAlert(title: "Failed to delete post", message: errorMessage)
        }
    }

}

// MARK: - conform to UITableViewDataSource

extension HomeVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        AudioCategory.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.reuseIdentifier) as? HomeTableViewCell else { return UITableViewCell()
        }
        
        let filteredFiles = audioFiles.filter({$0.category == AudioCategory.allCases[indexPath.section].rawValue})
        cell.backgroundColor = UIColor(named: CommonUsage.scBlue)
        cell.delegate = self
        cell.firebaseData = filteredFiles
        cell.category = AudioCategory.allCases[indexPath.item].rawValue
        return cell
    }
    
}

// MARK: - conform to UITableViewDelegate

extension HomeVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomeTableViewHeader.reuseIdentifier) as? HomeTableViewHeader else { return UIView() }
        headerView.presentInPage = .audioCategory
        headerView.delegate = self
        headerView.config(section: section, content: AudioCategory.allCases[section].rawValue)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        300
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath == IndexPath(row: 0, section: 5) {
            
            return 230
            
        } else {
            
            return 168
            
        }
        
    }
    
}

// MARK: - conform to PressPassableDelegate

extension HomeVC: PressPassableDelegate {
    
    func goSectionPage(from section: Int, sectionPageType: SectionPageType) {
        
        let category = AudioCategory.allCases[section]
        
        var data = [SCPost]()
        
        for file in audioFiles {
            
            if file.category == category.rawValue {
                data.append(file)
            }
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let categoryPage = storyboard.instantiateViewController(withIdentifier: String(describing: CategoryViewController.self)) as? CategoryViewController else { return }
        
        categoryPage.config(category: category)
        navigationController?.pushViewController(categoryPage, animated: true)
    }
    
    func goCategoryPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let categoryPage = storyboard.instantiateViewController(withIdentifier: String(describing: CategoryViewController.self)) as? CategoryViewController else { return }
        
        navigationController?.pushViewController(categoryPage, animated: true)
    }
    
}

// MARK: - conform to AlertPresentableDelegate

extension HomeVC: AlertPresentableDelegate {
    
    func popBlockAlert(toBeBlockedID: String) {
       
       let alert = UIAlertController(title: "Are you sure?",
                                     message: "You can't see this user's comments, audio posts and profile page after blocking. And you have no chance to unblock this user in the future",
                                     preferredStyle: .alert )
       
       let okButton = UIAlertAction(title: "Block", style: .destructive) {[weak self] _ in
           guard let self = self else { return }
           self.blockThisUser(toBeBlockedID: toBeBlockedID)
       }
       
       let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
       
       alert.addAction(cancelButton)
       alert.addAction(okButton)
       
       present(alert, animated: true, completion: nil)
   }

    func popDeletePostAlert(documentID: String) {
        
        let alert = UIAlertController(title: "Are you sure to delete this audio?",
                                      message: nil ,
                                      preferredStyle: .alert )
        
        let okButton = UIAlertAction(title: "Delete", style: .destructive) {[weak self] _ in
            guard let self = self else { return }
            self.deletePost(documentID: documentID)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(cancelButton)
        alert.addAction(okButton)
        
        present(alert, animated: true, completion: nil)
    }
    
    func popErrorAlert(errorMessage: String?) {
        popErrorAlert(title: "Failed to download audio", message: errorMessage)
    }
    
}
