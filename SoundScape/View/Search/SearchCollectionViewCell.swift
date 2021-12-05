//
//  SearchCollectionViewCell.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/29.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI properties
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: Constant.scWhite)
        label.backgroundColor = UIColor(named: Constant.scLightBlue)
        label.layer.cornerRadius = 20
        label.textAlignment = .center
        label.clipsToBounds = true
        label.layer.masksToBounds = true
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
            textLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textLabel.widthAnchor.constraint(equalToConstant: 95),
            textLabel.heightAnchor.constraint(equalToConstant: 41)
        ])
    }
    
    func setContent(content: String) {
        textLabel.text = content
        textLabel.layer.cornerRadius = 10
    }
    
    func setLabelColorRed() {
        textLabel.backgroundColor = UIColor(named: Constant.scSuperLightBlue)
    }
    
    func setLabelColorGreen() {
        textLabel.backgroundColor = UIColor(named: Constant.scLightBlue)
    }

}
