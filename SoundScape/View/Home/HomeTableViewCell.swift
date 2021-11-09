//
//  HomeTableViewCell.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/22.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    
    // MARK: - properties
    
    static let reuseIdentifier = String(describing: HomeTableViewCell.self)
    
    let remotePlayHelper = RemotePlayHelper.shared
    
    var firebaseData = [SCPost]() {
        
        didSet {
            collectionView.reloadData()
        }
    }
    
    var category = ""
    
    var profileSection: ProfilePageSection?
    
    // MARK: - UI properties
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 150, height: 150)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 10
        
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
    
    // MARK: - config UI method
    
    private func setCollectionView() {
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 168),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
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
        
        cell.setCell(image: nil,
                     audioTitle: firebaseData[indexPath.item].title, author: firebaseData[indexPath.item].authorName)
        
        return cell
    }
    
}

// MARK: - conform to UICollectionViewDelegate

extension HomeTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(category),didSelect \(indexPath), url: \(firebaseData[indexPath.item].audioURL)")
        
        let title = firebaseData[indexPath.item].title
        let author = firebaseData[indexPath.item].authorName
        let content = firebaseData[indexPath.item].content
        let duration = firebaseData[indexPath.item].duration
        let documentID = firebaseData[indexPath.item].documentID
        let authorUserID = firebaseData[indexPath.item].authorID
        let authorAccountProvider = firebaseData[indexPath.item].authIDProvider
        
        //         Must set url first, then set playInfo.
        //        (Because in class RemotePlayHelper, set url will make playinfo be nil.)
        remotePlayHelper.url = firebaseData[indexPath.item].audioURL
        remotePlayHelper.setPlayInfo(title: title,
                                     author: author,
                                     content: content,
                                     duration: duration,
                                     documentID:documentID,
                                     authorUserID: authorUserID,
                                     authorAccountProvider:authorAccountProvider)
        
        AudioPlayerWindow.shared.show()
    }
    
}
