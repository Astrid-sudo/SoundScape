//
//  ViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/18.
//

import UIKit
import DSWaveformImage

class SoundDetailVC: UIViewController {
    
    // MARK: - UI properties
    
    @IBOutlet weak var waveformView: WaveformImageView!
    
    @IBOutlet weak var waveformProgressView: WaveformImageView!
    
    @IBOutlet weak var playButton: UIButton!
    
    private lazy var playButtonC: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        let bigImage = UIImage(systemName: CommonUsage.SFSymbol.play, withConfiguration: config)
        button.setImage(bigImage, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(manipulatePlayer), for: .touchUpInside)
        return button
    }()
    
    @IBOutlet weak var authorButton: UIButton!
    
    private lazy var authorButtonC: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.addTarget(self, action: #selector(goAuthorPage), for: .touchUpInside)
        return button
    }()

    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    private lazy var titleLabelc: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scWhite)
        label.textAlignment = .left
        return label
    }()

    
    @IBOutlet weak var contentTextView: UITextView!
    
    private lazy var contentTextViewc: UITextView = {
        let textView = UITextView()
        textView.textColor = .white
        textView.font = UIFont(name: CommonUsage.font, size: 15)
        textView.textAlignment = .left
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
//        textView.layer.cornerRadius = 10
//        textView.delegate = self
        textView.textContainer.maximumNumberOfLines = 8
        textView.textContainer.lineBreakMode = .byWordWrapping
        return textView
    }()

    
    private lazy var backgroundImageView: UIImageView = {
       let imageView = UIImageView()
        return imageView
    }()
   
    // MARK: - properties
    
    private let waveformImageDrawer = WaveformImageDrawer()
    
    private let audioURL = Bundle.main.url(forResource: "memories", withExtension: "mp3")
    
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
        setAudioHelper()
        waveformView.isHidden = true
        waveformProgressView.isHidden = true
    }
    
    // MARK: - deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - action
    
    @IBAction func presentCommentPage(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let commentViewController = storyboard.instantiateViewController(withIdentifier: String(describing: CommentViewController.self)) as? CommentViewController else { return }
        commentViewController.currentPlayingDocumentID = nowPlayingDocumentID
        present(commentViewController, animated: true)
    }
    
    @IBAction func goAuthorProfile(_ sender: UIButton) {
        
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
    
    @IBAction func leaveDetailPage(_ sender: UIButton) {
        guard let leave = delegate?.leaveDetailPage else { return }
        displayLink?.invalidate()
        AudioPlayerWindow.shared.makeSmallFrame()
        AudioPlayerWindow.shared.showVC()

        leave()
    }
    
    @IBAction func playAudio(_ sender: UIButton) {
        
        if remotePlayerHelper.state == .playing {
            remotePlayerHelper.pause()
            playButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.play), for: .normal)
        } else if remotePlayerHelper.state == .paused
                    || remotePlayerHelper.state == .loaded
                    || remotePlayerHelper.state == .buffering
                    || remotePlayerHelper.state == .stopped {
            remotePlayerHelper.play()
            playButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.pause), for: .normal)
        }
        
    }
    
    @objc func manipulatePlayer() {
        
        if remotePlayerHelper.state == .playing {
            remotePlayerHelper.pause()
            playButtonC.setImage(UIImage(systemName: CommonUsage.SFSymbol.play), for: .normal)
        } else if remotePlayerHelper.state == .paused
                    || remotePlayerHelper.state == .loaded
                    || remotePlayerHelper.state == .buffering
                    || remotePlayerHelper.state == .stopped {
            remotePlayerHelper.play()
            playButtonC.setImage(UIImage(systemName: CommonUsage.SFSymbol.pause), for: .normal)
        }
        
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
            
            let audioFileURL = cachesFolderURL?.appendingPathComponent("\(remoteURL).m4a")
            
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
            playButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.play), for: .normal)
        }
        
        if remotePlayerHelper.state == .playing {
            playButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.pause), for: .normal)
        }
        
    }
    
    @objc func updatePlayInfo(notification: Notification) {
        guard let nowPlayingInfo = notification.userInfo?["UserInfo"] as? PlayInfo else { return }
        titleLabel.text = nowPlayingInfo.title
        titleLabelc.text = nowPlayingInfo.title

//        authorLabel.text = nowPlayingInfo.author
        backgroundImageView.image = CommonUsage.audioImages[nowPlayingInfo.audioImageNumber]
        authorButton.setTitle(nowPlayingInfo.author, for: .normal)
        authorButtonC.setTitle(nowPlayingInfo.author, for: .normal)
        contentTextView.text = nowPlayingInfo.content
        authorIdentity = UserIdentity(userID: nowPlayingInfo.authorUserID, userIDProvider: nowPlayingInfo.authorAccountProvider)
        nowPlayingDocumentID = nowPlayingInfo.documentID
        
    }
    
    private func updateWaveformImages(localURL: URL) {
        // always uses background thread rendering
        
        let waveformViewConfig = Waveform.Style.StripeConfig.init(color: UIColor(named: CommonUsage.scLightGreen) ?? .green, width: 3.0, spacing: 3.5 , lineCap: .butt)

        waveformImageDrawer.waveformImage(fromAudioAt: localURL,
                                          with: Waveform.Configuration(size: self.waveformView.bounds.size,
                                                                       backgroundColor: .white,
                                                                       style: .striped(waveformViewConfig) , dampening: nil,
                                                                       position: .middle,
                                                                       scale: 10.0 , verticalScalingFactor: 0.5, shouldAntialias: true), completionHandler: { image in
            DispatchQueue.main.async {
                self.waveformView.image = image
            }
        })

        let waveformProgressViewConfig = Waveform.Style.StripeConfig.init(color: UIColor(named: CommonUsage.scOrange) ?? .orange, width: 3.0, spacing: 3.5, lineCap: .butt)

        waveformImageDrawer.waveformImage(fromAudioAt: localURL,
                                          with: Waveform.Configuration(size: self.waveformView.bounds.size,
                                                                       backgroundColor: .white,
                                                                       style: .striped(waveformViewConfig) , dampening: nil,
                                                                       position: .middle,
                                                                       scale: 10.0 , verticalScalingFactor: 0.5, shouldAntialias: true), completionHandler: { image in
            DispatchQueue.main.async {
                self.waveformProgressView.image = image
            }
        })

    }
    
    private func updateProgressWaveform(_ progress: Double) {
        
        let fullRect = waveformProgressView.bounds
        let newWidth = Double(fullRect.size.width) * progress
        
        let maskLayer = CAShapeLayer()
        let maskRect = CGRect(x: 0.0, y: 0.0, width: newWidth, height: Double(fullRect.size.height))
        
        let path = CGPath(rect: maskRect, transform: nil)
        maskLayer.path = path
        
        waveformProgressView.layer.mask = maskLayer
    }
    
    private func setAudioHelper() {
        audioHelper.url = audioURL
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

extension SoundDetailVC {
    
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
    
}
