//
//  CategoryTableViewCell.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/29.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {
    
    // MARK: - properties
    
    static let reuseIdentifier = String(describing: CategoryTableViewCell.self)
    
    // MARK: - UI properties
    
    lazy var titlelabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scWhite)
        label.font = UIFont(name: CommonUsage.font, size: 20)
        label.textAlignment = .right
        return label
    }()
    
    lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scWhite)
        label.font = UIFont(name: CommonUsage.font, size: 14)
        label.textAlignment = .right
        return label
    }()

    lazy var theImageView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 40
        image.layer.masksToBounds = true
        return image
    }()
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setImageView()
        setTitlelabel()
        setAuthorLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - config UI method
    
    private func setImageView() {
        contentView.addSubview(theImageView)
        theImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            theImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            theImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            theImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            theImageView.heightAnchor.constraint(equalToConstant: 100),
            theImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    private func setTitlelabel() {
        contentView.addSubview(titlelabel)
        titlelabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titlelabel.trailingAnchor.constraint(equalTo: theImageView.trailingAnchor, constant: -20),
            titlelabel.topAnchor.constraint(equalTo: theImageView.topAnchor, constant: 20),
            titlelabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setAuthorLabel() {
        contentView.addSubview(authorLabel)
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            authorLabel.trailingAnchor.constraint(equalTo: theImageView.trailingAnchor, constant: -20),
            authorLabel.topAnchor.constraint(equalTo: titlelabel.bottomAnchor, constant: 10),
            authorLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func setContent(title: String, author: String) {
        titlelabel.text = title
        authorLabel.text = author
        theImageView.image = UIImage(named: CommonUsage.audioImage)
    }
    
}

