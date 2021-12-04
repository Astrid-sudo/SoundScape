//
//  CommentTableViewCell.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/1.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    // MARK: - UI properties
    
    private lazy var wholeStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .top
        stack.distribution = .fillProportionally
        return stack
    }()
    
    lazy var leftImageView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 25
        image.layer.masksToBounds = true
        image.image = UIImage(named: CommonUsage.yeh1024)
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    lazy var rightImageView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 25
        image.layer.masksToBounds = true
        image.image = UIImage(named: CommonUsage.yeh1024)
        return image
    }()
    
    private lazy var commentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .top
        stack.distribution = .fill
        return stack
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scWhite)
        label.layer.cornerRadius = 10
        label.numberOfLines = 0
        label.textAlignment = .left
        label.baselineAdjustment = .alignBaselines
        label.autoresizesSubviews = false
        label.font = UIFont(name: CommonUsage.font, size: 16)
        return label
    }()
    
    private lazy var commentInfoLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scWhite)
        label.layer.cornerRadius = 10
        label.textAlignment = .left
        label.font = UIFont(name: CommonUsage.font, size: 12)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var backgroundGrayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: CommonUsage.scLightBlue)
        view.layer.cornerRadius = 10.0
        return view
    }()
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(named: CommonUsage.scBlue)
        setImagesConstraint()
        setCommentStackView()
        pinBackground(backgroundGrayView, to: commentStackView)
        setWholeStackViewStackView()
        rightImageView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - config UI method
    
    private func pinBackground(_ view: UIView, to stackView: UIStackView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.insertSubview(view, at: 0)
        view.pin(to: stackView)
    }
    
    private func setImagesConstraint() {
        NSLayoutConstraint.activate([
            leftImageView.widthAnchor.constraint(equalToConstant: 50),
            leftImageView.heightAnchor.constraint(equalToConstant: 50),
            rightImageView.widthAnchor.constraint(equalToConstant: 50),
            rightImageView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setCommentStackView() {
        commentStackView.addArrangedSubview(messageLabel)
        commentStackView.addArrangedSubview(commentInfoLabel)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        commentInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: commentStackView.leadingAnchor, constant: 8),
            messageLabel.trailingAnchor.constraint(equalTo: commentStackView.trailingAnchor, constant: -8),
            messageLabel.topAnchor.constraint(equalTo: commentStackView.topAnchor, constant: 8),
            
            commentInfoLabel.leadingAnchor.constraint(equalTo: commentStackView.leadingAnchor, constant: 8),
            commentInfoLabel.trailingAnchor.constraint(equalTo: commentStackView.trailingAnchor, constant: 8),
            commentInfoLabel.bottomAnchor.constraint(equalTo: commentStackView.bottomAnchor, constant: -8)
        ])
    }
    
    private func setWholeStackViewStackView() {
        contentView.addSubview(wholeStackView)
        wholeStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wholeStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            wholeStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            wholeStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            wholeStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        wholeStackView.addArrangedSubview(leftImageView)
        wholeStackView.addArrangedSubview(commentStackView)
        wholeStackView.addArrangedSubview(rightImageView)
        
    }
    
    func configCell(comment: SCComment, authorImageString: String?) {
        
        guard let createTime = comment.createdTime?.dateValue() else { return }
        let createdTime = "\(createTime + 28800)"
        let processedCreatedTime = String(createdTime.dropLast(9))
        let commentAuthorName = comment.userName
        
        messageLabel.text = comment.comment
        commentInfoLabel.text = "\(commentAuthorName) at \(processedCreatedTime)"
        
        if let authorImageString = authorImageString {
            if let data = Data(base64Encoded: authorImageString) {
                leftImageView.image = UIImage(data: data)
            }
        }
    }
    
}

extension UIView {
    func pin(to view: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
