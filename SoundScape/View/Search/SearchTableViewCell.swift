//
//  SearchTableViewCell.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/29.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setImageView()
        setTitleLabel()
        setAuthorLabel()
        setFavoriteButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - method
    
    func setContent(title: String, author: String, imageNumber: Int) {
        titleLabel.text = title
        authorLabel.text = author
        theImageView.image = UIProperties.audioImages[imageNumber]
    }
    
    // MARK: - UI properties
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: Constant.scWhite)
        label.font = UIFont(name: Constant.font, size: 18)
        label.textAlignment = .left
        return label
    }()
    
    lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: Constant.scWhite)
        label.font = UIFont(name: Constant.font, size: 12)
        label.textAlignment = .left
        return label
    }()
    
    lazy var theImageView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 10
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: Constant.SFSymbol.heart), for: .normal)
        button.tintColor = .red
        button.isHidden = true
        return button
    }()
    
}

// MARK: - UI method

extension SearchTableViewCell {
    
    private func setImageView() {
        contentView.addSubview(theImageView)
        theImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            theImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            theImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            theImageView.heightAnchor.constraint(equalToConstant: 60),
            theImageView.widthAnchor.constraint(equalTo: theImageView.heightAnchor)
        ])
    }
    
    private func setTitleLabel() {
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: theImageView.trailingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10)
        ])
    }
    
    private func setAuthorLabel() {
        contentView.addSubview(authorLabel)
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            authorLabel.leadingAnchor.constraint(equalTo: theImageView.trailingAnchor, constant: 8),
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4)
        ])
    }
    
    private func setFavoriteButton() {
        contentView.addSubview(favoriteButton)
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

}
