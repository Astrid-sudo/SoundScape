//
//  ProfileViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/30.
//

// swiftlint:disable file_length

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
        }
    }
    
    private var numbersOfFollowers: Int? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var currentUserPic: String? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var currentUserCover: String? {
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
        table.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.reuseIdentifier)
        return table
    }()
    
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
    
    // MARK: - deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - config UI method
    
    private func setBackgroundColor() {
        view.backgroundColor = UIColor(named: CommonUsage.scBlue)
    }
    
    private func setNavigationBar() {
        navigationItem.title = CommonUsage.Text.myProfile
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
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
        FirebaseManager.shared.deletePostInAllAudio(documentID: documentID) { [weak self] errorMessage in
            guard let self = self else { return }
            self.popErrorAlert(title: "Failed to delete post", message: errorMessage)
        }
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

// MARK: - conform to UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        ProfilePageSection.allCases.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.reuseIdentifier) as? HomeTableViewCell,
              let profileDataCell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.reuseIdentifier) as? ProfileTableViewCell,
              let logginUser = signInManager.currentUserInfoFirebase else { return UITableViewCell() }
        
        cell.backgroundColor = UIColor(named: CommonUsage.scBlue)
        cell.delegate = self
        profileDataCell.backgroundColor = UIColor(named: CommonUsage.scBlue)
        
        switch indexPath.section {
            
        case 0:
            profileDataCell.delegate = self
            profileDataCell.configMyProfilecell(userData: logginUser,
                                                followers: numbersOfFollowers,
                                                followings: currentUserFollowingList?.count ,
                                                userPic: currentUserPic,
                                                coverPic: currentUserCover)
            return profileDataCell
            
        case 1:
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
            cell.profileSection = ProfilePageSection.allCases[indexPath.section - 1]
            return cell
            
        case 2:
            
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
            cell.profileSection = ProfilePageSection.allCases[indexPath.section - 1]
            return cell
            
        case 3:
            
            let myAudioFiles = allAudioFiles.filter({$0.authorName == signInManager.currentUserInfoFirebase?.username})
            cell.firebaseData = myAudioFiles
            cell.profileSection = ProfilePageSection.allCases[indexPath.section - 1]
            return cell
            
        default:
            
            let filteredFiles = allAudioFiles.filter({$0.category == AudioCategory.allCases[indexPath.section - 1].rawValue})
            cell.firebaseData = filteredFiles
            cell.category = AudioCategory.allCases[indexPath.item].rawValue
            return cell
        }
    }
    
}

// MARK: - conform to UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            return nil
        
        } else {
           
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomeTableViewHeader.reuseIdentifier) as? HomeTableViewHeader else { return UIView()}
            
            headerView.delegate = self
            headerView.presentInPage = .profileSection
            headerView.config(section: section, content: ProfilePageSection.allCases[section - 1].rawValue)
            return headerView
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        300
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath == IndexPath(row: 0, section: 3) {
            
            return 230
            
        } else if indexPath == IndexPath(row: 0, section: 0) {
            
            return 250
            
        } else {
            
            return 168
            
        }
    }
    
}

// MARK: - conform to ProfileViewController

extension ProfileViewController: PressPassableDelegate {
    
    func goSectionPage(from section: Int, sectionPageType: SectionPageType) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let categoryPage = storyboard.instantiateViewController(withIdentifier: String(describing: CategoryViewController.self)) as? CategoryViewController else { return }
        
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
    
    func manipulateFollow() {
    }
    
    func goSettingPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let settingViewController = storyboard.instantiateViewController(withIdentifier: String(describing: SettingViewController.self)) as? SettingViewController else { return }
        navigationController?.pushViewController(settingViewController, animated: true)
    }
    
}

// MARK: - conform to AlertPresentableDelegate

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


// swiftlint:enable file_length
