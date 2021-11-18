//
//  HomeCollectionViewCell.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/22.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: HomeCollectionViewCell.self)
    
    // MARK: - UI properties
    
    private lazy var audioImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 10
        image.mask?.clipsToBounds = true
        image.clipsToBounds = true
        return image
    }()
    
    private lazy var audioTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont(name: CommonUsage.font, size: 14)
        return label
    }()
    
    private lazy var authorNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont(name: CommonUsage.font, size: 12)
        return label
    }()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(named: CommonUsage.scBlue)
        setAudioImage()
        setAudioTitleLabel()
        setAuthorNameLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - configUI method
    
    private func setAudioImage() {
        contentView.addSubview(audioImage)
        audioImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            audioImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            audioImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            audioImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            audioImage.heightAnchor.constraint(equalTo: audioImage.widthAnchor)
        ])
    }
    
    private func setAudioTitleLabel() {
        contentView.addSubview(audioTitleLabel)
        audioTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            audioTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            audioTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            audioTitleLabel.heightAnchor.constraint(equalToConstant: 20),
            audioTitleLabel.topAnchor.constraint(equalTo: audioImage.bottomAnchor, constant: 4)
        ])
    }
    
    private func setAuthorNameLabel() {
        contentView.addSubview(authorNameLabel)
        authorNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            authorNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            authorNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            authorNameLabel.topAnchor.constraint(equalTo: audioTitleLabel.bottomAnchor),
            authorNameLabel.heightAnchor.constraint(equalToConstant: 20),
            authorNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }
    
    func setCell(imageNumber: Int, audioTitle: String, author: String) {
        audioImage.image = CommonUsage.audioImages[imageNumber]
        audioTitleLabel.text = audioTitle
        authorNameLabel.text = author
    }
    
    func setCellImage(image: UIImage?) {
        audioImage.image = image
        audioTitleLabel.removeFromSuperview()
        authorNameLabel.removeFromSuperview()
    }
    
    func setImageBorder() {
        audioImage.layer.borderWidth = 5
        audioImage.layer.borderColor = UIColor(named: CommonUsage.scRed)?.cgColor
    }
    
    func removeImageBorder() {
        audioImage.layer.borderWidth = 0
        audioImage.layer.borderColor = UIColor.clear.cgColor
    }
    
}
