//
//  CommentViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/1.
//

import UIKit
import Lottie

class CommentViewController: UIViewController {
    
    let firebaseManager = FirebaseManager.shared
    
    let signInManager = SignInManager.shared
    
    var currentPlayingDocumentID: String? {
        didSet {
            guard let currentPlayingDocumentID = currentPlayingDocumentID else { return }
            checkComment(from: currentPlayingDocumentID)
        }
    }
    
    var comments = [SCComment]() {
        didSet {
            filterOutAuthors()
            filterComment()
        }
    }
    
    var commentsWillDisplay = [SCComment]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var newAuthorIDs = Set<String>() {
        didSet {
            for newAuthorId in newAuthorIDs {
                fetchUserPicFromFirebase(userID: newAuthorId)
//                firebaseManager.fetchUserPicFromFirebase(userID: newAuthorId) { [weak self] result in
//                    guard let self = self else { return }
//                    switch result {
//                    case .success(let picture):
//                        self.userPicCache[newAuthorId] = picture.picture
//                    case .failure(let error):
//                        print("Failed to fetch \(newAuthorId)'s picString \(error)")
//                    }
//                }
            }
        }
    }
    
    
    var authorsIDSet = Set<String>() {
        didSet {
            if authorsIDSet != oldValue {
                newAuthorIDs = authorsIDSet.subtracting(oldValue)
            }
        }
    }
    
    // userID: picString
    var userPicCache: [String: String] = [:] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var currentUserBlacklist: [SCBlockUser]? {
        didSet {
            filterComment()
        }
    }
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
        fetchBlacklist()
        setViewbackgroundColor()
        setCommentTitleLabel()
        setDismissButton()
        setTableView()
        setUserImage()
        setTextView()
        setCommentPlaceHolder()
        addSendButton()
        filterOutAuthors()
    }
    
    override func viewDidLayoutSubviews() {
        currentUserImageView.layer.cornerRadius = currentUserImageView.frame.width / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let currentUserPic = signInManager.currentUserPic,
              let data = Data(base64Encoded: currentUserPic) else { return }
        currentUserImageView.image = UIImage(data: data)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - method
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(currentUserBlacklistChange),
                                               name: .currentUserBlacklistChange ,
                                               object: nil)
    }
    
    @objc func currentUserBlacklistChange() {
        fetchBlacklist()
    }
    
    private func fetchBlacklist() {
        currentUserBlacklist = signInManager.currentUserBlacklist
    }
    
    private func filterOutAuthors() {
        let authors = comments.map({$0.userID})
        authorsIDSet = Set(authors)
    }
    
    private func filterComment() {
        if let currentUserBlacklist = currentUserBlacklist {
            
            let blockedIDs = currentUserBlacklist.map({$0.userID})
            var shouldDisplayComments = [SCComment]()
            
            for id in blockedIDs {
                let shouldDisplayComment = comments.filter({$0.userID != id })
                shouldDisplayComments.append(contentsOf: shouldDisplayComment)
            }
            
            commentsWillDisplay = shouldDisplayComments
            
        } else {
            
            commentsWillDisplay = comments
        }
    }
    
    private func checkComment(from documentID: String) {
        
        _ = firebaseManager.collectionAddListener(collectionType: .comments(audioDocumentID: documentID)) { (result: Result<[SCComment], Error>) in
            switch result {
                
            case .success(let comments):
                self.comments = comments
                
            case .failure(let error):
                print("Failed to fetch comments \(error)")
            }
        }
    }
    
    @objc private func done() {
        commentTextView.endEditing(true)
    }
    
    @objc private func addComment() {
        
        let checkMessage = commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if commentTextView.text != nil,
           checkMessage != "" {
            addCommentToFirebase()
        } else {
            popBlankCommentAlert()
        }
    }
    
    @objc func dismissCommentViewController() {
        dismiss(animated: true)
    }
    
    // MARK: - method
    
    private func popBlankCommentAlert() {
        popErrorAlert(title: "Yoy have a blank commet.", message: "Please type something to leave your comment.")
    }
    
    private func addCommentCompletion() {
        commentTextView.text = nil
        commentTextView.endEditing(true)
        animationView.removeFromSuperview()
    }
    
    private func addCommentToFirebase() {
        addLottie()
        
        guard let currentPlayingDocumentID = currentPlayingDocumentID,
              commentTextView.text != "",
              let comment = commentTextView.text,
              let currentUserInfo = signInManager.currentUserInfoFirebase else {
                  print("CommentVC: Add Comment Return.")
                  animationView.removeFromSuperview()
                  return }
        
        let commentData = SCComment(commentDocumentID: nil,
                                    userID: currentUserInfo.userID,
                                    userName: currentUserInfo.username,
                                    userImage: nil,
                                    createdTime: nil,
                                    lastEditedTime: nil,
                                    comment: comment)
        
        firebaseManager.addComment(to: currentPlayingDocumentID,
                                   with: commentData,
                                   completion: addCommentCompletion) { [weak self] errorMessage in
            guard let self = self else { return }
            self.popErrorAlert(title: "Failed to add comment", message: errorMessage)
        }
    }
    
    private func blockThisUser(toBeBlockedID: String) {
        
        guard let currentUserDocID = signInManager.currentUserInfoFirebase?.userInfoDoumentID else { return }
        
        firebaseManager.addToBlackList(loggedInUserInfoDocumentID: currentUserDocID,
                                       toBeBlockedID: toBeBlockedID, completion: nil)
    }
    
    private func popBlockAlert(toBeBlockedID: String) {
        
        let alert = UIAlertController(title: "Are you sure?",
                                      message: "You can't see this user's comments, audio posts and profile page after blocking. And you have no chance to unblock this user in the future",
                                      preferredStyle: .alert )
        
        let okButton = UIAlertAction(title: "Block", style: .destructive) {[weak self] _ in
            guard let self = self else { return }
            self.blockThisUser(toBeBlockedID: toBeBlockedID)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(cancelButton)
        alert.addAction(okButton)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func popDeleteCommentAlert(commentID: String) {
        
        let alert = UIAlertController(title: "Are you sure to delete this comment?",
                                      message: nil,
                                      preferredStyle: .alert )
        
        let okButton = UIAlertAction(title: "Delete", style: .destructive) {[weak self] _ in
            guard let self = self else { return }
            self.deleteComment(commentID: commentID)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(cancelButton)
        alert.addAction(okButton)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func deleteComment(commentID: String) {
        guard let audioDocumentID = currentPlayingDocumentID else { return }
        firebaseManager.deleteComment(audioDocumentID: audioDocumentID,
                                      commentDocumentID: commentID) { [weak self] errorMessage in
            guard let self = self else { return }
            self.popErrorAlert(title: "Failed to delete comment", message: errorMessage)
        } successedCompletion: {
            SPAlertWrapper.shared.presentSPAlert(title: "Comment deleted!",
                                                 message: nil,
                                                 preset: .done,
                                                 completion: nil)
        }
    }
    
    private func fetchUserPicFromFirebase(userID: String) {
        firebaseManager.documentFetchData(documentType:
                                                .userPicDoc(userInfoDocumentID: userID)) { (result:
                                                                                                Result<SCPicture, Error>) in
            switch result {
            case .success(let picture):
                self.userPicCache[userID] = picture.picture
            case .failure(let error):
                print("Failed to fetch \(userID)'s picString \(error)")
            }
        }
    }
    
    // MARK: - UI properties
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.allowsSelection = false
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.backgroundColor = UIColor(named: CommonUsage.scBlue)
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
        image.layer.masksToBounds = true
        image.image = UIImage(named: CommonUsage.yeh1024)
        image.contentMode = .scaleAspectFill
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
        textView.textContainer.maximumNumberOfLines = 8
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.addDoneOnKeyboardWithTarget(self, action: #selector(done))
        return textView
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        let bigImage = UIImage(systemName: CommonUsage.SFSymbol.paperplaneFill, withConfiguration: config)
        button.setImage(bigImage, for: .normal)
        button.tintColor = UIColor(named: CommonUsage.scSuperLightBlue)
        button.addTarget(self, action: #selector(addComment), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var animationView: AnimationView = {
        let animationView = AnimationView(name: "lf30_editor_r2yecdir")
        animationView.frame = CGRect(x: 0, y: 100, width: 400, height: 400)
        animationView.center = view.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        return animationView
    }()
    
    private lazy var emptyTextViewConstraint = NSLayoutConstraint()
    private lazy var fullTextViewConstraint = NSLayoutConstraint()
    
}

// MARK: - conform to UITableViewDataSource

extension CommentViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        commentsWillDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.reuseIdentifier, for: indexPath) as? CommentTableViewCell else { return UITableViewCell()}
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
    
    private func setViewbackgroundColor() {
        view.backgroundColor = UIColor(named: CommonUsage.scLightBlue)
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
            currentUserImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            currentUserImageView.heightAnchor.constraint(equalToConstant: 50),
            currentUserImageView.widthAnchor.constraint(equalToConstant: 50)
            
        ])
    }
    
    private func setTextView() {
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
    
    private func setCommentPlaceHolder() {
        commentTextView.text = CommonUsage.Text.addComment
        commentTextView.textColor = UIColor(named: CommonUsage.scWhite)
    }
    
    private func addSendButton() {
        view.addSubview(sendButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sendButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),
            sendButton.bottomAnchor.constraint(equalTo: commentTextView.bottomAnchor, constant: -4)
        ])
    }
    
    private func addLottie() {
        view.addSubview(animationView)
        animationView.play()
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
            emptyTextViewConstraint.isActive = false
            fullTextViewConstraint = commentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
            fullTextViewConstraint.isActive = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text == "" {
            textView.text = CommonUsage.Text.addComment
            textView.textColor = UIColor(named: CommonUsage.scWhite)
            sendButton.isHidden = true
            fullTextViewConstraint.isActive = false
            emptyTextViewConstraint.isActive = true
            view.layoutIfNeeded()
        }
    }
    
}
