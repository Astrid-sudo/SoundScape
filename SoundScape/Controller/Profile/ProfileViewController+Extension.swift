//
//  ProfileViewController+Extension.swift
//  SoundScape
//
//  Created by Astrid on 2021/12/6.
//

import UIKit

// MARK: - UI method
extension ProfileViewController {
    
    func setBackgroundColor() {
        view.backgroundColor = UIColor(named: Constant.scBlue)
    }
    
    func setNavigationBar() {
        navigationItem.title = Constant.Text.myProfile
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = UIColor(named: Constant.scBlue)
        let font = UIFont(name: Constant.fontBungee, size: 28)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font,
                                                                   NSAttributedString.Key.foregroundColor: UIColor(named: Constant.scWhite)]
    }
    
}

// MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        ProfilePageSection.allCases.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    // swiftlint:disable line_length
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.reuseIdentifier) as? HomeTableViewCell,
              let profileDataCell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.reuseIdentifier) as? ProfileTableViewCell,
              let profileBlankCell = tableView.dequeueReusableCell(withIdentifier: ProfileBlankTableViewCell.reuseIdentifier) as? ProfileBlankTableViewCell,
              let logginUser = signInManager.currentUserInfoFirebase else { return UITableViewCell() }
        // swiftlint:enable line_length

        cell.backgroundColor = UIColor(named: Constant.scBlue)
        cell.delegate = self
        profileDataCell.backgroundColor = UIColor(named: Constant.scBlue)
        
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
            guard let followings = currentUserFollowingList,
                  !followings.isEmpty else {
                      print("ProfilePage cant get followingList")
                      profileBlankCell.cellType(profilePageSection: .followingsLatest)
                      return profileBlankCell
                  }
            
            var myFollowingsUserFiles = [SCPost]()
            for audioFile in allAudioFiles {
                for folloing in followings where audioFile.authorID == folloing.userID {
                        myFollowingsUserFiles.append(audioFile)
                }
            }
            
            guard !myFollowingsUserFiles.isEmpty else {
                profileBlankCell.cellType(profilePageSection: .followingsLatest)
                return profileBlankCell
            }
            
            cell.firebaseData = myFollowingsUserFiles
            cell.profileSection = ProfilePageSection.allCases[indexPath.section - 1]
            return cell
            
        case 2:
            
            guard let currentUserFavoriteDocumentIDs = currentUserFavoriteDocumentIDs,
                  !currentUserFavoriteDocumentIDs.isEmpty else {
                      profileBlankCell.cellType(profilePageSection: .myFavorite)
                      return profileBlankCell
                  }
            
            var myFavoriteFiles = [SCPost]()
            
            for audioFile in allAudioFiles {
                for favorite in currentUserFavoriteDocumentIDs where audioFile.documentID == favorite {
                        myFavoriteFiles.append(audioFile)
                }
            }
            
            guard !myFavoriteFiles.isEmpty else {
                profileBlankCell.cellType(profilePageSection: .myFavorite)
                return profileBlankCell
            }
            
            cell.firebaseData = myFavoriteFiles
            cell.profileSection = ProfilePageSection.allCases[indexPath.section - 1]
            return cell
            
        case 3:
            
            let myAudioFiles = allAudioFiles.filter({$0.authorName == signInManager.currentUserInfoFirebase?.username})
            guard !myAudioFiles.isEmpty else {
                profileBlankCell.cellType(profilePageSection: .myAudio)
                return profileBlankCell
            }
            cell.firebaseData = myAudioFiles
            cell.profileSection = ProfilePageSection.allCases[indexPath.section - 1]
            return cell
            
        default:
            // swiftlint:disable line_length
            let filteredFiles = allAudioFiles.filter({$0.category == AudioCategory.allCases[indexPath.section - 1].rawValue})
            // swiftlint:enable line_length
            cell.firebaseData = filteredFiles
            cell.category = AudioCategory.allCases[indexPath.item].rawValue
            return cell
        }
    }
    
}

// MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            return nil
            
        } else {
            // swiftlint:disable line_length
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomeTableViewHeader.reuseIdentifier) as? HomeTableViewHeader else { return UIView()}
            // swiftlint:enable line_length
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
            
            return 200
            
        }
    }
    
}
