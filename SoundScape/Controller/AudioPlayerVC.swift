//
//  AudioPlayerVC.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/19.
//

import UIKit

class AudioPlayerVC: UIViewController {
    
    // MARK: - properties
    
    weak var delegate: DetailPageShowableDelegate?
    
    var timer: Timer?
    
    let audioHelper = AudioPlayHelper.shared
    
    let remotePlayerHelper = RemotePlayHelper.shared
    
    private let audioURL = Bundle.main.url(forResource: "memories", withExtension: "mp3")
    
    private var dontShowDetailConstraint = NSLayoutConstraint()
    
    private var showDetailConstraint = NSLayoutConstraint()
    
    var soundDetailVC: SoundDetailVC?
    
    // MARK: - UI properties
    
    lazy var baseView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: CommonUsage.scGreen)
        return view
    }()
    
    private lazy var audioImage: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 10
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.image = UIImage(named: CommonUsage.audioImage)
        return image
    }()
    
    private lazy var audioTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: CommonUsage.font, size: 15)
        label.textAlignment = .left
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
        button.setImage(UIImage(systemName: CommonUsage.SFSymbol.heart), for: .normal)
        button.tintColor = .red
        //      button.addTarget(self, action: #selector(), for: .touchUpInside)
        return button
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: CommonUsage.SFSymbol.play), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(manipulatePlayer), for: .touchUpInside)
        return button
    }()
    
    private lazy var fullDurationView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var progressView: UIView = {
        let view = UIView()
        view.backgroundColor = .orange
        return view
    }()
    
    private lazy var detailButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(presentDetail), for: .touchUpInside)
        return button
    }()
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObserver()
        view.backgroundColor = UIColor(named: CommonUsage.scGreen)
        
        setupBaseVew()
        setAudioImage()
        setAudioTitle()
        setAuthorLabel()
        setPlayButton()
        setFavoriteButton()
        setFullDurationView()
        setProgressView()
        setDetailButton()
        addDetailPage()
    }
    
    
    // MARK: - init
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - method
    
    private func addDetailPage() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SoundDetailVC") as? SoundDetailVC else { return }
        
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
    
    // MARK: - UI method
    
    private func setupBaseVew() {
        view.addSubview(baseView)
        baseView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            baseView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            baseView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            baseView.topAnchor.constraint(equalTo: view.topAnchor),
            baseView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            //            baseView.heightAnchor.constraint(equalToConstant: 60),
            //            baseView.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -120)
        ])
    }
    
    private func setAudioImage() {
        baseView.addSubview(audioImage)
        audioImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            audioImage.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 8),
            audioImage.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 4),
            audioImage.widthAnchor.constraint(equalToConstant: 40),
            audioImage.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setAudioTitle() {
        baseView.addSubview(audioTitleLabel)
        audioTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            audioTitleLabel.leadingAnchor.constraint(equalTo: audioImage.trailingAnchor, constant: 20),
            audioTitleLabel.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 4)
        ])
    }
    
    private func setAuthorLabel() {
        baseView.addSubview(authorLabel)
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            authorLabel.leadingAnchor.constraint(equalTo: audioImage.trailingAnchor, constant: 20),
            authorLabel.topAnchor.constraint(equalTo: audioTitleLabel.bottomAnchor, constant: 4)
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
    
    private func setFakedata() {
        audioTitleLabel.text = "陽明山下七股溫泉"
        authorLabel.text = "Phillip Winter"
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
    
    // MARK: - action
    
    @objc func manipulatePlayer() {
        if remotePlayerHelper.state == .playing {
            remotePlayerHelper.pause()
        } else if remotePlayerHelper.state == .paused
                    || remotePlayerHelper.state == .loaded
                    || remotePlayerHelper.state == .buffering
                    || remotePlayerHelper.state == .stopped {
            remotePlayerHelper.play()
        }
    }
    
    @objc func updatePlaybackTime(notification: Notification) {
        //        localUpdatePlaybackTime()
        
        guard let playProgress = notification.userInfo?["UserInfo"] as? PlayProgress else { return }
        let currentTime = playProgress.currentTime
        let duration = playProgress.duration
        let timeProgress = currentTime / duration
        
        updateProgressWaveform(timeProgress)
        
    }
    
    @objc func presentDetail() {
        
        AudioPlayerWindow.shared.showDetailPage()
        
        guard let soundDetailVC = soundDetailVC else { return }
        
        dontShowDetailConstraint.isActive = false
        showDetailConstraint.isActive = true
        
        UIView.animate(withDuration: 0.9, delay: 0, options: .curveLinear) {
            soundDetailVC.view.isHidden = false
            self.view.layoutIfNeeded()
        }
        
        
    }
    
    @objc func updatePlayInfo(notification: Notification) {
        
        guard let nowPlayingInfo = notification.userInfo?["UserInfo"] as? PlayInfo else { return }
        audioTitleLabel.text = nowPlayingInfo.title
        authorLabel.text = nowPlayingInfo.author
        
    }
    
    // MARK: - method
    
    func addObserver() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updatePlayInfo),
                                               name: .playingAudioChange,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changeButtImage),
                                               name: .didStateChange,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updatePlaybackTime),
                                               name: .didCurrentTimeChange,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changeButtImage),
                                               name: .didItemPlayToEndTime,
                                               object: nil)
    }
    
    @objc func changeButtImage() {
        
        if remotePlayerHelper.state == .stopped
            || remotePlayerHelper.state == .buffering
            || remotePlayerHelper.state == .paused
            || remotePlayerHelper.state == .loaded {
            playButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.play), for: .normal)
        }
        
        if remotePlayerHelper.state == .playing {
            playButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.pause), for: .normal)
        }
        
    }
    
    func localManipulatePlayer() {
        if audioHelper.isPlaying == true {
            self.audioHelper.pause()
            playButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.play), for: .normal)
            if let timer = timer {
                timer.invalidate()
            }
        } else {
            audioHelper.play()
            playButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.pause), for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 0.1,
                                         target: self,
                                         selector: #selector(updatePlaybackTime),
                                         userInfo: nil,
                                         repeats: true)
        }
        
    }
    
    func localUpdatePlaybackTime() {
        print(audioHelper.currentTime)
        let progress = audioHelper.currentTime / audioHelper.duration
        updateProgressWaveform(progress)
    }
    
    func localUpdateUI() {
        timer = Timer.scheduledTimer(timeInterval: 0.1,
                                     target: self,
                                     selector: #selector(updatePlaybackTime),
                                     userInfo: nil,
                                     repeats: true)
        
        if audioHelper.isPlaying == true {
            playButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.pause), for: .normal)
        } else {
            playButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.play), for: .normal)
        }
        
    }
    
    private func setAudioHelper() {
        audioHelper.url = audioURL
    }
    
    private func updateProgressWaveform(_ progress: Double) {
        let fullRect = progressView.bounds
        let newWidth = Double(fullRect.size.width) * progress
        let maskLayer = CAShapeLayer()
        let maskRect = CGRect(x: 0.0, y: 0.0, width: newWidth, height: Double(fullRect.size.height))
        let path = CGPath(rect: maskRect, transform: nil)
        maskLayer.path = path
        progressView.layer.mask = maskLayer
    }
    
    func updateUI() {
        //        localUpdateUI()
        
        if remotePlayerHelper.state == .playing {
            playButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.pause), for: .normal)
        } else if remotePlayerHelper.state == .paused {
            playButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.play), for: .normal)
        }
    }
    
}

extension AudioPlayerVC: DetailPageShowableDelegate {
    
    func showDetailPage() {
        
        guard let soundDetailVC = soundDetailVC else { return }
        
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
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
            self.view.layoutIfNeeded()
        }
    }
    
}
