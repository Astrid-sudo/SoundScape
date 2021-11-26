//
//  AudioPlayerVC.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/19.
//

import UIKit

class AudioPlayerVC: UIViewController {
    
    // MARK: - properties
    
    private let signInManager = SignInManager.shared
    
    private let firebaseManager = FirebaseManager.shared
    
    weak var delegate: DetailPageShowableDelegate?
    
    private var nowPlayDocumentID: String?
    
    private var currentUserFavoriteDocumentIDs: [String]?
    
    var nowPlayingURL: URL?
    
    private let audioURL = Bundle.main.url(forResource: "memories", withExtension: "mp3")
    
    private var dontShowDetailConstraint = NSLayoutConstraint()
    
    private var showDetailConstraint = NSLayoutConstraint()
    
    private var soundDetailVC: SoundDetailViewController?
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserFavoriteList()
        addObserver()
        setviewBackgroundcolor()
        setupBaseVew()
        setAudioImage()
        setAudioTitle()
        setAuthorLabel()
        setPlayButton()
        setIndicatorView()
        setFavoriteButton()
        setFullDurationView()
        setProgressView()
        setDetailButton()
        addDetailPage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - init
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - method
    
    private func fetchUserFavoriteList() {
        guard let userProfileDocumentID = signInManager.currentUserInfoFirebase?.userInfoDoumentID else {
            print("AudioPlayerVC: Cant get favorite before login")
            return
        }
        
        firebaseManager.checkFavoriteChange(userProfileDocumentID: userProfileDocumentID) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let scFavorites):
                self.currentUserFavoriteDocumentIDs = scFavorites.map({$0.favoriteDocumentID})
                
            case .failure(let error):
                print("AudioPlayerVC: Failed to get favoriteDocumentID \(error)")
                
            }
        }
    }
    
    private func addDetailPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SoundDetailViewController") as? SoundDetailViewController else { return }
        
        self.soundDetailVC = vc
        guard let soundDetailVC = soundDetailVC else { return }
        soundDetailVC.delegate = self
        
        view.addSubview(soundDetailVC.view)
        soundDetailVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        dontShowDetailConstraint = soundDetailVC.view.topAnchor.constraint(equalTo: view.bottomAnchor)
        showDetailConstraint = soundDetailVC.view.topAnchor.constraint(equalTo: view.topAnchor)
        
        NSLayoutConstraint.activate([
            soundDetailVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            soundDetailVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            soundDetailVC.view.heightAnchor.constraint(equalToConstant: CommonUsage.screenHeight),
            dontShowDetailConstraint
        ])
        
        soundDetailVC.view.isHidden = true
    }
    
    private func fillFavoriteButton() {
        favoriteButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.heart), for: .normal)
        favoriteButton.tintColor = UIColor(named: CommonUsage.scYellow)
    }
    
    private func emptyFavoriteButton() {
        favoriteButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.heartEmpty), for: .normal)
        favoriteButton.tintColor = UIColor(named: CommonUsage.scYellow)
    }
    
    // MARK: - action
    
    @objc func manipulateFavorite() {
        guard let userProfileDocumentID = signInManager.currentUserInfoFirebase?.userInfoDoumentID else {
            print("Cant addToFavorite before loggin")
            return
        }
        
        guard let nowPlayDocumentID = nowPlayDocumentID else {
            return
        }
        
        firebaseManager.manipulateFavorite(userProfileDocumentID: userProfileDocumentID,
                                           documendID: nowPlayDocumentID,
                                           addCompletion: fillFavoriteButton,
                                           removeCompletion: emptyFavoriteButton) { [weak self] errorMessage in
            guard let self = self else { return }
            self.popErrorAlert(title: "Failed to add or remove favorite", message: errorMessage)
            
        }
    }
    
    @objc func playOrPause() {
        togglePlayer()
    }
    
    @objc func updatePlayTime(notification: Notification) {
        updatePlaybackTime(notification: notification)
    }
    
    @objc func presentDetail() {
        AudioPlayerWindow.shared.showDetailPage()
        
        guard let soundDetailVC = soundDetailVC else { return }
        soundDetailVC.view.alpha = 1
        
        dontShowDetailConstraint.isActive = false
        showDetailConstraint.isActive = true
        
        UIView.animate(withDuration: 0.9, delay: 0, options: .curveLinear) {
            soundDetailVC.view.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func updateInfo(notification: Notification) {
        updatePlayInfo(notification: notification)
    }
    
    @objc func audioPlayHelperError() {
        popErrorAlert(title: "Audio player error",
                      message: "Please terminate SoundScape_ and try again.")
    }
    
    @objc func changeButtImage() {
        changeButtonImage()
    }
    
    // MARK: - method
    
    private func manipulateFavoriteImage() {
        
        guard let currentUserFavoriteDocumentIDs = currentUserFavoriteDocumentIDs,
              let nowPlayDocumentID = nowPlayDocumentID else {
                  print("AudioPlayerVC: Cant get currentUserFavoriteDocumentIDs and nowPlayDocumentID  ")
                  return
              }
        
        if currentUserFavoriteDocumentIDs.contains(nowPlayDocumentID) {
            fillFavoriteButton()
        } else {
            emptyFavoriteButton()
        }
    }
    
    private func addObserver() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateInfo),
                                               name: .playingAudioChange,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changeButtImage),
                                               name: .didStateChange,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updatePlayTime),
                                               name: .didCurrentTimeChange,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changeButtImage),
                                               name: .didItemPlayToEndTime,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioPlayHelperError),
                                               name: .audioPlayHelperError,
                                               object: nil)
    }
    
    private func setAudioHelper() {
        audioPlayHelper.url = audioURL
    }
    
    func resetAudioPlayerUI(audioTitle: String, audioImageNumber: Int) {
        audioTitleLabel.text = audioTitle
        authorLabel.text = CommonUsage.Text.loading
        updateProgressWaveform(0)
        indicatorView.startAnimating()
        indicatorView.isHidden = false
        playButton.isHidden = true
        audioImage.image = CommonUsage.audioImages[audioImageNumber]
    }
    
    // MARK: - UI properties
    
    private lazy var baseView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: CommonUsage.scLightBlue)
        return view
    }()
    
    private lazy var audioImage: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 10
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.image = UIImage(named: CommonUsage.launchScreen1)
        return image
    }()
    
    private lazy var audioTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: CommonUsage.font, size: 15)
        label.textAlignment = .left
        label.text = CommonUsage.Text.loading
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: CommonUsage.font, size: 12)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: CommonUsage.SFSymbol.heartEmpty), for: .normal)
        button.tintColor = UIColor(named: CommonUsage.scYellow)
        button.addTarget(self, action: #selector(manipulateFavorite), for: .touchUpInside)
        return button
    }()
    
    private lazy var fullDurationView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var detailButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(presentDetail), for: .touchUpInside)
        return button
    }()
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium )
        view.color = UIColor(named: CommonUsage.scWhite)
        view.hidesWhenStopped = true
        view.isHidden = true
        return view
    }()
    
    // MARK: - AudioPlayerProtocol
    
    lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(playButtonImagePlay, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(playOrPause), for: .touchUpInside)
        return button
    }()
    
    lazy var progressView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: CommonUsage.scOrange)
        return view
    }()
    
    var caDisplayLink: CADisplayLink?
    
}

extension AudioPlayerVC: AudioPlayerProtocol {
    
    func updatePlayInfo(notification: Notification) {
        guard let nowPlayingInfo = notification.userInfo?["UserInfo"] as? PlayInfo else { return }
        DispatchQueue.main.async {
            self.audioTitleLabel.text = nowPlayingInfo.title
            self.authorLabel.text = nowPlayingInfo.author
            self.nowPlayDocumentID = nowPlayingInfo.documentID
            self.audioImage.image = CommonUsage.audioImages[nowPlayingInfo.audioImageNumber]
            self.manipulateFavoriteImage()
            self.indicatorView.stopAnimating()
            self.playButton.isHidden = false
            self.updateProgressWaveform(0)
        }
    }
    
}

// MARK: - conform to DetailPageShowableDelegate

extension AudioPlayerVC: DetailPageShowableDelegate {
    
    func showDetailPage() {
        guard let soundDetailVC = soundDetailVC else { return }
        soundDetailVC.view.alpha = 1
        
        dontShowDetailConstraint.isActive = false
        showDetailConstraint.isActive = true
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
            soundDetailVC.view.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
    
    func leaveDetailPage() {
        showDetailConstraint.isActive = false
        dontShowDetailConstraint.isActive = true
        guard let soundDetailVC = soundDetailVC else { return }
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
            soundDetailVC.view.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
}

// MARK: - config UI method

extension AudioPlayerVC {
    
    private func setviewBackgroundcolor() {
        view.backgroundColor = UIColor(named: CommonUsage.scGreen)
    }
    
    private func setupBaseVew() {
        view.addSubview(baseView)
        baseView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            baseView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            baseView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            baseView.topAnchor.constraint(equalTo: view.topAnchor),
            baseView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setAudioImage() {
        baseView.addSubview(audioImage)
        audioImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            audioImage.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 8),
            audioImage.centerYAnchor.constraint(equalTo: baseView.centerYAnchor, constant: -5),
            audioImage.widthAnchor.constraint(equalToConstant: 40.adjusted),
            audioImage.heightAnchor.constraint(equalToConstant: 40.adjusted)
        ])
    }
    
    private func setAudioTitle() {
        baseView.addSubview(audioTitleLabel)
        audioTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            audioTitleLabel.leadingAnchor.constraint(equalTo: audioImage.trailingAnchor, constant: 20),
            audioTitleLabel.bottomAnchor.constraint(equalTo: audioImage.centerYAnchor)
        ])
    }
    
    private func setAuthorLabel() {
        baseView.addSubview(authorLabel)
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            authorLabel.leadingAnchor.constraint(equalTo: audioImage.trailingAnchor, constant: 20),
            authorLabel.topAnchor.constraint(equalTo: audioImage.centerYAnchor)
        ])
    }
    
    private func setPlayButton() {
        baseView.addSubview(playButton)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playButton.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -16),
            playButton.centerYAnchor.constraint(equalTo: audioImage.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 50),
            playButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setIndicatorView() {
        baseView.addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -16),
            indicatorView.centerYAnchor.constraint(equalTo: audioImage.centerYAnchor),
            indicatorView.widthAnchor.constraint(equalToConstant: 50),
            indicatorView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setFavoriteButton() {
        baseView.addSubview(favoriteButton)
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            favoriteButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -8),
            favoriteButton.centerYAnchor.constraint(equalTo: audioImage.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 30),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setFullDurationView() {
        baseView.addSubview(fullDurationView)
        fullDurationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fullDurationView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
            fullDurationView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
            fullDurationView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -6),
            fullDurationView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    private func setProgressView() {
        baseView.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -6),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    private func setDetailButton() {
        baseView.addSubview(detailButton)
        detailButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detailButton.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
            detailButton.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor),
            detailButton.topAnchor.constraint(equalTo: baseView.topAnchor),
            detailButton.bottomAnchor.constraint(equalTo: baseView.bottomAnchor)
        ])
    }
    
}
