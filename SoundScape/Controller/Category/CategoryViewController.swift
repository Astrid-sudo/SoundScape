//
//  CategoryViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/29.
//

import UIKit

class CategoryViewController: UIViewController {
    
    // MARK: - properties
    
    private let remotePlayHelper = RemotePlayHelper.shared
    
    private var category: AudioCategory?
    
    private var profileSection: ProfilePageSection?
    
    private var audioFiles = [SCPost]() {
       
        didSet {
            
            if category != nil {
                filterCategory()
            }
            
            if profileSection != nil {
                filterSection()

            }
        }
    }
    
    private var data = [SCPost]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var displayUserID: String? {
        didSet {
            fetchUserFavoriteList()
            fetchAmountOfFollows()
        }
    }
    
    private var userFavoriteDocumentIDs: [String]? {
        didSet {
            if profileSection != nil {
                filterSection()
            }

            tableView.reloadData()
        }
    }
    private var othersFollowingList: [SCFollow]? {
        didSet {
            if profileSection != nil {
                filterSection()
            }

            tableView.reloadData()
        }
    }
    
    let firebaseManager = FirebaseManager.shared
    
    let signInManager = SignInManager.shared
    // MARK: - UI properties
    
    private lazy var headView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var categoryTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scLightBlue)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: CommonUsage.fontBungee, size: 40)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var deleteHintLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scWhite)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.text = CommonUsage.Text.deleteAudioMessage
        return label
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.allowsSelection = true
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.backgroundColor = UIColor(named: CommonUsage.scBlue)
        table.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.reuseIdentifier)
        return table
    }()
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
        fetchAllAudioFile()
        setViewBackgroundColor()
        setHeadView()
        
        if category != nil {
            setCategoryTitleLabel()
        } else {
            setProfileTitleLabel()
        }
        
        setTableView()
        setHeadViewTitle()
        
        if profileSection == .myAudio,
            data.indices.contains(0),
           data[0].authorID == SignInManager.shared.currentUserInfoFirebase?.userID {
            setDeleteHintLabel()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - method
    
    private func loadAudio(localURL: URL, playInfo: PlayInfo) {
        AudioPlayHelper.shared.url = localURL
        AudioPlayHelper.shared.setPlayInfo(playInfo: playInfo)
    }
    
    private func fetchUserFavoriteList() {
        
        guard let userProfileDocumentID = displayUserID else {
            print("OtherProfileVC: Cant get favorite")
            return
        }
        
        firebaseManager.checkFavoriteChange(userProfileDocumentID: userProfileDocumentID) { [weak self]
            
            result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let scFavorites):
                self.userFavoriteDocumentIDs = scFavorites.map({$0.favoriteDocumentID})
                
            case .failure(let error):
                print("OtherProfileVC: Failed to get favoriteDocumentID \(error)")
                
            }
        }
    }
    
    private func fetchAmountOfFollows() {
        
        guard let userProfileDocumentID = displayUserID else {
            print("OtherProfileVC: Cant get favorite")
            return
        }

        firebaseManager.checkFollowingsChange(userInfoDoumentID: userProfileDocumentID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let followings):
                self.othersFollowingList = followings
                
            case .failure(let error): print(error)
            }
        }
    }


    private func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateAllAudioFile),
                                               name: .allAudioPostChange ,
                                               object: nil)
    }
    
    @objc func updateAllAudioFile() {
        fetchAllAudioFile()
    }
    
    private func fetchAllAudioFile() {
        audioFiles = AudioPostManager.shared.filteredAudioFiles
    }
    
    private func filterCategory() {
        guard let category = category else { return }
        let filteredPost = audioFiles.filter({$0.category == category.rawValue})
        data = filteredPost
    }
    
    private func filterSection() {
        
        switch profileSection {
            
        case .followingsLatest:
            
            var followingList: [SCFollow]?
            
            if displayUserID == nil {
                followingList = SignInManager.shared.currentUserFollowingList
            } else {
                followingList = othersFollowingList
            }
            
            if let followingList = followingList {
                var myFollowingsUserFiles = [SCPost]()
                for audioFile in audioFiles {
                    for following in followingList {
                        if audioFile.authorID == following.userID,
                            audioFile.authIDProvider == following.provider {
                            myFollowingsUserFiles.append(audioFile)
                        }
                    }
                }
                data = myFollowingsUserFiles
            }
            
        case .myFavorite:
            
            var favoriteList: [String]?
            
            if displayUserID == nil {
                favoriteList = SignInManager.shared.currentUserFavoriteDocumentIDs
            } else {
                favoriteList = userFavoriteDocumentIDs
            }

            if let favoriteList = favoriteList {
                var myFavoriteFiles = [SCPost]()
                
                for audioFile in audioFiles {
                    for favorite in favoriteList {
                        if audioFile.documentID == favorite {
                            myFavoriteFiles.append(audioFile)
                        }
                    }
                }
                data = myFavoriteFiles
            }
            
        case .myAudio:
            
            var userID: String?
            
            if displayUserID == nil {
                userID = SignInManager.shared.currentUserInfoFirebase?.userID
            } else {
                userID = displayUserID
            }

            let myAudioFiles = audioFiles.filter({$0.authorID == userID})
            data = myAudioFiles
            
        default:
            break
        }
    }
    
    func config(category: AudioCategory) {
        // This method will be called by HomeViewController
        self.category = category
        self.profileSection = nil
        self.displayUserID = nil
    }
    
    func config(profileSection: ProfilePageSection) {
        // This method will be called by ProfileViewController
        self.profileSection = profileSection
        self.category = nil
        self.displayUserID = nil
    }
    
    func config(profileSection: ProfilePageSection, displayUserID: String) {
        // This method will be called by OthersProfileViewController
        self.profileSection = profileSection
        self.category = nil
        self.displayUserID = displayUserID
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
    
    func deletePost(documentID: String) {
        FirebaseManager.shared.deletePostInAllAudio(documentID: documentID) { [weak self] errorMessage in
            guard let self = self else { return }
            self.popErrorAlert(title: "Failed to delete post", message: errorMessage)
        }
    }
    
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
    
    private func blockThisUser(toBeBlockedID: String) {
        
        guard let currentUserDocID = signInManager.currentUserInfoFirebase?.userInfoDoumentID else { return }
        
        firebaseManager.addToBlackList(loggedInUserInfoDocumentID: currentUserDocID,
                                       toBeBlockedID: toBeBlockedID, completion: nil)
    }
    
    // MARK: - config UI method
    
    private func setViewBackgroundColor() {
        view.backgroundColor = UIColor(named: CommonUsage.scBlue)
    }
    
    private func setHeadView() {
        view.addSubview(headView)
        headView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headView.topAnchor.constraint(equalTo: view.topAnchor),
            headView.heightAnchor.constraint(equalToConstant: CommonUsage.screenHeight / 3.5)
        ])
    }
    
    private func setDeleteHintLabel() {
        view.addSubview(deleteHintLabel)
        deleteHintLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteHintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteHintLabel.bottomAnchor.constraint(equalTo: headView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setCategoryTitleLabel() {
        view.addSubview(categoryTitleLabel)
        categoryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryTitleLabel.leadingAnchor.constraint(equalTo: headView.leadingAnchor, constant: 16),
            categoryTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4)
        ])
    }
    
    private func setProfileTitleLabel() {
        view.addSubview(categoryTitleLabel)
        categoryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                        categoryTitleLabel.centerXAnchor.constraint(equalTo: headView.centerXAnchor),
                        categoryTitleLabel.centerYAnchor.constraint(equalTo: headView.centerYAnchor)
        ])
    }

    private func setTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: headView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setHeadViewTitle() {
        
        headView.image = UIImage(named: CommonUsage.audioImage2)
        
        if let category = category {
            categoryTitleLabel.text = category.rawValue
            
            switch category {
            case .nature:
                headView.image = CommonUsage.audioImages[8]
                
            case .meaningful:
                headView.image = CommonUsage.audioImages[6]
                
            case .unique:
                headView.image = CommonUsage.audioImages[3]
                
            case .city:
                headView.image = CommonUsage.audioImages[9]
                
            case .animal:
                headView.image = CommonUsage.audioImages[1]
                
            case .other:
                headView.image = CommonUsage.audioImages[11]
                
            }
            
        }
        
        if let profileSection = profileSection {
            categoryTitleLabel.text = profileSection.rawValue
            categoryTitleLabel.textColor = UIColor(named: CommonUsage.scWhite)
            headView.image = CommonUsage.audioImages[12]
        }
    }
    
}

// MARK: - conform to UITableViewDataSource

extension CategoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =
                tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.reuseIdentifier) as? CategoryTableViewCell else { return UITableViewCell()}
        let data = data[indexPath.row]
        cell.setContent(title: data.title, author: data.authorName, audioImageNumber: data.imageNumber)
        cell.selectionStyle = .none
        return cell
    }
    
}

// MARK: - conform to UITableViewDelegate

extension CategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        AudioPlayerWindow.shared.show()
        
        let playInfo = PlayInfo(title: data[indexPath.item].title,
                                author: data[indexPath.item].authorName,
                                content: data[indexPath.item].content,
                                duration: data[indexPath.item].duration,
                                documentID: data[indexPath.item].documentID,
                                authorUserID: data[indexPath.item].authorID,
                                audioImageNumber: data[indexPath.item].imageNumber,
                                authorAccountProvider: data[indexPath.item].authIDProvider)
        
        if let remoteURL = data[indexPath.item].audioURL {
            RemoteAudioManager.shared.downloadRemoteURL(documentID: data[indexPath.item].documentID,
                                                        remoteURL: remoteURL, completion: { localURL in
                self.loadAudio(localURL: localURL, playInfo: playInfo)
            },
            errorCompletion: { [weak self] errorMessage in
                guard let self = self else { return }
                self.popErrorAlert(title: "Failed to load this audio", message: errorMessage)
            }
 )
        }

    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        300
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == data.count - 1 {
            return 180
        } else {
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let row = indexPath.row
        let identifier = "\(row)" as NSString
        let post = data[row]
        
        if profileSection != nil {
            if profileSection == .myAudio,
                data[0].authorID == SignInManager.shared.currentUserInfoFirebase?.userID {
                
                return UIContextMenuConfiguration(
                    identifier: identifier, previewProvider: nil) { _ in
                        // 3
                        let deleteAction = UIAction(title: "Delete this audio",
                                                   image: nil) { [weak self] _ in
                            guard let self = self else { return }
                            self.popDeletePostAlert(documentID: self.data[row].documentID)
                        }
                        return UIMenu(title: "",
                                      image: nil,
                                      children: [deleteAction])
                    }
                
            } else {
                return nil
            }
        }
        
        if category != nil,
            post.authorID != signInManager.currentUserInfoFirebase?.userID {
            
            return UIContextMenuConfiguration(
                identifier: identifier, previewProvider: nil) { _ in
                    // 3
                    let blockAction = UIAction(title: "Block this user",
                                               image: nil) { _ in
                        self.popBlockAlert(toBeBlockedID: post.authorID)
                    }
                    return UIMenu(title: "",
                                  image: nil,
                                  children: [blockAction])
                }
        }
        return nil
    }
    
}
