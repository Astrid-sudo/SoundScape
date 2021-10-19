//
//  AudioPlayerVC.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/19.
//

import UIKit

class AudioPlayerVC: UIViewController {
    
    // MARK: - properties
    
    var timer: Timer?
    
    let audioHelper = AudioHelper()
    
    private let audioURL = Bundle.main.url(forResource: "memories", withExtension: "mp3")
    
    // MARK: - UI properties
    
    private(set) lazy var audioImage: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 10
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.image = UIImage(named: CommonUsage.audioImage)
        return image
    }()
    
    private(set) lazy var audioTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: CommonUsage.font, size: 15)
        label.textAlignment = .left
        return label
    }()
    
    private(set) lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: CommonUsage.font, size: 12)
        label.textAlignment = .left
        return label
    }()
    
    lazy var favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        button.tintColor = .red
        //      button.addTarget(self, action: #selector(), for: .touchUpInside)
        return button
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
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
    
    lazy var detailButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(presentDetail), for: .touchUpInside)
        return button
    }()
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: CommonUsage.scGreen)
        setAudioHelper()
        setAudioImage()
        setAudioTitle()
        setAuthorLabel()
        setPlayButton()
        setFavoriteButton()
        setFakedata()
        setFullDurationView()
        setProgressView()
        setDetailButton()
        
    }
    
    // MARK: - init
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI method
    
    private func setAudioImage() {
        view.addSubview(audioImage)
        audioImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            audioImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            audioImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
            audioImage.widthAnchor.constraint(equalToConstant: 40),
            audioImage.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setAudioTitle() {
        view.addSubview(audioTitleLabel)
        audioTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            audioTitleLabel.leadingAnchor.constraint(equalTo: audioImage.trailingAnchor, constant: 20),
            audioTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 4)
        ])
    }
    
    private func setAuthorLabel() {
        view.addSubview(authorLabel)
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            authorLabel.leadingAnchor.constraint(equalTo: audioImage.trailingAnchor, constant: 20),
            authorLabel.topAnchor.constraint(equalTo: audioTitleLabel.bottomAnchor, constant: 4)
        ])
    }
    
    private func setPlayButton() {
        view.addSubview(playButton)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            playButton.centerYAnchor.constraint(equalTo: audioImage.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 50),
            playButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setFavoriteButton() {
        view.addSubview(favoriteButton)
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
        view.addSubview(fullDurationView)
        fullDurationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fullDurationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fullDurationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fullDurationView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6),
            fullDurationView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    private func setProgressView() {
        view.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    private func setDetailButton() {
        view.addSubview(detailButton)
        detailButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detailButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailButton.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor),
            detailButton.topAnchor.constraint(equalTo: view.topAnchor),
            detailButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - action
    
    @objc func manipulatePlayer() {
        
        if audioHelper.isPlaying == true {
            audioHelper.pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            if let timer = timer {
                timer.invalidate()
            }
        } else {
            audioHelper.play()
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 0.1,
                                         target: self,
                                         selector: #selector(updatePlaybackTime),
                                         userInfo: nil,
                                         repeats: true)
        }
    }
    
    @objc func updatePlaybackTime() {
        print(audioHelper.currentTime)
        updateProgressWaveform(audioHelper.currentTime / audioHelper.duration)
    }
    
    @objc func presentDetail() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let soundDetailVC = storyboard.instantiateViewController(withIdentifier: "SoundDetailVC") as? SoundDetailVC else { return }
        present(soundDetailVC, animated: true, completion: nil)
    }
    
    // MARK: - method
    
    private func setAudioHelper() {
        audioHelper.url = audioURL
    }
    
    func updateProgressWaveform(_ progress: Double) {
        let fullRect = progressView.bounds
        let newWidth = Double(fullRect.size.width) * progress
        let maskLayer = CAShapeLayer()
        let maskRect = CGRect(x: 0.0, y: 0.0, width: newWidth, height: Double(fullRect.size.height))
        let path = CGPath(rect: maskRect, transform: nil)
        maskLayer.path = path
        progressView.layer.mask = maskLayer
    }
    
}
