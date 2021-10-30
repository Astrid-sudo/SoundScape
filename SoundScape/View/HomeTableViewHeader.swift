//
//  HomeTableViewHeader.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/22.
//

import UIKit

protocol PressPassableDelegate: AnyObject {
    func goCategoryPage(from section: Int)
}

class HomeTableViewHeader: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = String(describing: HomeTableViewHeader.self)
    
    private var section: Int?
    
    weak var delegate: PressPassableDelegate?
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: CommonUsage.fontSemibold, size: 32)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var goToCategoryButt: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: CommonUsage.SFSymbol.right), for: .normal)
        button.tintColor = UIColor(named: CommonUsage.scWhite)
        return button
    }()
    
    private lazy var backgroundButton: UIButton = {
       let button = UIButton()
        button.addTarget(self, action: #selector(pressBackgroundButton), for: .touchUpInside)
        return button
    }()
    // MARK: - init
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        tintColor = UIColor(named: CommonUsage.scDarkGreen)
        setLabel()
        setButton()
        setBackgroundButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - action
    
    @objc func pressBackgroundButton() {
        
        guard let section = section else { return }
        
        delegate?.goCategoryPage(from: section)
    }
    
    // MARK: - method
    
    private func setLabel() {
        contentView.addSubview(categoryLabel)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            categoryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
        
    }

    private func setButton() {
        contentView.addSubview(goToCategoryButt)
        goToCategoryButt.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            goToCategoryButt.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor, constant: 8),
            goToCategoryButt.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor)
        ])
    }
    
    private func setBackgroundButton() {
        contentView.addSubview(backgroundButton)
        backgroundButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backgroundButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            backgroundButton.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            backgroundButton.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        ])

    }
    
    func config(section: Int, content: String) {
        self.section = section
        categoryLabel.text = content
    }
    
}
