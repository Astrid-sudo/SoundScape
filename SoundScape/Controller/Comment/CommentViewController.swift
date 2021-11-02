//
//  CommentViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/1.
//

import UIKit

class CommentViewController: UIViewController {
    
    var fakeData = [SCComment(documentID: "",
                              userID: "yaheyyodude",
                              userName: "厘題恩",
                              userImage: nil,
                              createdTime: nil,
                              comment: "想去聽，希望這次去可以遇到好的狀況，旁邊也不要太吵，錄到乾淨的聲音。想去聽，希望這次去可以遇到好的狀況，旁邊也不要太吵，錄到乾淨的聲音。"),
                    SCComment(documentID: "",
                              userID: "yaheyyodude",
                              userName: "厘題恩",
                              userImage: nil,
                              createdTime: nil,
                              comment: "想去聽，希望這次去可以遇到好的狀況。"),
                    SCComment(documentID: "",
                              userID: "yaheyyodude",
                              userName: "厘題恩",
                              userImage: nil,
                              createdTime: nil,
                              comment: "想去聽。")
    ]
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewbackgroundColor()
        setCommentTitleLabel()
        setDismissButton()
        setTableView()
        setUserImage()
        setTextView()
        setCommentPlaceHolder()
        addSendButton()
    }
    
    // MARK: - method
    
    @objc func dismissCommentViewController() {
        dismiss(animated: true)
    }
    
    // MARK: - UI properties
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.allowsSelection = false
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.backgroundColor = UIColor(named: CommonUsage.scRed)
        table.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.reuseIdentifier)
        return table
    }()
    
    private lazy var commentTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scWhite)
        label.textAlignment = .center
        label.font = UIFont(name: CommonUsage.font, size: 24)
        label.numberOfLines = 0
        label.text = CommonUsage.Text.comments
        label.backgroundColor = .clear
        return label
    }()
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        let bigImage = UIImage(systemName: CommonUsage.SFSymbol.chevronDown, withConfiguration: config)
        button.setImage(bigImage, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(dismissCommentViewController), for: .touchUpInside)
        return button
    }()
    
    lazy var currentUserImageView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 25
        image.layer.masksToBounds = true
        image.image = UIImage(named: CommonUsage.profilePic2)
        return image
    }()
    
    private lazy var commentTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .white
        textView.font = UIFont(name: CommonUsage.font, size: 15)
        textView.textAlignment = .left
        textView.isEditable = true
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor(named: CommonUsage.scGray)
        textView.layer.cornerRadius = 10
        textView.delegate = self
//        textView.maximumContentSizeCategory = .small
        textView.textContainer.maximumNumberOfLines = 8
        textView.textContainer.lineBreakMode = .byWordWrapping
        return textView
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        let bigImage = UIImage(systemName: CommonUsage.SFSymbol.paperplaneFill, withConfiguration: config)
        button.setImage(bigImage, for: .normal)
        button.tintColor = UIColor(named: CommonUsage.scLightBlue)
        button.addTarget(self, action: #selector(dismissCommentViewController), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

}

// MARK: - conform to UITableViewDataSource

extension CommentViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fakeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.reuseIdentifier, for: indexPath) as? CommentTableViewCell else { return UITableViewCell()}
        cell.configCell(comment: fakeData[indexPath.row])
        return cell
    }
    
}

// MARK: - conform to UITableViewDelegate

extension CommentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        300
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: - UI method

extension CommentViewController {
    
    private func setViewbackgroundColor() {
        view.backgroundColor = UIColor(named: CommonUsage.scSuperLightBlue)
    }
    
    private func setCommentTitleLabel() {
        view.addSubview(commentTitleLabel)
        commentTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commentTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            commentTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8)
        ])
    }
    
    private func setDismissButton() {
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dismissButton.centerYAnchor.constraint(equalTo: commentTitleLabel.centerYAnchor)
        ])
    }
    
    private func setTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: commentTitleLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func setUserImage() {
        view.addSubview(currentUserImageView)
        currentUserImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentUserImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            currentUserImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            currentUserImageView.heightAnchor.constraint(equalToConstant: 50),
            currentUserImageView.widthAnchor.constraint(equalToConstant: 50)
            
        ])
    }
    
    private func setTextView() {
        view.addSubview(commentTextView)
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commentTextView.leadingAnchor.constraint(equalTo: currentUserImageView.trailingAnchor, constant: 8),
            commentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            commentTextView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            commentTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }
    
    private func setCommentPlaceHolder() {
        commentTextView.text = CommonUsage.Text.addComment
        commentTextView.textColor = UIColor(named: CommonUsage.scWhite)
    }
    
    private func addSendButton() {
        view.addSubview(sendButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sendButton.trailingAnchor.constraint(equalTo: commentTextView.trailingAnchor, constant: -4),
            sendButton.bottomAnchor.constraint(equalTo: commentTextView.bottomAnchor, constant: -4)
        ])
    }

}

// MARK: - confrom to UITextViewDelegate

extension CommentViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(named: CommonUsage.scWhite) {
            textView.text = nil
            textView.textColor = UIColor(named: CommonUsage.scBlue)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != nil, textView.text != "" {
            sendButton.isHidden = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text == "" {
            textView.text = CommonUsage.Text.addComment
            textView.textColor = UIColor(named: CommonUsage.scWhite)
            sendButton.isHidden = true
        }
    }
    
}
