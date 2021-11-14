//
//  ProSoundDetailViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/14.
//

import UIKit
import DSWaveformImage

class ProSoundDetailViewController: UIViewController {
    
    // MARK: - UI properties
    
    // swiftlint:disable line_length
    
    private lazy var waveformView: WaveformImageView = {
        let safeAreaHeight = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 45.adjusted
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let sCTabBarController = storyboard.instantiateViewController(identifier: "SCTabBarController") as? SCTabBarController else { return WaveformImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0)) }
        let tabBarHeight = sCTabBarController.tabBar.frame.size.height
        let waveformViewY = CommonUsage.screenHeight - safeAreaHeight - tabBarHeight - 180
        let waveformView = WaveformImageView(frame: CGRect(x: 0, y: waveformViewY, width: CommonUsage.screenWidth, height: 100))
        return waveformView
    }()
    
    private lazy var waveformProgressView: WaveformImageView = {
        let safeAreaHeight = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 45.adjusted
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let sCTabBarController = storyboard.instantiateViewController(identifier: "SCTabBarController") as? SCTabBarController else { return WaveformImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0)) }
        let tabBarHeight = sCTabBarController.tabBar.frame.size.height
        let waveformViewY = CommonUsage.screenHeight - safeAreaHeight - tabBarHeight - 180
        let waveformView = WaveformImageView(frame: CGRect(x: 0, y: waveformViewY, width: CommonUsage.screenWidth, height: 100))
        return waveformView
    }()

    // swiftlint:enable line_length

    private lazy var playButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 32)
        let bigImage = UIImage(systemName: CommonUsage.SFSymbol.play, withConfiguration: config)
        button.setImage(bigImage, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(manipulatePlayer), for: .touchUpInside)
        return button
    }()

    private lazy var commentButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        let bigImage = UIImage(systemName: CommonUsage.SFSymbol.comment, withConfiguration: config)
        button.setImage(bigImage, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(presentCommentPage), for: .touchUpInside)
        return button
    }()
    
    private lazy var leaveButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        let bigImage = UIImage(systemName: CommonUsage.SFSymbol.chevronDown, withConfiguration: config)
        button.setImage(bigImage, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(leaveDetailPage), for: .touchUpInside)
        return button
    }()

    private lazy var authorButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(goAuthorPage), for: .touchUpInside)
        button.titleLabel?.font = UIFont(name: CommonUsage.fontBungee, size: 24)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scWhite)
        label.font = UIFont(name: CommonUsage.fontSemibold, size: 18)

        label.textAlignment = .left
        return label
    }()
    
    private lazy var contentTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .white
        textView.font = UIFont(name: CommonUsage.font, size: 14)
        textView.textAlignment = .left
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.isUserInteractionEnabled = true
        textView.textContainer.lineBreakMode = .byWordWrapping
        return textView
    }()
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var backgroundView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor(red: 24/255, green: 31/255, blue: 41/255, alpha: 0.7)

        return view
    }()
    
    // MARK: - properties
    
    private let waveformImageDrawer = WaveformImageDrawer()
    
    var audioHelper = AudioPlayHelper.shared
    
    var displayLink: CADisplayLink?
    
    var fileNameCount = 0
    
    weak var delegate: DetailPageShowableDelegate?
    
    let remotePlayerHelper = RemotePlayHelper.shared
    
    var authorIdentity: UserIdentity?
    
    var nowPlayingDocumentID: String?
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
        setBackgroundImage()
        setBackgroundView()
        setWaveformView()
        setWaveformProgressView()
        setAuthorButton()
        setTitleLabel()
        setTextView()
        setLeaveButton()
        setCommentButton()
        setPlayButton()
    }
    
    // MARK: - deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - action
    
    @objc func presentCommentPage(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let commentViewController = storyboard.instantiateViewController(withIdentifier: String(describing: CommentViewController.self)) as? CommentViewController else { return }
        commentViewController.currentPlayingDocumentID = nowPlayingDocumentID
        present(commentViewController, animated: true)
    }
    
    @objc func goAuthorPage() {
        
        guard let scTabBarController = UIApplication.shared.windows.filter({$0.rootViewController is SCTabBarController}).first?.rootViewController as? SCTabBarController else { return }
        
        scTabBarController.selectedIndex = 0
        
        guard let homeVC = scTabBarController.viewControllers?[0].children[0] as? HomeVC else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let othersProfileViewController = storyboard.instantiateViewController(withIdentifier: String(describing: OthersProfileViewController.self)) as? OthersProfileViewController,
              let authorIdentity = self.authorIdentity  else { return }
        
        othersProfileViewController.idWillDisplay = authorIdentity
        
        homeVC.navigationController?.pushViewController(othersProfileViewController, animated: true)
        
        guard let leave = delegate?.leaveDetailPage else { return }
        displayLink?.invalidate()
        
        AudioPlayerWindow.shared.makeSmallFrame()
        AudioPlayerWindow.shared.showVC()
        
        leave()
        
    }
    
    @objc func leaveDetailPage() {
        guard let leave = delegate?.leaveDetailPage else { return }
        displayLink?.invalidate()
        AudioPlayerWindow.shared.makeSmallFrame()
        AudioPlayerWindow.shared.showVC()

        leave()
    }

    @objc func manipulatePlayer() {
        
        if remotePlayerHelper.state == .playing {
            remotePlayerHelper.pause()
            let config = UIImage.SymbolConfiguration(pointSize: 32)
            let bigImage = UIImage(systemName: CommonUsage.SFSymbol.play, withConfiguration: config)
            playButton.setImage(bigImage, for: .normal)
        } else if remotePlayerHelper.state == .paused
                    || remotePlayerHelper.state == .loaded
                    || remotePlayerHelper.state == .buffering
                    || remotePlayerHelper.state == .stopped {
            remotePlayerHelper.play()
            let config = UIImage.SymbolConfiguration(pointSize: 32)
            let bigImage = UIImage(systemName: CommonUsage.SFSymbol.pause, withConfiguration: config)
            playButton.setImage(bigImage, for: .normal)
        }
        
    }
    
    // MARK: - method
    
    private func setWaveformView() {
        view.addSubview(waveformView)
    }
    
    private func setWaveformProgressView() {
        view.addSubview(waveformProgressView)
    }

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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(renderRemoteURLWave),
                                               name: .remoteURLDidSelect,
                                               object: nil)
        
    }
    
    @objc func renderRemoteURLWave(notification: Notification) {
        
        guard let remoteURL = notification.userInfo?["UserInfo"] as? URL else { return }
        
        let task = URLSession.shared.downloadTask(with: remoteURL) { downloadedURL, urlResponse, error in
            
            guard let downloadedURL = downloadedURL else { return }
            
            let cachesFolderURL = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            self.fileNameCount += 1
            
            let audioFileURL = cachesFolderURL?.appendingPathComponent("localFile\(self.fileNameCount).m4a")
            
            guard let localURL = audioFileURL else { return }
            
            try? FileManager.default.copyItem(at: downloadedURL, to: localURL)
            
            DispatchQueue.main.async {
                
                                self.updateWaveformImages(localURL: localURL)
                
                let waveformAnalyzer = WaveformAnalyzer(audioAssetURL: localURL)
                waveformAnalyzer?.samples(count: 10) { samples in
                    print("sampled down to 10, results are \(samples ?? [])")
                }
                
            }
        }
        task.resume()
    }
    
    @objc func updatePlaybackTime(notification: Notification) {
        //        localUpdatePlaybackTime()
        
        guard let playProgress = notification.userInfo?["UserInfo"] as? PlayProgress else { return }
        let currentTime = playProgress.currentTime
        let duration = playProgress.duration
        let timeProgress = currentTime / duration
        
                updateProgressWaveform(timeProgress)
        
    }
    
    @objc func changeButtImage() {
        
        if remotePlayerHelper.state == .stopped
            || remotePlayerHelper.state == .buffering
            || remotePlayerHelper.state == .paused
            || remotePlayerHelper.state == .loaded {
            let config = UIImage.SymbolConfiguration(pointSize: 32)
            let bigImage = UIImage(systemName: CommonUsage.SFSymbol.play, withConfiguration: config)
            playButton.setImage(bigImage, for: .normal)
        }
        
        if remotePlayerHelper.state == .playing {
            let config = UIImage.SymbolConfiguration(pointSize: 32)
            let bigImage = UIImage(systemName: CommonUsage.SFSymbol.pause, withConfiguration: config)
            playButton.setImage(bigImage, for: .normal)
        }
        
    }
    
    @objc func updatePlayInfo(notification: Notification) {
        guard let nowPlayingInfo = notification.userInfo?["UserInfo"] as? PlayInfo else { return }
        titleLabel.text = nowPlayingInfo.title
        backgroundImageView.image = CommonUsage.audioImages[nowPlayingInfo.audioImageNumber]
        authorButton.setTitle(nowPlayingInfo.author, for: .normal)
        contentTextView.text = nowPlayingInfo.content
        authorIdentity = UserIdentity(userID: nowPlayingInfo.authorUserID, userIDProvider: nowPlayingInfo.authorAccountProvider)
        nowPlayingDocumentID = nowPlayingInfo.documentID
        
    }
    
    private func updateWaveformImages(localURL: URL) {
        // always uses background thread rendering
        
        let waveformViewConfig = Waveform.Style.StripeConfig.init(color: UIColor(named: CommonUsage.scSuperLightBlue) ?? .green, width: 1.0, spacing: 1, lineCap: .round)
        waveformImageDrawer.waveformImage(fromAudioAt: localURL,
                                          with: Waveform.Configuration(size: self.waveformView.bounds.size,
                                                                       backgroundColor: .clear,
                                                                       style: .striped(waveformViewConfig) , dampening: nil,
                                                                       position: .middle,
                                                                       scale: 10.0,
                                                                       verticalScalingFactor: 0.5, shouldAntialias: true), completionHandler: { image in
            DispatchQueue.main.async {
                self.waveformView.image = image
            }
        })

        let waveformProgressViewConfig = Waveform.Style.StripeConfig.init(color: UIColor(named: CommonUsage.scWhite) ?? .orange, width: 1.0, spacing: 1, lineCap: .round)
        waveformImageDrawer.waveformImage(fromAudioAt: localURL,
                                          with: Waveform.Configuration(size: self.waveformView.bounds.size,
                                                                       backgroundColor: .clear,
                                                                       style: .striped(waveformProgressViewConfig), dampening: nil,
                                                                       position: .middle,
                                                                       scale: 10.0,
                                                                       verticalScalingFactor: 0.5, shouldAntialias: true), completionHandler: { image in
            DispatchQueue.main.async {
                self.waveformProgressView.image = image
            }
        })
    }
    
    private func updateProgressWaveform(_ progress: Double) {
        let fullRect = waveformProgressView.bounds
        let newWidth = Double(fullRect.size.width) * progress
        let maskLayer = CAShapeLayer()
        let maskRect = CGRect(x: 0.0, y: 0, width: newWidth, height: Double(fullRect.size.height))
        let path = CGPath(rect: maskRect, transform: nil)
        maskLayer.path = path
        waveformProgressView.layer.mask = maskLayer
    }

    func updateUI() {
        
        displayLink = CADisplayLink(target: self, selector: #selector(updatePlaybackTime))
        displayLink?.add(to: RunLoop.main, forMode: .common)
        
        if audioHelper.isPlaying == true {
            
            playButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.pause), for: .normal)
            
        } else {
            
            playButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.play), for: .normal)
        }
    }
    
}

extension ProSoundDetailViewController {
    
    private func setBackgroundImage() {
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setBackgroundView() {
        view.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setAuthorButton() {
        view.addSubview(authorButton)
        authorButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            authorButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            authorButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)
        ])
    }
    
    private func setTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel .topAnchor.constraint(equalTo: authorButton.bottomAnchor, constant: 16)
        ])
    }
    
    private func setTextView() {
        view.addSubview(contentTextView)
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            contentTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            contentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            contentTextView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
    
    private func setLeaveButton() {
        view.addSubview(leaveButton)
        leaveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leaveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            leaveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            leaveButton.widthAnchor.constraint(equalToConstant: 48),
            leaveButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func setCommentButton() {
        view.addSubview(commentButton)
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            commentButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32)
        ])
    }
    
    private func setPlayButton() {
        view.addSubview(playButton)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            playButton.bottomAnchor.constraint(equalTo: commentButton.topAnchor, constant: -16),
            playButton.widthAnchor.constraint(equalToConstant: 48),
            playButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

}