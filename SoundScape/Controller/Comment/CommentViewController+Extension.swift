//
//  CommentViewController+Extension.swift
//  SoundScape
//
//  Created by Astrid on 2021/12/6.
//

import UIKit

// MARK: - conform to UITableViewDataSource

extension CommentViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        commentsWillDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable line_length
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.reuseIdentifier, for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
        // swiftlint:enable line_length
        
        let comment = commentsWillDisplay[indexPath.row]
        let authorID = comment.userID
        var authorImageString: String?
        
        if let authorPic = userPicCache[authorID] {
            authorImageString = authorPic
        }
        
        cell.configCell(comment: comment, authorImageString: authorImageString)
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
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        
        let comment = commentsWillDisplay[indexPath.row]
        let authorID = comment.userID
        let index = indexPath.row
        let identifier = "\(index)" as NSString
        
        if authorID != signInManager.currentUserInfoFirebase?.userID {
            
            return UIContextMenuConfiguration(
                identifier: identifier, previewProvider: nil) { _ in
                    // 3
                    let blockAction = UIAction(title: "Block this user",
                                               image: nil) { _ in
                        self.popBlockAlert(toBeBlockedID: authorID)
                    }
                    return UIMenu(title: "",
                                  image: nil,
                                  children: [blockAction])
                }
            
        } else {
            
            guard let commentID = comment.commentDocumentID else { return nil}
            
            return UIContextMenuConfiguration(
                identifier: identifier, previewProvider: nil) { _ in
                    // 3
                    let deleteAction = UIAction(title: "Delete this comment",
                                                image: nil) { _ in
                        self.popDeleteCommentAlert(commentID: commentID)
                    }
                    return UIMenu(title: "",
                                  image: nil,
                                  children: [deleteAction])
                }
        }
    }
    
}

// MARK: - UI method

extension CommentViewController {
    
    func setViewbackgroundColor() {
        view.backgroundColor = UIColor(named: Constant.scLightBlue)
    }
    
    func setCommentTitleLabel() {
        view.addSubview(commentTitleLabel)
        commentTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commentTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            commentTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8)
        ])
    }
    
    func setDismissButton() {
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dismissButton.centerYAnchor.constraint(equalTo: commentTitleLabel.centerYAnchor)
        ])
    }
    
    func setTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: commentTitleLabel.bottomAnchor, constant: 8)
        ])
    }
    
    func setUserImage() {
        view.addSubview(currentUserImageView)
        currentUserImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentUserImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            currentUserImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            currentUserImageView.heightAnchor.constraint(equalToConstant: 50),
            currentUserImageView.widthAnchor.constraint(equalToConstant: 50)
            
        ])
    }
    
    func setTextView() {
        view.addSubview(commentTextView)
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        emptyTextViewConstraint = commentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        
        NSLayoutConstraint.activate([
            commentTextView.leadingAnchor.constraint(equalTo: currentUserImageView.trailingAnchor, constant: 8),
            emptyTextViewConstraint,
            commentTextView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            commentTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    func setCommentPlaceHolder() {
        commentTextView.text = Constant.Text.addComment
        commentTextView.textColor = UIColor(named: Constant.scWhite)
    }
    
    func addSendButton() {
        view.addSubview(sendButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sendButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),
            sendButton.bottomAnchor.constraint(equalTo: commentTextView.bottomAnchor, constant: -4)
        ])
    }
    
    func addLottie() {
        view.addSubview(animationView)
        animationView.play()
    }
    
}

// MARK: - confrom to UITextViewDelegate

extension CommentViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(named: Constant.scWhite) {
            textView.text = nil
            textView.textColor = UIColor(named: Constant.scBlue)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != nil, textView.text != "" {
            sendButton.isHidden = false
            emptyTextViewConstraint.isActive = false
            // swiftlint:disable line_length
            fullTextViewConstraint = commentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
            // swiftlint:enable line_length
            fullTextViewConstraint.isActive = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text == "" {
            textView.text = Constant.Text.addComment
            textView.textColor = UIColor(named: Constant.scWhite)
            sendButton.isHidden = true
            fullTextViewConstraint.isActive = false
            emptyTextViewConstraint.isActive = true
            view.layoutIfNeeded()
        }
    }
    
}
