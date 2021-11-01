//
//  ProfileViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/30.
//

import UIKit

struct UserIdentity {
    let userID: String
    let userIDProvider: String
}

enum ProfilePageSection: String, CaseIterable {
    case followingsLatest = "Followings Latest"
    case myFavorite = "My Favorite"
    case myAudio = "My Audio"
}

class ProfileViewController: UIViewController {
    
    // MARK: - properties
    
//    var idWillDisplay: UserIdentity?
//
//    var userWillDisplay: SCUser? {
//        didSet {
//            setUserProfile()
//        }
//    }
//
//    var displayOthersProfile = false
//
    let signInManager = SignInManager.shared
    
    let firebaseManager = FirebaseManager.shared
    
    private var allAudioFiles = [SCPost]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var currentUserFavoriteDocumentIDs: [String]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var currentUserFollowingList: [SCFollow]? {
        didSet {
            tableView.reloadData()
        }
    }

    private var numbersOfFollowers: Int? {
        didSet {
            guard let numbersOfFollowers = numbersOfFollowers else { return }
            followersNumberLabel.text = String(describing: numbersOfFollowers)
        }
    }
    
    private var numbersOfFollowings: Int? {
        didSet {
            guard let numbersOfFollowings = numbersOfFollowings else { return }
            followingsNumberLabel.text = String(describing: numbersOfFollowings)
        }
    }


    
    // MARK: - UI properties
    
    private lazy var coverImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleToFill
        return image
    }()
    
    private lazy var userImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleToFill
        image.clipsToBounds = true
        
        return image
    }()
    
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
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scWhite)
        label.font = UIFont(name: CommonUsage.fontSemibold, size: 24)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var followersNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scWhite)
        label.font = UIFont(name: CommonUsage.fontSemibold, size: 14)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var followersTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scGray)
        label.font = UIFont(name: CommonUsage.fontSemibold, size: 10)
        label.textAlignment = .left
        label.text = CommonUsage.Text.followers
        return label
    }()
    
    private lazy var followingsNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scWhite)
        label.font = UIFont(name: CommonUsage.fontSemibold, size: 14)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var followingsTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scGray)
        label.font = UIFont(name: CommonUsage.fontSemibold, size: 10)
        label.textAlignment = .left
        label.text = CommonUsage.Text.followings
        return label
    }()
    
    private lazy var followersStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 1
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var followingsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 1
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var socialStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var followButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(named: CommonUsage.scWhite), for: .normal)
        button.setTitle(CommonUsage.Text.settings, for: .normal)

        //        btn.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        button.backgroundColor = UIColor(named: CommonUsage.scDarkYellow)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(named: CommonUsage.scLightGreen)?.cgColor
        button.layer.cornerRadius = 15
        
//        if displayOthersProfile {
//            button.setTitle(CommonUsage.Text.follow, for: .normal)
//        } else {
//            button.setTitle(CommonUsage.Text.settings, for: .normal)
//        }
        
        return button
    }()
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tellMyProfileOrOthers()
        fetchUserInfoFromFirebase()
        fetchDataFromFirebase()
        setBackgroundColor()
        setCoverImageView()
        setTableView()
        setUserImageView()
        setNameLabel()
        setSocialStackView()
        setFollowersStackView()
        setFollowingsStackView()
        setFollowButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchAmountOfFollows()
        fetchCurrentUserFollowingList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - config UI method
    
    private func setBackgroundColor() {
        view.backgroundColor = UIColor(named: CommonUsage.scBlue)
    }
    
    private func setCoverImageView() {
        view.addSubview(coverImageView)
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            coverImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            coverImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: CommonUsage.screenHeight / 4)
        ])
    }
    
    private func setTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: CommonUsage.screenHeight / 8),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setUserImageView() {
        view.addSubview(userImageView)
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userImageView.centerYAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: -CommonUsage.screenHeight / 16),
            userImageView.widthAnchor.constraint(equalToConstant: CommonUsage.screenHeight / 5),
            userImageView.heightAnchor.constraint(equalToConstant: CommonUsage.screenHeight / 5)
        ])
    }
    
    private func setNameLabel() {
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 4)
        ])
    }
    
    private func setSocialStackView() {
        view.addSubview(socialStackView)
        socialStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            socialStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            socialStackView.trailingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: -8),
            socialStackView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor)
        ])
        socialStackView.addArrangedSubview(followersStackView)
        socialStackView.addArrangedSubview(followingsStackView)
    }
    
    private func setFollowersStackView() {
        followersStackView.addArrangedSubview(followersNumberLabel)
        followersStackView.addArrangedSubview(followersTitleLabel)
    }
    
    private func setFollowingsStackView() {
        followingsStackView.addArrangedSubview(followingsNumberLabel)
        followingsStackView.addArrangedSubview(followingsTitleLabel)
    }
    
    private func setFollowButton() {
        view.addSubview(followButton)
        followButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            followButton.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 16),
            followButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            followButton.heightAnchor.constraint(equalTo: nameLabel.heightAnchor, multiplier: 0.75),
            followButton.widthAnchor.constraint(equalToConstant: 80)
        ])
        
    }
    
    // MARK: - method
    
//    private func tellMyProfileOrOthers() {
//        // 從sound detail page 推過來 才需要判斷是不是自己
//
//        guard let idWillDisplay = idWillDisplay,
//         let currentUserInfo =  signInManager.currentUserInfo else { return }
//
//        if idWillDisplay.userID == currentUserInfo.userID,
//           idWillDisplay.userIDProvider == currentUserInfo.provider {
//            return
//        } else {
//            //整套要換成這位user的 而且button 要顯示 follow
//            displayOthersProfile = true
//        }
//
//    }
    
    private func fetchCurrentUserFollowingList() {
        guard let currentUserInfoDocumentID = signInManager.currentUserInfo?.userInfoDoumentID else {
            print("OthersProfileController: please logIn")
            return }
        firebaseManager.checkFollowersChange(userInfoDoumentID: currentUserInfoDocumentID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let followers):
                
                self.currentUserFollowingList = followers
                
            case .failure(let error): print(error)
            }
        }
        
        
    }

    private func fetchUserFavoriteList() {
        
        guard let userProfileDocumentID = signInManager.currentUserInfo?.userInfoDoumentID else {
            print("AudioPlayerVC: Cant get favorite before login")
            return
        }
        firebaseManager.checkFavoriteChange(userProfileDocumentID: userProfileDocumentID) { [weak self]
            result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let scFavorites):
                self.currentUserFavoriteDocumentIDs = scFavorites.map({$0.favoriteDocumentID})
                
            case .failure(let error):
                print("AudioPlayerVC: Failed to get favoriteDocumentID \(error)")
                
            }
        }
    }
    
    private func fetchDataFromFirebase() {
        
        firebaseManager.checkPostsChange { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let posts):
                self.allAudioFiles = posts
                
            case.failure(let error):
                print(error)
            }
        }
    }
    
    private func fetchUserInfoFromFirebase() {
        signInManager.checkUser(completion: setUserProfile)
    }
    
    private func fetchAmountOfFollows() {
        guard let userWillDisplay = signInManager.currentUserInfo,
              let userInfoDoumentID = userWillDisplay.userInfoDoumentID else { return }
        firebaseManager.checkFollowersChange(userInfoDoumentID: userInfoDoumentID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let followers):
                
                self.numbersOfFollowers = followers.count
                
            case .failure(let error): print(error)
            }
        }
        
        firebaseManager.checkFollowingsChange(userInfoDoumentID: userInfoDoumentID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let followings):
                self.numbersOfFollowings = followings.count
            case .failure(let error): print(error)
            }
        }
    }

    
    private func setUserProfile() {
            coverImageView.image = UIImage(named: signInManager.profileCover)
            userImageView.image = UIImage(named: signInManager.userPic)
            nameLabel.text = signInManager.currentUserInfo?.username
//            followersNumberLabel.text = "2"
//            followingsNumberLabel.text = "4"
            fetchUserFavoriteList()
    }
}

// MARK: - conform to UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        ProfilePageSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.reuseIdentifier) as? HomeTableViewCell else { return UITableViewCell() }
        
        switch indexPath.section {
            
        case 0:
            guard let followings = currentUserFollowingList else {
                print("ProfilePage cant get followingList")
                return UITableViewCell()
            }
            
            var myFollowingsUserFiles = [SCPost]()
            for audioFile in allAudioFiles {
                for folloing in followings {
                    if audioFile.authorID == folloing.userID, audioFile.authIDProvider == folloing.provider {
                        myFollowingsUserFiles.append(audioFile)
                    }
                }
            }
            cell.firebaseData = myFollowingsUserFiles
            cell.profileSection = ProfilePageSection.allCases[indexPath.section]

            
        case 1:
            
            guard let currentUserFavoriteDocumentIDs = currentUserFavoriteDocumentIDs else {
                print("ProfilePage cant get currentUserFavoriteDocumentIDs")
                return UITableViewCell()
            }
            
            var myFavoriteFiles = [SCPost]()
            
            for audioFile in allAudioFiles {
                for favorite in currentUserFavoriteDocumentIDs {
                    if audioFile.documentID == favorite {
                        myFavoriteFiles.append(audioFile)
                    }
                }
            }
            cell.firebaseData = myFavoriteFiles
            cell.profileSection = ProfilePageSection.allCases[indexPath.section]
            
        case 2:
            let myAudioFiles = allAudioFiles.filter({$0.authorName == signInManager.currentUserInfo?.username})
            cell.firebaseData = myAudioFiles
            cell.profileSection = ProfilePageSection.allCases[indexPath.section]
            
        default:
            let filteredFiles = allAudioFiles.filter({$0.category == AudioCategory.allCases[indexPath.section].rawValue})
            cell.firebaseData = filteredFiles
            cell.category = AudioCategory.allCases[indexPath.item].rawValue
        }
        
        //        let filteredFiles = allAudioFiles.filter({$0.category == AudioCategory.allCases[indexPath.section].rawValue})
        cell.backgroundColor = .clear
        //        cell.firebaseData = filteredFiles
        //        cell.category = AudioCategory.allCases[indexPath.item].rawValue
        return cell
    }
    
}

// MARK: - conform to UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomeTableViewHeader.reuseIdentifier) as? HomeTableViewHeader else { return UIView()}
        
        headerView.delegate = self
        headerView.config(section: section, content: ProfilePageSection.allCases[section].rawValue)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        300
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
}

extension ProfileViewController: PressPassableDelegate {
    
    func goCategoryPage(from section: Int) {
        
        let category = AudioCategory.allCases[section]
        
        var data = [SCPost]()
        
        for file in allAudioFiles {
            
            if file.category == category.rawValue {
                data.append(file)
            }
        }
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let categoryPage = storyboard.instantiateViewController(withIdentifier: String(describing: CategoryViewController.self)) as? CategoryViewController else { return }
        
        categoryPage.config(category: category, data: data)
        navigationController?.pushViewController(categoryPage, animated: true)
        
    }
    
    func goCategoryPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let categoryPage = storyboard.instantiateViewController(withIdentifier: String(describing: CategoryViewController.self)) as? CategoryViewController else { return }
        
        navigationController?.pushViewController(categoryPage, animated: true)
    }
    
}

