//
//  ProfileBlankTableViewCell.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/20.
//

import UIKit

class ProfileBlankTableViewCell: UITableViewCell {
    
    // MARK: - UI properties
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var theImageView: UIImageView = {
        let image = UIImageView()
        image.layer.masksToBounds = true
        image.image = UIImage(named: Constant.launchScreen1)
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(named: Constant.scGreen)
        setLabel()
        setImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - config UI method
    
    private func setLabel() {
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
        ])
    }
    
    private func setImageView() {
        contentView.addSubview(theImageView)
        theImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            theImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            theImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            theImageView.topAnchor.constraint(equalTo: label.bottomAnchor),
            theImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func cellType(profilePageSection: ProfilePageSection) {
        
        switch profilePageSection {
        case .followingsLatest:
            label.text = "Follow other users to see their posts here."
            
        case .myFavorite:
            label.text = "Press heart on small player to add your favorite posts."
            
        case .myAudio:
            label.text = "Upload audio to see all your audio here."
            
        }
    }
    
}
