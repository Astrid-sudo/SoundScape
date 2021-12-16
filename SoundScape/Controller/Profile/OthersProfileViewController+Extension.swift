//
//  OthersProfileViewController+Extension.swift
//  SoundScape
//
//  Created by Astrid on 2021/12/6.
//

import UIKit
import Photos

extension OthersProfileViewController {
    
    // MARK: - config UI method
    
    func setBackgroundColor() {
        view.backgroundColor = UIColor(named: Constant.scBlue)
    }
    
    func setNavigationBar() {
        guard let userWillDisplay = userWillDisplay else { return }
        navigationController?.isNavigationBarHidden = false
        // swiftlint:disable line_length
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(backToLastPage))
        // swiftlint:enable line_length
        navigationItem.leftBarButtonItem?.image = UIImage(systemName: Constant.SFSymbol.back)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: Constant.scWhite)
        
        switch profilePageType {
        case .otherUser:
            navigationItem.title = userWillDisplay.username
            
        case .loggInUser:
            navigationItem.title = Constant.Text.myProfile
            
        }
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
    
    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable line_length
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.reuseIdentifier) as? HomeTableViewCell,
              let profileDataCell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.reuseIdentifier) as? ProfileTableViewCell,
              let userWillDisplay = userWillDisplay else { return UITableViewCell() }
        // swiftlint:enable line_length

        cell.backgroundColor = UIColor(named: Constant.scBlue)
        cell.delegate = self
        
        profileDataCell.backgroundColor = UIColor(named: Constant.scBlue)
        
        switch indexPath.section {
            
        case 0:
            profileDataCell.delegate = self
            
            switch profilePageType {
            case .loggInUser:
                
                profileDataCell.configMyProfilecell(userData: userWillDisplay,
                                                    followers: numbersOfFollowers,
                                                    followings: numbersOfFollowings,
                                                    userPic: otherUserPic,
                                                    coverPic: otherUserCover)
                
            case.otherUser:
                
                profileDataCell.configcell(userData: userWillDisplay,
                                           followers: numbersOfFollowers,
                                           followings: numbersOfFollowings,
                                           userPic: otherUserPic,
                                           coverPic: otherUserCover)
                
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
                return ProfileBlankTableViewCell()
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
            
            guard !myFollowingsUserFiles.isEmpty else {
                return ProfileBlankTableViewCell()
            }
            
            cell.firebaseData = myFollowingsUserFiles
            cell.profileSection = ProfilePageSection.allCases[indexPath.section - 1]
            return cell
            
        case 2:
            
            guard let userFavoriteDocumentIDs = userFavoriteDocumentIDs else {
                print("ProfilePage cant get userFavoriteDocumentIDs")
                return ProfileBlankTableViewCell()
            }
            
            var myFavoriteFiles = [SCPost]()
            
            for audioFile in allAudioFiles {
                for favorite in userFavoriteDocumentIDs where audioFile.documentID == favorite {
                    myFavoriteFiles.append(audioFile)
                }
            }
            
            guard !myFavoriteFiles.isEmpty else {
                return ProfileBlankTableViewCell()
            }
            
            cell.firebaseData = myFavoriteFiles
            cell.profileSection = ProfilePageSection.allCases[indexPath.section - 1]
            return cell
            
        case 3:
            let myAudioFiles = allAudioFiles.filter({$0.authorName == userWillDisplay.username})
            
            guard !myAudioFiles.isEmpty else {
                return ProfileBlankTableViewCell()
            }
            
            cell.firebaseData = myAudioFiles
            cell.profileSection = ProfilePageSection.allCases[indexPath.section - 1]
            return cell
            
        default:
            // swiftlint:disable line_length
            let filteredFiles = allAudioFiles.filter({$0.category == AudioCategory.allCases[indexPath.section].rawValue})
            // swiftlint:enable line_length
            cell.firebaseData = filteredFiles
            cell.category = AudioCategory.allCases[indexPath.item].rawValue
            return cell
            
        }
    }
    
    // swiftlint:enable cyclomatic_complexity
    
}

// MARK: - conform to UITableViewDelegate

extension OthersProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            return nil
        } else {
            // swiftlint:disable line_length
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomeTableViewHeader.reuseIdentifier) as? HomeTableViewHeader else { return UIView() }
            // swiftlint:enable line_length
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
        350
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath == IndexPath(row: 0, section: 3) {
            
            return 230
            
        } else if indexPath == IndexPath(row: 0, section: 0) {
            
            return 310
            
        } else {
            
            return 168
            
        }
    }
    
}

// MARK: - conform to PressPassableDelegate

extension OthersProfileViewController: PressPassableDelegate {
    
    func goSectionPage(from section: Int, sectionPageType: SectionPageType) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // swiftlint:disable line_length
        guard let categoryPage = storyboard.instantiateViewController(withIdentifier: CategoryViewController.reuseIdentifier) as? CategoryViewController,
              let displayUserID = userWillDisplay?.userID else { return }
        // swiftlint:enable line_length

        switch section {
            
        case 1:
            
            let section = ProfilePageSection.allCases[section - 1]
            categoryPage.config(profileSection: section, displayUserID: displayUserID)
            
        case 2:
            
            let section = ProfilePageSection.allCases[section - 1]
            categoryPage.config(profileSection: section, displayUserID: displayUserID)
            
        case 3:
            
            let section = ProfilePageSection.allCases[section - 1]
            categoryPage.config(profileSection: section, displayUserID: displayUserID)
            
        default:
            break
        }
        
        navigationController?.pushViewController(categoryPage, animated: true)
    }
    
    func goCategoryPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // swiftlint:disable line_length
        guard let categoryPage = storyboard.instantiateViewController(withIdentifier: CategoryViewController.reuseIdentifier) as? CategoryViewController else { return }
        // swiftlint:enable line_length
        navigationController?.pushViewController(categoryPage, animated: true)
    }
    
}

// MARK: - conform to UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension OthersProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    // swiftlint:disable line_length
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // swiftlint:enable line_length
        
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
