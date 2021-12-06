//
//  SCMapMarkerIcon.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/6.
//

import UIKit

protocol ButtonTappedPassableDelegate: AnyObject {
    func pushSoundDetailPage()
}

class SCMapInfoWindow: UIView {
    
    weak var delegate: ButtonTappedPassableDelegate?
    
    // MARK: - init
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIProperties.screenWidth - 100, height: 50))
        self.backgroundColor = UIColor(named: Constant.scLightBlue)
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor(named: Constant.scGray)?.cgColor
        setHeadphoneImageView()
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
    
    // MARK: - method
    
    func setMapMarkerIcon(title: String?, authorName: String?, audioImageNumber: Int) {
        titlelabel.text = title
        authorNamelabel.text = authorName
        audioImage.image = UIProperties.audioImages[audioImageNumber]
    }
    
    // MARK: - UI properties
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(goSoundDetailPage), for: .touchUpInside)
        return button
    }()
    
    private lazy var titlelabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: Constant.scWhite)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.01
        return label
    }()
    
    private lazy var authorNamelabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: Constant.scWhite)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.01
        return label
    }()
    
    private lazy var audioImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
}

// MARK: - UI method

extension SCMapInfoWindow {
    
    private func setHeadphoneImageView() {
        self.addSubview(audioImage)
        audioImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            audioImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4),
            audioImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            audioImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4),
            audioImage.widthAnchor.constraint(equalTo: audioImage.heightAnchor)
        ])
    }
    
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
            titlelabel.leadingAnchor.constraint(equalTo: audioImage.trailingAnchor, constant: 4),
            titlelabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 4)
        ])
    }
    
    private func setAuthorNamelabel() {
        self.addSubview(authorNamelabel)
        authorNamelabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            authorNamelabel.topAnchor.constraint(equalTo: titlelabel.bottomAnchor, constant: 4),
            authorNamelabel.leadingAnchor.constraint(equalTo: audioImage.trailingAnchor, constant: 4),
            authorNamelabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4)
        ])
    }
    
}
