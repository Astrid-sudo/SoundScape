//
//  SearchCollectionViewCell.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/29.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    
    // MARK: - properties
    
    static let reuseIdentifier = String(describing: SearchCollectionViewCell.self)
    
    // MARK: - UI properties
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scYellow)
        label.backgroundColor = UIColor(named: CommonUsage.scLightGreen)
        label.layer.cornerRadius = 10
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setTextLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - configUI method
    
    private func setTextLabel() {
        contentView.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textLabel.widthAnchor.constraint(equalToConstant: 90),
            textLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        textLabel.layer.cornerRadius = 30

    }
    
    func setContent(content: String) {
        textLabel.text = content
        
    }
    
}
