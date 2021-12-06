//
//  OthersProfileViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/31.
//

import UIKit
import Photos

enum ProfilePageType {
    case otherUser
    case loggInUser
}

class OthersProfileViewController: UIViewController {
    
    // MARK: - properties
    
    var profilePageType = ProfilePageType.otherUser {
        didSet {
            setNavigationBar()
            setTableView()
        }
    }
    
    let signInManager = LoggedInUserManager.shared
    
    var idWillDisplay: UserIdentity?
    
    var userWillDisplay: SCUser? {
        didSet {
            checkDisplayUser()
            fetchUserFavoriteList()
            fetchAmountOfFollows()
            fetchUserPicFromFirebase()
            fetchUserCoverFromFirebase()
            checkUserPicFromFirebase()
            checkUserCoverFromFirebase()
        }
    }
    
    let firebaseManager = FirebaseManager.shared
    
    var allAudioFiles = [SCPost]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var userFavoriteDocumentIDs: [String]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var numbersOfFollowers: Int? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var numbersOfFollowings: Int? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var othersFollowingList: [SCFollow]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var otherUserPic: String? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var otherUserCover: String? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var selectedPicButton = PicType.coverPic
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
        fetchUserInfo()
        fetchDataFromFirebase()
        setBackgroundColor()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Action
    
    @objc func backToLastPage() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - method
    
    private func checkDisplayUser() {
        guard let userWillDisplay = userWillDisplay,
              let logginUser = signInManager.currentUserInfoFirebase else {
                  return
              }
        
        if userWillDisplay.userID == logginUser.userID {
            profilePageType = .loggInUser
        } else {
            profilePageType = .otherUser
        }
        
    }
    
    private func addObserver() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateAllAudioFile),
                                               name: .allAudioPostChange ,
                                               object: nil)
        
    }
    
    func makeButtonFollowed() {
        // swiftlint:disable line_length
        guard let profileCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileTableViewCell else { return }
        profileCell.makeButtonFollowed()
    }
    
    func makeButtonUnFollow() {
        guard let profileCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileTableViewCell else { return }
        profileCell.makeButtonUnFollow()
    }
    
    private func fetchAmountOfFollows() {
        guard let userWillDisplay = userWillDisplay,
              let userInfoDoumentID = userWillDisplay.userInfoDoumentID else { return }
        checkFollowersChange(userInfoDoumentID: userInfoDoumentID)
        checkFollowingsChange(userInfoDoumentID: userInfoDoumentID)
    }
    
    private func checkFollowersChange(userInfoDoumentID: String) {
        _ = firebaseManager.collectionAddListener(collectionType: .followedBy(userInfoDocumentID: userInfoDoumentID)) { (result: Result<[SCFollow], Error>) in
            switch result {
            case .success(let followers):
                self.numbersOfFollowers = followers.count
            case .failure(let error): print(error)
            }
        }
    }
    
    private func checkFollowingsChange(userInfoDoumentID: String) {
        _ = firebaseManager.collectionAddListener(collectionType: .following(userInfoDocumentID: userInfoDoumentID)) { (result: Result<[SCFollow], Error>) in
            switch result {
            case .success(let followings):
                self.numbersOfFollowings = followings.count
                self.othersFollowingList = followings
            case .failure(let error): print(error)
            }
        }
    }
    
    private func fetchUserInfo() {
        
        guard let userID = idWillDisplay?.userID,
              let userIDProider = idWillDisplay?.userIDProvider else {
                  print("OtherProfileVC: Dont know who to display")
                  return
              }
        
        firebaseManager.fetchUser(userID: userID,
                                  userIDProvider: userIDProider) { result in
            
            switch result {
                
            case .success(let user):
                self.userWillDisplay = user
                
            case.failure(let error):
                print(error)
            }
        }
    }
    
    private func fetchUserFavoriteList() {
        
        guard let userProfileDocumentID = userWillDisplay?.userInfoDoumentID else {
            print("OtherProfileVC: Cant get favorite")
            return
        }
        
        _ = firebaseManager.collectionAddListener(collectionType: .myFavorite(userInfoDocumentID: userProfileDocumentID)) { (result: Result<[SCFavorite], Error>) in
            switch result {
                
            case .success(let scFavorites):
                self.userFavoriteDocumentIDs = scFavorites.map({$0.favoriteDocumentID})
                
            case .failure(let error):
                print("OtherProfileVC: Failed to get favoriteDocumentID \(error)")
                
            }
        }
    }
    
    @objc func updateAllAudioFile() {
        fetchDataFromFirebase()
    }
    
    private func fetchDataFromFirebase() {
        allAudioFiles = AudioPostManager.shared.filteredAudioFiles
    }
    
    // swiftlint:disable line_length
    private func fetchUserPicFromFirebase() {
        guard let userID = userWillDisplay?.userInfoDoumentID else { return }
        firebaseManager.documentFetchData(documentType:
                                                .userPicDoc(userInfoDocumentID:
                                                                userID)) { (result:
                                                                                Result<SCPicture, Error>) in
            switch result {
            case .success(let picture):
                self.otherUserPic = picture.picture
            case .failure(let error):
                print(error)
            }
        }
    }
    // swiftlint:enable line_length
    
    private func checkUserPicFromFirebase() {
        guard let userID = userWillDisplay?.userInfoDoumentID else { return }
        // swiftlint:disable line_length
        _ = firebaseManager.documentAddListener(documentType: .userPicDoc(userInfoDocumentID: userID)) { (result: Result<SCPicture, Error>) in
            switch result {
            case .success(let picture):
                self.otherUserPic = picture.picture
            case .failure(let error):
                print(error)
            }
        }
    }
    // swiftlint:enable line_length
    
    private func fetchUserCoverFromFirebase() {
        guard let userID = userWillDisplay?.userInfoDoumentID else { return }
        firebaseManager
            .documentFetchData(documentType: .userCoverDoc(userInfoDocumentID: userID)) { (result: Result<SCPicture, Error>) in
                switch result {
                case .success(let picture):
                    self.otherUserCover = picture.picture
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    private func checkUserCoverFromFirebase() {
        guard let userID = userWillDisplay?.userInfoDoumentID else { return }
        _ = firebaseManager.documentAddListener(documentType: .userCoverDoc(userInfoDocumentID: userID)) { (result: Result<SCPicture, Error>) in
            switch result {
            case .success(let picture):
                self.otherUserCover = picture.picture
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func popBlockAlert() {
        
        let alert = UIAlertController(title: "Are you sure?",
                                      message: "You can't see this user's comments, audio posts and profile page after blocking. And you have no chance to unblock this user in the future",
                                      preferredStyle: .alert )
        
        let okButton = UIAlertAction(title: "Block", style: .destructive) {[weak self] _ in
            guard let self = self else { return }
            self.blockUser()
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(cancelButton)
        alert.addAction(okButton)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    private func backToHome() {
        navigationController?.popToRootViewController(animated: true)
        // swiftlint:disable line_length
        guard let scTabBarController = UIApplication.shared.windows.filter({$0.rootViewController is SCTabBarController}).first?.rootViewController as? SCTabBarController else { return }
        scTabBarController.selectedIndex = 0
        // swiftlint:enable line_length
    }
    
    private func blockUser() {
        
        guard let currentUserDocID = signInManager.currentUserInfoFirebase?.userInfoDoumentID,
              let  blockUser = userWillDisplay else { return }
        
        firebaseManager.addToBlackList(loggedInUserInfoDocumentID: currentUserDocID,
                                       toBeBlockedID: blockUser.userID, completion: backToHome)
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
    
    private func loadAudio(localURL: URL, playInfo: PlayInfo) {
        AudioPlayHelper.shared.url = localURL
        AudioPlayHelper.shared.setPlayInfo(playInfo: playInfo)
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
    
    func pressSelectImage(selectedPicButton: PicType) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        
        picker.sourceType = .photoLibrary
        
        picker.allowsEditing = true
        
        present(picker, animated: true)
        
        self.selectedPicButton = selectedPicButton
        
    }
    
    func sendPhoto(_ image: UIImage) {
        guard let userDocumentID = signInManager.currentUserInfoFirebase?.userInfoDoumentID,
              let  compressedImage = image.jpegData(compressionQuality: 0.15) else { return }
        let imageBase64String = compressedImage.base64EncodedString()
        
        firebaseManager.uploadPicToFirebase(userDocumentID: userDocumentID,
                                            picString: imageBase64String,
                                            picType: selectedPicButton) { [weak self] errorMessage in
            guard let self = self else { return }
            self.popErrorAlert(title: "Failed to uplaod picture", message: errorMessage)
        } succeededCompletion: {
            SPAlertWrapper.shared.presentSPAlert(title: "Photo added!", message: nil, preset: .heart, completion: nil)
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
        table.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.reuseIdentifier)
        table.register(HomeTableViewHeader.self, forHeaderFooterViewReuseIdentifier: HomeTableViewHeader.reuseIdentifier)
        return table
    }()
    
    let loadingAnimationView = LottieWrapper.shared.createLottieAnimationView(lottieType: .greyStripeLoading,
                                                                              frame: CGRect(x: 0,
                                                                                            y: 0,
                                                                                            width: UIProperties.screenWidth,
                                                                                            height: UIProperties.screenHeight))
}
// swiftlint:enable line_length


// MARK: - conform to ProfileCellDelegate

extension OthersProfileViewController: ProfileCellDelegate {
    
    func blockThisUser() {
        popBlockAlert()
    }
    
    func toggleFollow() {
        guard let userWillDisplay = userWillDisplay,
              let userInfoDoumentID = userWillDisplay.userInfoDoumentID,
              let loggedInUserInfo = signInManager.currentUserInfoFirebase,
              let loggedInUserInfoDocumentID = loggedInUserInfo.userInfoDoumentID else { return }
        
        firebaseManager.manipulateFollow(userInfoDoumentID: userInfoDoumentID,
                                         userInfo: SCFollow(userID: userWillDisplay.userID,
                                                            provider: userWillDisplay.provider),
                                         loggedInUserInfoDocumentID: loggedInUserInfoDocumentID,
                                         loggedInUserInfo: SCFollow(userID: loggedInUserInfo.userID,
                                                                    provider: loggedInUserInfo.provider),
                                         followCompletion: makeButtonFollowed,
                                         unfollowCompletion: makeButtonUnFollow) { [weak self] errorMessage in
            guard let self = self else { return }
            self.popErrorAlert(title: "Failed to add or remove follow", message: errorMessage)
        }
    }
    
    func goSettingPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // swiftlint:disable line_length
        guard let settingViewController = storyboard.instantiateViewController(withIdentifier: SettingViewController.reuseIdentifier) as? SettingViewController else { return }
        // swiftlint:enable line_length
        navigationController?.pushViewController(settingViewController, animated: true)
    }
    
}

extension OthersProfileViewController: AlertPresentableDelegate {
    
    func popBlockAlert(toBeBlockedID: String) {
        // swiftlint:disable line_length
        let alert = UIAlertController(title: "Are you sure?",
                                      message: "You can't see this user's comments, audio posts and profile page after blocking. And you have no chance to unblock this user in the future",
                                      preferredStyle: .alert )
        // swiftlint:enable line_length
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
