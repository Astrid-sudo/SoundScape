//
//  HomeTableViewCell.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/22.
//

import UIKit

protocol AlertPresentableDelegate: AnyObject {
    func popBlockAlert(toBeBlockedID: String)
    func popDeletePostAlert(documentID: String)
}

class HomeTableViewCell: UITableViewCell {
    
    // MARK: - properties
    
    static let reuseIdentifier = String(describing: HomeTableViewCell.self)
    
    var firebaseData = [SCPost]() {
        
        didSet {
            collectionView.reloadData()
        }
    }
    
    var category = ""
    
    var profileSection: ProfilePageSection?
    
    let firebaseManager = FirebaseManager.shared
    
    let signInManager = SignInManager.shared
    
    weak var delegate: AlertPresentableDelegate?
    
    // MARK: - UI properties
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 150, height: 150)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(named: CommonUsage.scBlue)
        collectionView.bounces = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(named: CommonUsage.scBlue)
        tintColor =  UIColor(named: CommonUsage.scBlue)
        setCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - method
    
    private func popBlockAlert(toBeBlockedID: String) {
        delegate?.popBlockAlert(toBeBlockedID: toBeBlockedID)
    }
    
    func popDeletePostAlert(documentID: String) {
        delegate?.popDeletePostAlert(documentID: documentID)
    }
    
    // MARK: - config UI method
    
    private func setCollectionView() {
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 168)
        ])
        
        collectionView.register(HomeCollectionViewCell.self,
                                forCellWithReuseIdentifier: HomeCollectionViewCell.reuseIdentifier)
    }
    
}

// MARK: - conform to UICollectionViewDataSource

extension HomeTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return firebaseData.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // swiftlint:disable line_length
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.reuseIdentifier, for: indexPath) as? HomeCollectionViewCell else { return UICollectionViewCell() }
        
        // swiftlint:enable line_length
        
        cell.setCell(imageNumber: firebaseData[indexPath.item].imageNumber,
                     audioTitle: firebaseData[indexPath.item].title,
                     author: firebaseData[indexPath.item].authorName)
        
        return cell
    }
    
}

// MARK: - conform to UICollectionViewDelegate

extension HomeTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(category),didSelect \(indexPath), url: \(firebaseData[indexPath.item].audioURL)")
        
        AudioPlayerWindow.shared.show()
        
        let title = firebaseData[indexPath.item].title
        let author = firebaseData[indexPath.item].authorName
        let content = firebaseData[indexPath.item].content
        let duration = firebaseData[indexPath.item].duration
        let documentID = firebaseData[indexPath.item].documentID
        let authorUserID = firebaseData[indexPath.item].authorID
        let audioImageNumber = firebaseData[indexPath.item].imageNumber
        let authorAccountProvider = firebaseData[indexPath.item].authIDProvider
        
        if let remoteURL = firebaseData[indexPath.item].audioURL {
            RemoteAudioManager.shared.downloadRemoteURL(documentID: documentID, remoteURL: remoteURL) { localURL in
                AudioPlayHelper.shared.url = localURL
                AudioPlayHelper.shared.setPlayInfo(title: title,
                                                   author: author,
                                                   content: content,
                                                   duration: duration,
                                                   documentID: documentID,
                                                   authorUserID: authorUserID,
                                                   audioImageNumber: audioImageNumber,
                                                   authorAccountProvider: authorAccountProvider)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        
        let index = indexPath.row
        let identifier = "\(index)" as NSString
        let post = firebaseData[index]
        let authorID = post.authorID
        
        
        if authorID != signInManager.currentUserInfoFirebase?.userID {
            //封鎖作者
            return UIContextMenuConfiguration(
                identifier: identifier, previewProvider: nil) { _ in
                    // 3
                    let blockAction = UIAction(title: "Block this user",
                                               image: nil) { _ in
                        self.popBlockAlert(toBeBlockedID: authorID)
                    }
                    return UIMenu(title: "",
                                  image: nil,
                                  children: [blockAction])
                }
            
        } else {
            //            刪除post
            let audioDocumentID = post.documentID
            
            return UIContextMenuConfiguration(
                identifier: identifier, previewProvider: nil) { _ in
                    // 3
                    let deleteAction = UIAction(title: "Delete this post",
                                                image: nil) { _ in
                        self.popDeletePostAlert(documentID: audioDocumentID)
                    }
                    return UIMenu(title: "",
                                  image: nil,
                                  children: [deleteAction])
                }
        }
    }
    
}

// MARK: - conform to UICollectionViewDelegateFlowLayout

extension HomeTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
}

