//
//  SettingTableViewCell.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/2.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(named: Constant.scBlue)
        setLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - method
    
    func configCell(content: String) {
        label.text = content
    }
    
    // MARK: - UI properties
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: Constant.scWhite)
        label.textAlignment = .left
        return label
    }()
    
}

// MARK: - UI method

extension SettingTableViewCell {
    
    private func setLabel() {
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

}
