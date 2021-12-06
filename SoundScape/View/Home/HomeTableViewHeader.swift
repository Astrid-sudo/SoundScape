//
//  HomeTableViewHeader.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/22.
//

import UIKit

enum SectionPageType {
    case profileSection
    case audioCategory
}

protocol PressPassableDelegate: AnyObject {
    func goSectionPage(from section: Int, sectionPageType: SectionPageType)
}

class HomeTableViewHeader: UITableViewHeaderFooterView {
    
    private var section: Int?
    
    weak var delegate: PressPassableDelegate?
    
    var presentInPage: SectionPageType?
    
    // MARK: - init
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        tintColor = UIColor(named: Constant.scBlue)
        setLabel()
        setButton()
        setBackgroundButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - action
    
    @objc func pressBackgroundButton() {
        
        guard let section = section,
              let presentInPage = presentInPage else { return }
        
        delegate?.goSectionPage(from: section, sectionPageType: presentInPage)
    }
    
    // MARK: - method
    
    func config(section: Int, content: String) {
        self.section = section
        categoryLabel.text = content
    }
    
    // MARK: - UI properties
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: Constant.fontSemibold, size: 18)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var goToCategoryButt: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: Constant.SFSymbol.right), for: .normal)
        button.tintColor = UIColor(named: Constant.scWhite)
        return button
    }()
    
    private lazy var backgroundButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(pressBackgroundButton), for: .touchUpInside)
        return button
    }()
    
}

// MARK: - UI method

extension HomeTableViewHeader {
    private func setLabel() {
        contentView.addSubview(categoryLabel)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
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
    
}
