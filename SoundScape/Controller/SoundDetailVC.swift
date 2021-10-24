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
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var contentTextView: UITextView!
   
    // MARK: - properties
    
    private let waveformImageDrawer = WaveformImageDrawer()
    
    private let audioURL = Bundle.main.url(forResource: "memories", withExtension: "mp3")
    
    var audioHelper = AudioPlayHelper.shared
    
    var timer: Timer?
    
    var fileNameCount = 0
    
    weak var delegate: DetailPageShowableDelegate?
    
    let remotePlayerHelper = RemotePlayHelper.shared
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObserver()
        setAudioHelper()
    }
    
    // MARK: - deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - action
    
    @IBAction func leaveDetailPage(_ sender: UIButton) {
        guard let leave = delegate?.leaveDetailPage else { return }
        leave()
        timer?.invalidate()
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
            
            self.fileNameCount += 1
            
            let audioFileURL = cachesFolderURL?.appendingPathComponent("localFile\(self.fileNameCount).wav")
            
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
        authorLabel.text = nowPlayingInfo.author
        contentTextView.text = nowPlayingInfo.content
    }
    
    private func updateWaveformImages(localURL: URL) {
        // always uses background thread rendering
        
        waveformImageDrawer.waveformImage(fromAudioAt: localURL,
                                          size: waveformView.bounds.size,
                                          color: UIColor(named: CommonUsage.scLightGreen) ?? .green,
                                          style: .striped,
                                          position: .middle) { image in
            // need to jump back to main queue
            DispatchQueue.main.async {
                
                self.waveformView.image = image
                
            }
        }
        
        waveformImageDrawer.waveformImage(fromAudioAt: localURL,
                                          size: waveformProgressView.bounds.size,
                                          color: UIColor(named: CommonUsage.scOrange) ?? .orange,
                                          style: .striped,
                                          position: .middle) { image in
            // need to jump back to main queue
            DispatchQueue.main.async {
                
                self.waveformProgressView.image = image
            }
        }
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
    
}
