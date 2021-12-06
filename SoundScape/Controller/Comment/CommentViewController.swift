//
//  CommentViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/1.
//

import UIKit

class CommentViewController: UIViewController {
    
    let firebaseManager = FirebaseManager.shared
    
    let signInManager = LoggedInUserManager.shared
    
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
        // swiftlint:disable line_length
        _ = firebaseManager.collectionAddListener(collectionType: .comments(audioDocumentID: documentID)) { (result: Result<[SCComment], Error>) in
            switch result {
                
            case .success(let comments):
                self.comments = comments
                
            case .failure(let error):
                print("Failed to fetch comments \(error)")
            }
        }
    }
    // swiftlint:enable line_length
    
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
    
    func popBlankCommentAlert() {
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
    
    func popBlockAlert(toBeBlockedID: String) {
        // swiftlint:disable line_length
        let alert = UIAlertController(title: "Are you sure?",
                                      message: "You can't see this user's comments, audio posts and profile page after blocking. And you have no chance to unblock this user in the future",
                                      preferredStyle: .alert )
        // swiftlint:enable line_length
        
        let okButton = UIAlertAction(title: "Block", style: .destructive) {[weak self] _ in
            guard let self = self else { return }
            self.blockThisUser(toBeBlockedID: toBeBlockedID)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(cancelButton)
        alert.addAction(okButton)
        
        present(alert, animated: true, completion: nil)
    }
    
    func popDeleteCommentAlert(commentID: String) {
        
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
        // swiftlint:disable line_length
        firebaseManager.documentFetchData(documentType: .userPicDoc(userInfoDocumentID: userID)) { (result: Result<SCPicture, Error>) in
            switch result {
            case .success(let picture):
                self.userPicCache[userID] = picture.picture
            case .failure(let error):
                print("Failed to fetch \(userID)'s picString \(error)")
            }
        }
    }
    // swiftlint:enable line_length
    
    // MARK: - UI properties
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.allowsSelection = false
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.backgroundColor = UIColor(named: Constant.scBlue)
        table.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.reuseIdentifier)
        return table
    }()
    
    lazy var commentTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: Constant.scWhite)
        label.textAlignment = .center
        label.font = UIFont(name: Constant.font, size: 24)
        label.numberOfLines = 0
        label.text = Constant.Text.comments
        label.backgroundColor = .clear
        return label
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        let bigImage = UIImage(systemName: Constant.SFSymbol.chevronDown, withConfiguration: config)
        button.setImage(bigImage, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(dismissCommentViewController), for: .touchUpInside)
        return button
    }()
    
    lazy var currentUserImageView: UIImageView = {
        let image = UIImageView()
        image.layer.masksToBounds = true
        image.image = UIImage(named: Constant.yeh1024)
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    lazy var commentTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .white
        textView.font = UIFont(name: Constant.font, size: 15)
        textView.textAlignment = .left
        textView.isEditable = true
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor(named: Constant.scGray)
        textView.layer.cornerRadius = 10
        textView.delegate = self
        textView.textContainer.maximumNumberOfLines = 8
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.addDoneOnKeyboardWithTarget(self, action: #selector(done))
        return textView
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        let bigImage = UIImage(systemName: Constant.SFSymbol.paperplaneFill, withConfiguration: config)
        button.setImage(bigImage, for: .normal)
        button.tintColor = UIColor(named: Constant.scSuperLightBlue)
        button.addTarget(self, action: #selector(addComment), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    let animationView = LottieWrapper.shared.createLottieAnimationView(lottieType: .commentLoading,
                                                                       frame: CGRect(x: 0,
                                                                                     y: 100,
                                                                                     width: 400,
                                                                                     height: 400))
    lazy var emptyTextViewConstraint = NSLayoutConstraint()
    lazy var fullTextViewConstraint = NSLayoutConstraint()
    
}
