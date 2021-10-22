//
//  HomeCollectionViewCell.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/22.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: HomeCollectionViewCell.self)
    
    // MARK:- UI properties
    
    private lazy var audioImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private lazy var audioTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: CommonUsage.font, size: 14)
        return label
    }()
    
    private lazy var authorNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: CommonUsage.font, size: 12)
        return label
    }()
    
    // MARK:- init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAudioImage()
        setAudioTitleLabel()
        setAuthorNameLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- configUI method
    
    private func setAudioImage() {
        contentView.addSubview(audioImage)
        audioImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            audioImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            audioImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            audioImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            audioImage.heightAnchor.constraint(equalToConstant: 60),
            audioImage.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setAudioTitleLabel() {
        contentView.addSubview(audioTitleLabel)
        audioTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            audioTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            audioTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            audioTitleLabel.heightAnchor.constraint(equalToConstant: 20),
            audioTitleLabel.topAnchor.constraint(equalTo: audioImage.bottomAnchor, constant: 5)
        ])
    }
    
    private func setAuthorNameLabel() {
        contentView.addSubview(authorNameLabel)
        authorNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            authorNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            authorNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            authorNameLabel.topAnchor.constraint(equalTo: audioTitleLabel.bottomAnchor, constant: 8),
            authorNameLabel.heightAnchor.constraint(equalToConstant: 20),
            authorNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 8)
        ])
    }
    
    func setCell(image: URL?, audioTitle: String, author: String) {
        audioImage.image = UIImage(named: CommonUsage.audioImage)
        audioTitleLabel.text = audioTitle
        authorNameLabel.text = author
    }

}
