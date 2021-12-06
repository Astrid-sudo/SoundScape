//
//  MapSearchResultTableViewCell.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/7.
//

import UIKit

class MapSearchResultTableViewCell: UITableViewCell {
    
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
    
    // MARK: - method
    
    func configCell(title: String?, subTitle: String?) {
        titleLabel.text = title
        subTitleLabel.text = subTitle
    }
    
    // MARK: - UI properties
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: Constant.scGray)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: Constant.scGray)
        label.numberOfLines = 0
        return label
    }()

}

// MARK: - UI method

extension MapSearchResultTableViewCell {
    
    private func setBackgroundcolor() {
        backgroundColor = UIColor(named: Constant.scBlue)
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(named: Constant.scLightBlue)
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
    
}
