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
    case followingsLatest = "Followings"
    case myFavorite = "Favorite"
    case myAudio = "Audio"
}

enum PicType: String {
    case userPic
    case coverPic
}

class ProfileViewController: UIViewController {
    
    // MARK: - properties
    
    let signInManager = LoggedInUserManager.shared
    
    let firebaseManager = FirebaseManager.shared
    
    var selectedPicButton = PicType.coverPic
    
    var allAudioFiles = [SCPost]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var currentUserFavoriteDocumentIDs: [String]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var currentUserFollowingList: [SCFollow]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var numbersOfFollowers: Int? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var currentUserPic: String? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var currentUserCover: String? {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - UI properties
    
    // swiftlint:disable line_length
    let loadingAnimationView = LottieWrapper.shared.createLottieAnimationView(lottieType: .greyStripeLoading,
                                                                              frame: CGRect(x: 0,
                                                                                            y: 0,
                                                                                            width: UIProperties.screenWidth,
                                                                                            height: UIProperties.screenHeight))
    
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
        table.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.reuseIdentifier)
        table.register(ProfileBlankTableViewCell.self, forCellReuseIdentifier: ProfileBlankTableViewCell.reuseIdentifier)
        return table
    }()
    // swiftlint:enable line_length
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        addObserver()
        fetchDataFromFirebase()
        setUserProfile()
        setBackgroundColor()
        setTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(failedFetchUserProfilePic),
                                               name: .failedFetchUserProfilePic ,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(failedFetchUserCoverPic),
                                               name: .failedFetchUserCoverPic ,
                                               object: nil)
    }
    
    @objc func updateAllAudioFile() {
        fetchDataFromFirebase()
    }
    
    @objc func failedFetchUserProfilePic(notification: Notification) {
        guard let error = notification.userInfo?["UserInfo"] as? String else { return }
        popErrorAlert(title: "Failed to fetch user profile pic", message: error)
    }
    
    @objc func failedFetchUserCoverPic(notification: Notification) {
        guard let error = notification.userInfo?["UserInfo"] as? String else { return }
        popErrorAlert(title: "Failed to fetch user cover pic", message: error)
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
        fetchUserFavoriteList()
        fetchFollowerList()
        fetchFollowingList()
        fetchCurrentUserPic()
        fetchCurrentCoverPic()
    }
    
    private func blockThisUser(toBeBlockedID: String) {
        guard let currentUserDocID = signInManager.currentUserInfoFirebase?.userInfoDoumentID else { return }
        firebaseManager.addToBlackList(loggedInUserInfoDocumentID: currentUserDocID,
                                       toBeBlockedID: toBeBlockedID, completion: nil)
    }
    
    func deletePost(documentID: String) {
        view.addSubview(loadingAnimationView)
        loadingAnimationView.play()
        
        FirebaseManager.shared.deletePostInAllAudio(documentID: documentID) { [weak self] errorMessage in
            guard let self = self else { return }
            self.loadingAnimationView.stop()
            self.loadingAnimationView.removeFromSuperview()
            self.popErrorAlert(title: "Failed to delete post", message: errorMessage)
        } succeededCompletion: {
            self.loadingAnimationView.stop()
            self.loadingAnimationView.removeFromSuperview()
            SPAlertWrapper.shared.presentSPAlert(title: "Post deleted!", message: nil, preset: .done, completion: nil)}
    }
    
    func setTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
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
                                            picType: selectedPicButton) { [weak self] errorMessage in
            guard let self = self else { return }
            self.popErrorAlert(title: "Failed to uplaod picyure", message: errorMessage)
        } succeededCompletion: {
            SPAlertWrapper.shared.presentSPAlert(title: "Photo added!", message: nil, preset: .heart, completion: nil)
        }
        
    }
    
    // MARK: - action
    
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

// MARK: - conform to ProfileViewController

extension ProfileViewController: PressPassableDelegate {
    
    func goSectionPage(from section: Int, sectionPageType: SectionPageType) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // swiftlint:disable line_length
        guard let categoryPage = storyboard.instantiateViewController(withIdentifier: String(describing: CategoryViewController.self)) as? CategoryViewController else { return }
        // swiftlint:enable line_length
        switch section {
            
        case 1:
            
            let section = ProfilePageSection.allCases[section - 1]
            categoryPage.config(profileSection: section)
            
        case 2:
            
            let section = ProfilePageSection.allCases[section - 1]
            categoryPage.config(profileSection: section)
            
        case 3:
            
            let section = ProfilePageSection.allCases[section - 1]
            categoryPage.config(profileSection: section)
            
        default:
            break
        }
        
        navigationController?.pushViewController(categoryPage, animated: true)
    }
    
}

// MARK: - conform to UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension ProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        picker.dismiss(animated: true)
        
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
            
        } else if let image = info[.originalImage] as? UIImage {
            sendPhoto(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}

// MARK: - conform to ProfileCellDelegate

extension ProfileViewController: ProfileCellDelegate {
    
    func pressSelectImage(selectedPicButton: PicType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        picker.sourceType = .photoLibrary
        
        picker.allowsEditing = true
        
        present(picker, animated: true)
        
        self.selectedPicButton = selectedPicButton
        
    }
    
    func blockThisUser() {
    }
    
    func toggleFollow() {
    }
    
    func goSettingPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let settingViewController = storyboard.instantiateViewController(withIdentifier: SettingViewController.reuseIdentifier) as? SettingViewController else { return }
        navigationController?.pushViewController(settingViewController, animated: true)
    }
    
}

// MARK: - AlertPresentableDelegate

extension ProfileViewController: AlertPresentableDelegate {
    
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
