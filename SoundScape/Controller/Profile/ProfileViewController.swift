//
//  ProfileViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/30.
//

import UIKit
import Photos

struct UserIdentity {
    let userID: String
    let userIDProvider: String
}

enum ProfilePageSection: String, CaseIterable {
    case followingsLatest = "Followings Latest"
    case myFavorite = "Favorite"
    case myAudio = "Audio"
}

enum PicType: String {
    case userPic
    case coverPic
}

class ProfileViewController: UIViewController {
    
    // MARK: - properties
    
    let signInManager = SignInManager.shared
    
    let firebaseManager = FirebaseManager.shared
    
    var selectedPicButton = PicType.coverPic
    
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
            guard let currentUserFollowingList = currentUserFollowingList else { return }
            followingsNumberLabel.text = String(describing: currentUserFollowingList.count)
            
        }
    }
    
    private var numbersOfFollowers: Int? {
        didSet {
            guard let numbersOfFollowers = numbersOfFollowers else { return }
            followersNumberLabel.text = String(describing: numbersOfFollowers)
        }
    }

    private var currentUserPic: String? {
        didSet {
            guard let currentUserPic = currentUserPic,
                  let data = Data(base64Encoded: currentUserPic) else { return }
            userImageView.image = UIImage(data: data)
        }
    }
    
    private var currentUserCover: String? {
        didSet {
            guard let currentUserCover = currentUserCover,
                  let data = Data(base64Encoded: currentUserCover) else { return }
            coverImageView.image = UIImage(data: data)
        }
    }

    // MARK: - UI properties
    
    private lazy var coverImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private lazy var userImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
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
        button.addTarget(self, action: #selector(goSettingPage), for: .touchUpInside)
        button.backgroundColor = UIColor(named: CommonUsage.scDarkYellow)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(named: CommonUsage.scLightGreen)?.cgColor
        button.layer.cornerRadius = 15
        return button
    }()
    
    private lazy var changeUserPicButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: CommonUsage.SFSymbol.photo), for: .normal)
        button.tintColor = UIColor(named: CommonUsage.scSuperLightBlue)
        button.addTarget(self, action: #selector(selectUserImage), for: .touchUpInside)
        return button
    }()
    
    private lazy var changeCoverPicButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: CommonUsage.SFSymbol.photo), for: .normal)
        button.tintColor = UIColor(named: CommonUsage.scSuperLightBlue)
        button.addTarget(self, action: #selector(selectCoverImage), for: .touchUpInside)
        return button
    }()
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObserver()
        fetchDataFromFirebase()
        setUserProfile()
        setBackgroundColor()
        setCoverImageView()
        setTableView()
        setUserImageView()
        setNameLabel()
        setSocialStackView()
        setFollowersStackView()
        setFollowingsStackView()
        setFollowButton()
        setImageHintOnUserPic()
        setImageHintOnUCoverPic()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    private func setImageHintOnUserPic() {
        view.addSubview(changeUserPicButton)
        changeUserPicButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            changeUserPicButton.trailingAnchor.constraint(equalTo: userImageView.trailingAnchor),
            changeUserPicButton.bottomAnchor.constraint(equalTo: userImageView.bottomAnchor),
            changeUserPicButton.heightAnchor.constraint(equalToConstant: 40),
            changeUserPicButton.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setImageHintOnUCoverPic() {
        view.addSubview(changeCoverPicButton)
        changeCoverPicButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            changeCoverPicButton.trailingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: -32),
            changeCoverPicButton.bottomAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: -32),
            changeCoverPicButton.heightAnchor.constraint(equalToConstant: 40),
            changeCoverPicButton.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - method
    
    private func addObserver() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(currentFavDocIDChange),
                                               name: .currentUserFavDocIDChange ,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(currentFollowersChange),
                                               name: .currentUserFollowersChange ,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(currentFollowingsChange),
                                               name: .currentUserFollowingsChange ,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(currentUserPicChange),
                                               name: .currentUserPicChange ,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(currentUserCoverChange),
                                               name: .currentUserCoverChange ,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateAllAudioFile),
                                               name: .allAudioPostChange ,
                                               object: nil)
    }
    
    @objc func updateAllAudioFile() {
        fetchDataFromFirebase()
    }
    
    private func fetchFollowerList() {
        numbersOfFollowers = signInManager.currentUserFollowerList?.count
    }
    
    private func fetchFollowingList() {
        currentUserFollowingList = signInManager.currentUserFollowingList
    }
    
    private func fetchUserFavoriteList() {
        currentUserFavoriteDocumentIDs = signInManager.currentUserFavoriteDocumentIDs
    }
    
    private func fetchCurrentUserPic() {
        currentUserPic = signInManager.currentUserPic
    }
    
    private func fetchCurrentCoverPic() {
        currentUserCover = signInManager.currentUserCover
    }
    
    private func fetchDataFromFirebase() {
        allAudioFiles = AudioPostManager.shared.filteredAudioFiles
    }
    
    private func setUserProfile() {
        coverImageView.image = UIImage(named: CommonUsage.profileCover4)
        userImageView.image = UIImage(named: CommonUsage.yeh1024)
        nameLabel.text = signInManager.currentUserInfoFirebase?.username
        fetchUserFavoriteList()
        fetchFollowerList()
        fetchFollowingList()
        fetchCurrentUserPic()
        fetchCurrentCoverPic()
    }
    
    // MARK: - image method
    
    private func pressSelectImage() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        
        picker.sourceType = .photoLibrary
        
        picker.allowsEditing = true

        present(picker, animated: true)
        
    }
    
    private func sendPhoto(_ image: UIImage) {
        
        guard let userDocumentID = signInManager.currentUserInfoFirebase?.userInfoDoumentID,
              let  compressedImage = image.jpegData(compressionQuality: 0.15) else { return }
        let imageBase64String = compressedImage.base64EncodedString()
        
        firebaseManager.uploadPicToFirebase(userDocumentID: userDocumentID,
                                            picString: imageBase64String,
                                            picType: selectedPicButton)
    }
    
    // MARK: - action
    
    @objc func goSettingPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let settingViewController = storyboard.instantiateViewController(withIdentifier: String(describing: SettingViewController.self)) as? SettingViewController else { return }
        navigationController?.pushViewController(settingViewController, animated: true)
    }
    
    @objc func currentFavDocIDChange() {
        fetchUserFavoriteList()
    }
    
    @objc func currentFollowersChange() {
        fetchFollowerList()
    }
    
    @objc func currentFollowingsChange() {
        fetchFollowingList()
    }
    
    @objc func currentUserPicChange() {
        fetchCurrentUserPic()
    }
    
    @objc func currentUserCoverChange() {
        fetchCurrentCoverPic()
    }
    
    @objc func selectUserImage() {
        pressSelectImage()
        selectedPicButton = .userPic
    }
    
    @objc func selectCoverImage() {
        pressSelectImage()
        selectedPicButton = .coverPic
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
            let myAudioFiles = allAudioFiles.filter({$0.authorName == signInManager.currentUserInfoFirebase?.username})
            cell.firebaseData = myAudioFiles
            cell.profileSection = ProfilePageSection.allCases[indexPath.section]
            
        default:
            let filteredFiles = allAudioFiles.filter({$0.category == AudioCategory.allCases[indexPath.section].rawValue})
            cell.firebaseData = filteredFiles
            cell.category = AudioCategory.allCases[indexPath.item].rawValue
        }
        
        cell.backgroundColor = .clear
        return cell
    }
    
}

// MARK: - conform to UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomeTableViewHeader.reuseIdentifier) as? HomeTableViewHeader else { return UIView()}
        
        headerView.delegate = self
        headerView.presentInPage = .profileSection
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
    
    func goSectionPage(from section: Int, sectionPageType: SectionPageType) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let categoryPage = storyboard.instantiateViewController(withIdentifier: String(describing: CategoryViewController.self)) as? CategoryViewController else { return }
        
        switch section {
            
        case 0:
            guard let followings = currentUserFollowingList else {
                print("ProfilePage cant get followingList")
                return
            }
            
            var myFollowingsUserFiles = [SCPost]()
            for audioFile in allAudioFiles {
                for folloing in followings {
                    if audioFile.authorID == folloing.userID, audioFile.authIDProvider == folloing.provider {
                        myFollowingsUserFiles.append(audioFile)
                    }
                }
            }
            
            let section = ProfilePageSection.allCases[section]
            categoryPage.config(profileSection: section, data: myFollowingsUserFiles)
            
        case 1:
            
            guard let currentUserFavoriteDocumentIDs = currentUserFavoriteDocumentIDs else {
                print("ProfilePage cant get currentUserFavoriteDocumentIDs")
                return
            }
            
            var myFavoriteFiles = [SCPost]()
            
            for audioFile in allAudioFiles {
                for favorite in currentUserFavoriteDocumentIDs {
                    if audioFile.documentID == favorite {
                        myFavoriteFiles.append(audioFile)
                    }
                }
            }
            let section = ProfilePageSection.allCases[section]
            categoryPage.config(profileSection: section, data: myFavoriteFiles)
            
        case 2:
            let myAudioFiles = allAudioFiles.filter({$0.authorName == signInManager.currentUserInfoFirebase?.username})
            let section = ProfilePageSection.allCases[section]
            categoryPage.config(profileSection: section, data: myAudioFiles)
            
        default:
            break
        }
        
        navigationController?.pushViewController(categoryPage, animated: true)
    }
    
}

// MARK: - conform to UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension ProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        picker.dismiss(animated: true)
        
        // 1
        if let asset = info[.phAsset] as? PHAsset {
            let size = CGSize(width: 500, height: 500)
            PHImageManager.default().requestImage(
                for: asset,
                   targetSize: size,
                   contentMode: .aspectFit,
                   options: nil
            ) { result, _ in
                guard let image = result else {
                    return
                }
                self.sendPhoto(image)
            }
            
            // 2
        } else if let image = info[.originalImage] as? UIImage {
            sendPhoto(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}

// MARK: - UIImage extension

extension UIImage {
    var scaledToSafeUploadSize: UIImage? {
        let maxImageSideLength: CGFloat = 480
        
        let largerSide: CGFloat = max(size.width, size.height)
        let ratioScale: CGFloat = largerSide > maxImageSideLength ? largerSide / maxImageSideLength : 1
        let newImageSize = CGSize(
            width: size.width / ratioScale,
            height: size.height / ratioScale)
        
        return image(scaledTo: newImageSize)
    }
    
    func image(scaledTo size: CGSize) -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        draw(in: CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

