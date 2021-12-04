//
//  MapSearchResultTableViewCell.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/7.
//

import UIKit

class MapSearchResultTableViewCell: UITableViewCell {
    
    // MARK: - UI properties
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: CommonUsage.scGray)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: CommonUsage.scGray)
        label.numberOfLines = 0
        return label
    }()

    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setBackgroundcolor()
        setTitleLabel()
        setSubTitleLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - config UI method
    
    private func setBackgroundcolor() {
        backgroundColor = UIColor(named: CommonUsage.scBlue)
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(named: CommonUsage.scLightBlue)
        selectedBackgroundView = bgColorView
    }
    
    private func setTitleLabel() {
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setSubTitleLabel() {
        contentView.addSubview(subTitleLabel)
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            subTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }

    func configCell(title: String?, subTitle: String?) {
        titleLabel.text = title
        subTitleLabel.text = subTitle
    }
    
}
