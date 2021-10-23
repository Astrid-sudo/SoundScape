//
//  EditVC.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/23.
//

import UIKit
import DSWaveformImage
import CoreMedia

class EditVC: UIViewController {
    
    // MARK: - properties
    
    let audioPlayHelper = AudioPlayHelper.shared
    
    // MARK: - UI properties
    private lazy var goUploadPageButton: UIButton = {
        let button = UIButton()
        button.setTitle("Go upload", for: .normal)
        button.setTitleColor(UIColor(named: CommonUsage.scWhite), for: .normal)
        button.backgroundColor = UIColor(named: CommonUsage.scRed)
        button.layer.cornerRadius = 15
        //      button.addTarget(self, action: #selector(removeThisCell), for: .touchUpInside)
        return button
    }()
    
    private lazy var lowCutButton: UIButton = {
        let button = UIButton()
        button.setTitle("""
Low
Cut
""", for: .normal)
        button.setTitleColor(UIColor(named: CommonUsage.scWhite), for: .normal)
        button.titleLabel?.numberOfLines = 0
        //        button.titleLabel?.font = UIFont(name: CommonUsage.font, size: 8)
        button.backgroundColor = UIColor(named: CommonUsage.scOrange)
        //      button.addTarget(self, action: #selector(removeThisCell), for: .touchUpInside)
        button.layer.cornerRadius = 30
        return button
    }()
    
    let waveformImageView = WaveformImageView(frame: CGRect(x: 0, y: 0, width: CommonUsage.screenWidth, height: 100))
    
    private lazy var trimButton: UIButton = {
        let button = UIButton()
        button.setTitle("TRIM", for: .normal)
        button.setTitleColor(UIColor(named: CommonUsage.scGreen), for: .normal)
        button.backgroundColor = UIColor(named: CommonUsage.scYellow)
        //      button.addTarget(self, action: #selector(removeThisCell), for: .touchUpInside)
        button.layer.cornerRadius = 15
        
        return button
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: CommonUsage.SFSymbol.play), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(manipulatePlayer), for: .touchUpInside)
        return button
    }()
    
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: CommonUsage.font, size: 40)
        label.text = "00:0.0"
        return label
    }()
    
    private lazy var durationTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont(name: CommonUsage.font, size: 20)
        label.text = "Duration"
        return label
    }()
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont(name: CommonUsage.font, size: 20)
        return label
    }()
    
    private let waveformImageDrawer = WaveformImageDrawer()
    
    // MARK: - properties
    
    var selectedFileURL: URL? {
        
        didSet {
            
            waveformImageView.waveformColor = .clear
            
            guard let selectedFileURL = selectedFileURL else { return }
            
            self.updateWaveformImages(localURL: selectedFileURL)
            
            let waveformAnalyzer = WaveformAnalyzer(audioAssetURL: selectedFileURL)
            waveformAnalyzer?.samples(count: 10) { samples in
                print("sampled down to 10, results are \(samples ?? [])")
            }
            
            audioPlayHelper.url = selectedFileURL
            
            let interval = audioPlayHelper.duration
            //            guard let playerItem = AudioPlayHelper.shared.playerItem else { return }
            
            //            let interval = playerItem.duration
            //            let secondDuration = CMTimeGetSeconds(interval)
            
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .full
            
            let formattedString = formatter.string(from: TimeInterval(interval))
            durationLabel.text = formattedString
            
        }
    }
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
        view.backgroundColor = UIColor(named: CommonUsage.scBlue)
        setGoUploadPageButton()
        setLowCutButton()
        setWaveformImageView()
        setTrimButton()
        setPlayButton()
        setCurrentTimeLabel()
        setDurationTitleLabel()
        setDurationLabel()
    }
    
    // MARK: - deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - method
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTime),
                                               name: .audioPlayHelperUpdateTime,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updatePlayButton),
                                               name: .audioPlayHelperDidPlayEnd,
                                               object: nil)
        
    }
    
    private func updateWaveformImages(localURL: URL) {
        // always uses background thread rendering
        
        waveformImageDrawer.waveformImage(fromAudioAt: localURL,
                                          size: waveformImageView.bounds.size,
                                          color: UIColor(named: CommonUsage.scOrange) ?? .orange,
                                          style: .striped,
                                          position: .middle) { image in
            // need to jump back to main queue
            DispatchQueue.main.async {
                
                self.waveformImageView.image = image
            }
        }
    }
    
    // MARK: - config UI method
    
    private func setGoUploadPageButton() {
        view.addSubview(goUploadPageButton)
        goUploadPageButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            goUploadPageButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            goUploadPageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            goUploadPageButton.heightAnchor.constraint(equalToConstant: 30),
            goUploadPageButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setLowCutButton() {
        view.addSubview(lowCutButton)
        lowCutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lowCutButton.topAnchor.constraint(equalTo: goUploadPageButton.bottomAnchor, constant: 30),
            lowCutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            lowCutButton.heightAnchor.constraint(equalToConstant: 60),
            lowCutButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setWaveformImageView() {
        view.addSubview(waveformImageView)
        waveformImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waveformImageView.topAnchor.constraint(equalTo: lowCutButton.bottomAnchor, constant: 60),
            waveformImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            waveformImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            waveformImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setTrimButton() {
        view.addSubview(trimButton)
        trimButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trimButton.topAnchor.constraint(equalTo: waveformImageView.bottomAnchor, constant: 24),
            trimButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trimButton.heightAnchor.constraint(equalToConstant: 40),
            trimButton.widthAnchor.constraint(equalToConstant: 100)
            
        ])
    }
    
    private func setPlayButton() {
        view.addSubview(playButton)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playButton.topAnchor.constraint(equalTo: trimButton.bottomAnchor, constant: 16),
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.heightAnchor.constraint(equalToConstant: 60),
            playButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setCurrentTimeLabel() {
        view.addSubview(currentTimeLabel)
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentTimeLabel.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 16),
            currentTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setDurationTitleLabel() {
        view.addSubview(durationTitleLabel)
        durationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            durationTitleLabel.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: 16),
            durationTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100)
        ])
    }
    
    private func setDurationLabel() {
        view.addSubview(durationLabel)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            durationLabel.centerYAnchor.constraint(equalTo: durationTitleLabel.centerYAnchor),
            durationLabel.leadingAnchor.constraint(equalTo: durationTitleLabel.trailingAnchor, constant: 8)
        ])
    }
    
    // MARK: - action
    
    @objc func manipulatePlayer() {
        
        if audioPlayHelper.isPlaying == true {
            audioPlayHelper.pause()
            playButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.play), for: .normal)
        }
        
        if audioPlayHelper.isPlaying == false {
            audioPlayHelper.play()
            playButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.pause), for: .normal)
        }
        
    }
    
    @objc func updateTime(notification: Notification) {
        
        guard let currentTime = notification.userInfo?["UserInfo"] as? Double else { return }
        //        let currentSeconds = CMTimeGetSeconds(cmCurrentTime)
        //        let interval = currentSeconds
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        
        let formattedString = formatter.string(from: TimeInterval(currentTime))
        currentTimeLabel.text = formattedString
    }
    
    @objc func updatePlayButton() {
        playButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.play), for: .normal)
    }
    
}
