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
    
    let signInManager = SignInManager.shared
    
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
    
    private var allAudioFiles = [SCPost]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var userFavoriteDocumentIDs: [String]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var numbersOfFollowers: Int? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var numbersOfFollowings: Int? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var othersFollowingList: [SCFollow]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var otherUserPic: String? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var otherUserCover: String? {
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
    
    deinit {
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
    
    private func makeButtonFollowed() {
        
        guard let profileCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileTableViewCell else { return }
        profileCell.makeButtonFollowed()
    }
    
    private func makeButtonUnFollow() {
        guard let profileCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileTableViewCell else { return }
        profileCell.makeButtonUnFollow()
    }
    
    private func fetchAmountOfFollows() {
        guard let userWillDisplay = userWillDisplay,
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
    
    @objc func updateAllAudioFile() {
        fetchDataFromFirebase()
    }
    
    private func fetchDataFromFirebase() {
        allAudioFiles = AudioPostManager.shared.filteredAudioFiles
    }
    
    private func fetchUserPicFromFirebase() {
        guard let userID = userWillDisplay?.userInfoDoumentID else { return }
        firebaseManager.fetchUserPicFromFirebase(userID: userID) { result in
            switch result {
            case .success(let picture):
                self.otherUserPic = picture.picture
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func checkUserPicFromFirebase() {
        guard let userID = userWillDisplay?.userInfoDoumentID else { return }
        firebaseManager.checkUserPicChange(userInfoDoumentID: userID) { result in
            switch result {
            case .success(let picture):
                self.otherUserPic = picture.picture
            case .failure(let error):
                print(error)
            }
        }
    }

    
    private func fetchUserCoverFromFirebase() {
        guard let userID = userWillDisplay?.userInfoDoumentID else { return }
        firebaseManager.fetchCoverPicFromFirebase(userID: userID) { result in
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
        firebaseManager.checkCoverPicChange(userInfoDoumentID: userID) { result in
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
                                      message: "You can't see this user's comments, audio posts and profile page after blocking.",
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
        guard let scTabBarController = UIApplication.shared.windows.filter({$0.rootViewController is SCTabBarController}).first?.rootViewController as? SCTabBarController else { return }
        scTabBarController.selectedIndex = 0
    }
    
    private func blockUser() {
        
        guard let currentUserDocID = signInManager.currentUserInfoFirebase?.userInfoDoumentID,
              let  blockUser = userWillDisplay else { return }
        
        firebaseManager.addToBlackList(loggedInUserInfoDocumentID: currentUserDocID,
                                       toBeBlockedID: blockUser.userID, completion: backToHome)
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
    
    private func sendPhoto(_ image: UIImage) {
        
        guard let userDocumentID = signInManager.currentUserInfoFirebase?.userInfoDoumentID,
              let  compressedImage = image.jpegData(compressionQuality: 0.15) else { return }
        let imageBase64String = compressedImage.base64EncodedString()
        
        firebaseManager.uploadPicToFirebase(userDocumentID: userDocumentID,
                                            picString: imageBase64String,
                                            picType: selectedPicButton)
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
    
    // MARK: - config UI method
    
    private func setBackgroundColor() {
        view.backgroundColor = UIColor(named: CommonUsage.scBlue)
    }
    
    private func setNavigationBar() {
        guard let userWillDisplay = userWillDisplay else { return }
        navigationController?.isNavigationBarHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: self,action: #selector(backToLastPage))
        navigationItem.leftBarButtonItem?.image = UIImage(systemName: CommonUsage.SFSymbol.back)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: CommonUsage.scWhite)
        

        switch profilePageType {
        case .otherUser:
            navigationItem.title = userWillDisplay.username

        case .loggInUser:
            navigationItem.title = CommonUsage.Text.myProfile

        }
        
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
    
}

// MARK: - conform to UITableViewDataSource

extension OthersProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        ProfilePageSection.allCases.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.reuseIdentifier) as? HomeTableViewCell,
              let profileDataCell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.reuseIdentifier) as? ProfileTableViewCell,
              let userWillDisplay = userWillDisplay else { return UITableViewCell() }
        
        cell.backgroundColor = UIColor(named: CommonUsage.scBlue)
        profileDataCell.backgroundColor = UIColor(named: CommonUsage.scBlue)
        
        switch indexPath.section {
            
        case 0:
            profileDataCell.delegate = self

            
            switch profilePageType {
            case .loggInUser:
                
                profileDataCell.configMyProfilecell(userData: userWillDisplay, followers: numbersOfFollowers, followings: numbersOfFollowings, userPic: otherUserPic, coverPic: otherUserCover)
                
            case.otherUser:
                
                profileDataCell.configcell(userData: userWillDisplay, followers: numbersOfFollowers, followings: numbersOfFollowings, userPic: otherUserPic, coverPic: otherUserCover)
                
                if let currentUserFollowingsID = signInManager.currentUserFollowingList?.map({$0.userID}) {
                    if currentUserFollowingsID.contains(userWillDisplay.userID) {
                        profileDataCell.makeButtonFollowed()
                    }
                }
                
            }
            
            return profileDataCell
            
        case 1:
            guard let followings = othersFollowingList else {
                print("OtherProfilePage cant get othersFollowingList")
                return UITableViewCell()
            }
            
            var myFollowingsUserFiles = [SCPost]()
            for audioFile in allAudioFiles {
                for folloing in followings {
                    if audioFile.authorID == folloing.userID,
                       audioFile.authIDProvider == folloing.provider {
                        myFollowingsUserFiles.append(audioFile)
                    }
                }
            }
            cell.firebaseData = myFollowingsUserFiles
            cell.profileSection = ProfilePageSection.allCases[indexPath.section - 1]
            return cell
            
            
        case 2:
            
            guard let userFavoriteDocumentIDs = userFavoriteDocumentIDs else {
                print("ProfilePage cant get userFavoriteDocumentIDs")
                return UITableViewCell()
            }
            
            var myFavoriteFiles = [SCPost]()
            
            for audioFile in allAudioFiles {
                for favorite in userFavoriteDocumentIDs {
                    if audioFile.documentID == favorite {
                        myFavoriteFiles.append(audioFile)
                    }
                }
            }
            cell.firebaseData = myFavoriteFiles
            cell.profileSection = ProfilePageSection.allCases[indexPath.section - 1]
            return cell
            
        case 3:
            let myAudioFiles = allAudioFiles.filter({$0.authorName == userWillDisplay.username})
            cell.firebaseData = myAudioFiles
            cell.profileSection = ProfilePageSection.allCases[indexPath.section - 1]
            return cell
            
        default:
            let filteredFiles = allAudioFiles.filter({$0.category == AudioCategory.allCases[indexPath.section].rawValue})
            cell.firebaseData = filteredFiles
            cell.category = AudioCategory.allCases[indexPath.item].rawValue
            return cell
            
        }
    }
    
}

// MARK: - conform to UITableViewDelegate

extension OthersProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            return nil
        } else {
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomeTableViewHeader.reuseIdentifier) as? HomeTableViewHeader else { return UIView()}
            headerView.presentInPage = .profileSection
            headerView.delegate = self
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

// MARK: - conform to PressPassableDelegate

extension OthersProfileViewController: PressPassableDelegate {
    
    func goSectionPage(from section: Int, sectionPageType: SectionPageType) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let categoryPage = storyboard.instantiateViewController(withIdentifier: String(describing: CategoryViewController.self)) as? CategoryViewController else { return }
        
        switch section {
            
        case 1:
            guard let followings = othersFollowingList else {
                print("OtherProfilePage cant get othersFollowingList")
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
            let section = ProfilePageSection.allCases[section - 1]
            categoryPage.config(profileSection: section, data: myFollowingsUserFiles)
            
        case 2:
            
            guard let userFavoriteDocumentIDs = userFavoriteDocumentIDs else {
                print("ProfilePage cant get userFavoriteDocumentIDs")
                return
            }
            
            var myFavoriteFiles = [SCPost]()
            
            for audioFile in allAudioFiles {
                for favorite in userFavoriteDocumentIDs {
                    if audioFile.documentID == favorite {
                        myFavoriteFiles.append(audioFile)
                    }
                }
            }
            let section = ProfilePageSection.allCases[section - 1]
            categoryPage.config(profileSection: section, data: myFavoriteFiles)
            
        case 3:
            guard let userWillDisplay = userWillDisplay else { break }
            
            let myAudioFiles = allAudioFiles.filter({$0.authorName == userWillDisplay.username})
            let section = ProfilePageSection.allCases[section - 1]
            categoryPage.config(profileSection: section, data: myAudioFiles)
            
        default:
            break
        }
        
        navigationController?.pushViewController(categoryPage, animated: true)
    }
    
    func goCategoryPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let categoryPage = storyboard.instantiateViewController(withIdentifier: String(describing: CategoryViewController.self)) as? CategoryViewController else { return }
        
        navigationController?.pushViewController(categoryPage, animated: true)
    }
    
}

// MARK: - conform to ProfileCellDelegate

extension OthersProfileViewController: ProfileCellDelegate {
    
    func blockThisUser() {
        popBlockAlert()
    }
    
    func manipulateFollow() {
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
                                         unfollowCompletion: makeButtonUnFollow)
        
    }
    
    func goSettingPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let settingViewController = storyboard.instantiateViewController(withIdentifier: String(describing: SettingViewController.self)) as? SettingViewController else { return }
        navigationController?.pushViewController(settingViewController, animated: true)
    }
    
}

// MARK: - conform to UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension OthersProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
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


