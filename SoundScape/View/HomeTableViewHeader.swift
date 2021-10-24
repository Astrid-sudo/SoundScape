//
//  HomeTableViewHeader.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/22.
//

import UIKit

class HomeTableViewHeader: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = String(describing: HomeTableViewHeader.self)

    private(set) lazy var categoryLabel: UILabel = {
      let label = UILabel()
      label.textColor = .white
        label.font = UIFont(name: CommonUsage.font, size: 20)
      label.textAlignment = .left
      return label
    }()

    private(set) lazy var goToCategoryButt: UIButton = {
      let button = UIButton()
        button.setImage(UIImage(systemName: CommonUsage.SFSymbol.right), for: .normal)
        //      button.addTarget(self, action: #selector(removeThisCell), for: .touchUpInside)
      return button
    }()

    // MARK: - init
    
    override init(reuseIdentifier: String?) {
      super.init(reuseIdentifier: reuseIdentifier)
        setLabel()
        setButton()
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    // MARK: - method
    
    private func setLabel() {
        contentView.addSubview(categoryLabel)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            categoryLabel.heightAnchor.constraint(equalToConstant: 10)
        ])

    }
    
    private func setButton() {
        contentView.addSubview(goToCategoryButt)
        goToCategoryButt.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            goToCategoryButt.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor, constant: 8),
            goToCategoryButt.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor),
            goToCategoryButt.heightAnchor.constraint(equalToConstant: 10)
        ])

    }
    
}
