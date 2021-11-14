//
//  ProfileTableViewCell.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/14.
//

import UIKit

protocol ProfileCellDelegate: AnyObject {
    func blockThisUser()
    func manipulateFollow()
}

class ProfileTableViewCell: UITableViewCell {
    
    // MARK: - properties
    
    static let reuseIdentifier = String(describing: ProfileTableViewCell.self)
    
    weak var delegate: ProfileCellDelegate?
    
    // MARK: - UI properties
    
    private lazy var coverImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.image = UIImage(named: CommonUsage.profileCover4)
        return image
    }()
    
    private lazy var userImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleToFill
        image.clipsToBounds = true
        image.layer.cornerRadius = CommonUsage.screenHeight / 10
        image.layer.borderWidth = 3
        image.layer.borderColor = UIColor(named: CommonUsage.scBlue)?.cgColor
        image.image = UIImage(named: CommonUsage.yeh1024)
        return image
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
        label.text = "0"
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
        label.text = "0"
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
        button.addTarget(self, action: #selector(manipulateFollow), for: .touchUpInside)
        button.backgroundColor = UIColor(named: CommonUsage.scLightBlue)
        button.layer.cornerRadius = 15
        button.setTitle(CommonUsage.Text.follow, for: .normal)
        return button
    }()
    
    private lazy var blockButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(named: CommonUsage.scWhite), for: .normal)
        button.addTarget(self, action: #selector(block), for: .touchUpInside)
        button.backgroundColor = UIColor(named: CommonUsage.scLightBlue)
        button.layer.cornerRadius = 15
        button.setTitle(CommonUsage.Text.block, for: .normal)
        return button
    }()

    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setCoverImageView()
        setUserImageView()
        setNameLabel()
        setSocialStackView()
        setFollowersStackView()
        setFollowersStackView()
        setFollowingsStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - action
    
    @objc func block() {
        delegate?.blockThisUser()
    }
    
    @objc func manipulateFollow() {
        delegate?.manipulateFollow()
    }
    
    // MARK: - config UI method
    
    private func setCoverImageView() {
        contentView.addSubview(coverImageView)
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coverImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: CommonUsage.screenHeight / 4)
        ])
    }
    
    private func setUserImageView() {
        contentView.addSubview(userImageView)
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            userImageView.centerYAnchor.constraint(equalTo: coverImageView.bottomAnchor,
                                                   constant: -CommonUsage.screenHeight / 16),
            userImageView.widthAnchor.constraint(equalToConstant: CommonUsage.screenHeight / 5),
            userImageView.heightAnchor.constraint(equalToConstant: CommonUsage.screenHeight / 5)
        ])
    }
    
    private func setNameLabel() {
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor)
        ])
    }
    
    private func setSocialStackView() {
        contentView.addSubview(socialStackView)
        socialStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            socialStackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            socialStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            socialStackView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor,
                                                     constant: 4),
            socialStackView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -4)
        ])
        
        socialStackView.addArrangedSubview(followersStackView)
        socialStackView.addArrangedSubview(followingsStackView)
        socialStackView.addArrangedSubview(blockButton)
        socialStackView.addArrangedSubview(followButton)
        
        NSLayoutConstraint.activate([
            followButton.widthAnchor.constraint(equalToConstant: 110),
            blockButton.widthAnchor.constraint(equalToConstant: 80)
        ])

    }
    
    private func setFollowersStackView() {
        followersStackView.addArrangedSubview(followersNumberLabel)
        followersStackView.addArrangedSubview(followersTitleLabel)
    }
    
    private func setFollowingsStackView() {
        followingsStackView.addArrangedSubview(followingsNumberLabel)
        followingsStackView.addArrangedSubview(followingsTitleLabel)
    }
    
    func configcell(userData: SCUser, followers: Int?, followings: Int?, userPic: String?, coverPic: String?) {
        
        nameLabel.text = userData.username
        
        if let userPic = userPic,
            let userPicData = Data(base64Encoded: userPic) {
            userImageView.image = UIImage(data: userPicData)
            userImageView.contentMode = .scaleAspectFill
        }
        
        if let coverPic = coverPic,
            let coverPicData = Data(base64Encoded: coverPic) {
            coverImageView.image = UIImage(data: coverPicData)
            coverImageView.contentMode = .scaleAspectFill
        }
        
        if let followers = followers {
            followersNumberLabel.text = String(followers)
        }
        
        if let followings = followings {
            followingsNumberLabel.text = String(followings)
        }
        
    }
    
     func makeButtonFollowed() {
        followButton.setTitle(CommonUsage.Text.unfollow, for: .normal)
        followButton.backgroundColor = UIColor(named: CommonUsage.scLightBlue)
    }
    
     func makeButtonUnFollow() {
        followButton.setTitle(CommonUsage.Text.follow, for: .normal)
        followButton.backgroundColor = UIColor(named: CommonUsage.scLightBlue)
    }

}

