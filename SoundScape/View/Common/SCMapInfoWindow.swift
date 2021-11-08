//
//  SCMapMarkerIcon.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/6.
//

protocol ButtonTappedPassableDelegate: AnyObject {
    func pushSoundDetailPage()
}

import UIKit

class SCMapInfoWindow: UIView {
    
    weak var delegate: ButtonTappedPassableDelegate?
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(goSoundDetailPage), for: .touchUpInside)
        return button
    }()
    
    private lazy var titlelabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scWhite)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.01
        return label
    }()
    
    private lazy var authorNamelabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scWhite)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.01
        return label
    }()
    
    // MARK: - init
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.backgroundColor = UIColor(named: CommonUsage.scBlue)
        setButton()
        setTitleLabel()
        setAuthorNamelabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - action
    
    @objc func goSoundDetailPage() {
        delegate?.pushSoundDetailPage()
    }
    
    // MARK: - UI method
    
    private func setButton() {
        self.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            button.topAnchor.constraint(equalTo: self.topAnchor),
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func setTitleLabel() {
        self.addSubview(titlelabel)
        titlelabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titlelabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            titlelabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            titlelabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8)
        ])
    }
    
    private func setAuthorNamelabel() {
        self.addSubview(authorNamelabel)
        authorNamelabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            authorNamelabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            authorNamelabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            authorNamelabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - method
    
    func setMapMarkerIcon(title: String?, authorName: String?) {
        titlelabel.text = title
        authorNamelabel.text = authorName
    }
    
}
