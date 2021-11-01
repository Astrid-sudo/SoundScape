//
//  RecordVC.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/23.
//

import UIKit
import DSWaveformImage

class RecordVC: UIViewController {
    
    // MARK: - properties
    
    let audioRecordHelper = AudioRecordHelper.shared
    
    private let waveformImageDrawer = WaveformImageDrawer()

    // MARK: - UI properties
    
    private lazy var goEditButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 30)
        let bigImage = UIImage(systemName: CommonUsage.SFSymbol.edit, withConfiguration: config)
        button.setImage(bigImage, for: .normal)
        button.tintColor = .red
        button.addTarget(self, action: #selector(pushToNext), for: .touchUpInside)
        return button
    }()
    
    private lazy var waveformLiveView: WaveformLiveView = {
        
        let waveformLiveView = WaveformLiveView(frame: CGRect(x: 0, y: 0, width: CommonUsage.screenWidth, height: 100))
        return waveformLiveView
    }()
    
    private lazy var recordTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scSuperLightBlue)
        label.textAlignment = .left
        label.font = UIFont(name: CommonUsage.font, size: 40)
        label.text = "00:0.0"
        return label
    }()
    
    private lazy var recordButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        let bigImage = UIImage(systemName: CommonUsage.SFSymbol.record, withConfiguration: config)
        button.setImage(bigImage, for: .normal)
        button.tintColor = .red
        button.addTarget(self, action: #selector(manipulaterecord), for: .touchUpInside)
        return button
    }()
    
    private lazy var playbackButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        let bigImage = UIImage(systemName: CommonUsage.SFSymbol.play, withConfiguration: config)
        button.setImage(bigImage, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(manipulatePlayback), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var stopButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        let bigImage = UIImage(systemName: CommonUsage.SFSymbol.stopPlay, withConfiguration: config)
        button.setImage(bigImage, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(stopPlaying), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setGoEditButton()
        setWaveformLiveView()
        setRecordTimeLabel()
        setRecordButton()
        setPlaybackButton()
        setStopButton()
        
        audioRecordHelper.delegate = self
        view.backgroundColor = UIColor(named: CommonUsage.scBlue)
        
    }
    
    /*
     size: self.waveformView.bounds.size,
                                  backgroundColor: .white,
                                  style: .striped(waveformViewConfig) , dampening: nil,
                                  position: .middle,
                                  scale: 10.0 , verticalScalingFactor: 0.5, shouldAntialias: true
     */
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let config = Waveform.Style.StripeConfig.init(color: UIColor(named: CommonUsage.scOrange) ?? .orange, width: 3.0, spacing: 3.5, lineCap: .butt)
        
        waveformLiveView.configuration = waveformLiveView.configuration.with(size: self.waveformLiveView.bounds.size,
                                                                             backgroundColor: UIColor(named: CommonUsage.scBlue),
                                                                             style: .striped(config),
                                                                             dampening: nil,
                                                                             position: .middle,
                                                                             scale: nil,
                                                                             verticalScalingFactor: nil, shouldDampenSides: true, shouldAntialias: false)
        
        waveformLiveView.shouldDrawSilencePadding = true
    }

    // MARK: - UI method
    
    private func setGoEditButton() {
        view.addSubview(goEditButton)
        goEditButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            goEditButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            goEditButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
    }
    
    private func setWaveformLiveView() {
        view.addSubview(waveformLiveView)
        waveformLiveView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waveformLiveView.topAnchor.constraint(equalTo: goEditButton.bottomAnchor, constant: 36),
            waveformLiveView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            waveformLiveView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            waveformLiveView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    private func setRecordTimeLabel() {
        view.addSubview(recordTimeLabel)
        recordTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recordTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordTimeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setRecordButton() {
        view.addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setPlaybackButton() {
        view.addSubview(playbackButton)
        playbackButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playbackButton.leadingAnchor.constraint(equalTo: recordButton.trailingAnchor, constant: 10),
            playbackButton.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor)
        ])
    }
    
    private func setStopButton() {
        view.addSubview(stopButton)
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stopButton.leadingAnchor.constraint(equalTo: playbackButton.trailingAnchor, constant: 16),
            stopButton.centerYAnchor.constraint(equalTo: playbackButton.centerYAnchor)
        ])
    }
    
    // MARK: - action
    
    @objc func manipulaterecord() {
        
        toggleRecordButtonImage()
        if audioRecordHelper.isRecording == false {
            waveformLiveView.reset()
            audioRecordHelper.recordAudio()
            playbackButton.isHidden = true
            stopButton.isHidden = true
        } else {
            audioRecordHelper.stopRecording()
            playbackButton.isHidden = false
            stopButton.isHidden = false
            
        }
    }
    
    @objc func manipulatePlayback() {
        
        togglePlayButtonImage()
        if audioRecordHelper.isPlaying == false {
            audioRecordHelper.playRecordedSound()
        } else {
            audioRecordHelper.pausePlayRecorded()
        }
    }
    
    @objc func stopPlaying() {
        
        audioRecordHelper.stopPlaying()
        
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        let bigImage = UIImage(systemName: CommonUsage.SFSymbol.play, withConfiguration: config)
        playbackButton.setImage(bigImage, for: .normal)
    }
    
    func toggleRecordButtonImage() {
        
        if audioRecordHelper.isRecording == false {
            
            let config = UIImage.SymbolConfiguration(pointSize: 50)
            let bigImage = UIImage(systemName: CommonUsage.SFSymbol.stopRecord, withConfiguration: config)
            recordButton.setImage(bigImage, for: .normal)
            
        } else {
            
            let config = UIImage.SymbolConfiguration(pointSize: 50)
            let bigImage = UIImage(systemName: CommonUsage.SFSymbol.record, withConfiguration: config)
            recordButton.setImage(bigImage, for: .normal)
            
        }
        
    }
    
    func togglePlayButtonImage() {
        
        if audioRecordHelper.isPlaying == false {
            
            let config = UIImage.SymbolConfiguration(pointSize: 50)
            let bigImage = UIImage(systemName: CommonUsage.SFSymbol.pause, withConfiguration: config)
            playbackButton.setImage(bigImage, for: .normal)
            
        } else {
            
            let config = UIImage.SymbolConfiguration(pointSize: 50)
            let bigImage = UIImage(systemName: CommonUsage.SFSymbol.play, withConfiguration: config)
            playbackButton.setImage(bigImage, for: .normal)
            
        }
        
    }
    
    @objc func pushToNext() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let editVC = storyboard.instantiateViewController(withIdentifier: "EditVC") as? EditVC else { return }
        
        let filename = "User.m4a"
        let path = NSHomeDirectory() + "/Documents/" + filename
        let url = URL(fileURLWithPath: path)
        
        editVC.selectedFileURL = url
        navigationController?.pushViewController(editVC, animated: true)
        
    }
    
}

extension RecordVC: PlayRecoredStateChangableDelegate {
    
    func updateTimeAndPower(currentTime: TimeInterval, power: Float) {
       
        let current = String(describing: currentTime).dropLast(13)
        audioRecordHelper.audioRecorder?.updateMeters()
        recordTimeLabel.text = String(current)
        
        let linear = 1 - pow(10, power / 20)
        
        print(String(current), linear)

        // Here we add the same sample 3 times to speed up the animation.
        // Usually you'd just add the sample once.
        waveformLiveView.add(samples: [linear])

    }
    
    func didFinishPlaying() {
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        let bigImage = UIImage(systemName: CommonUsage.SFSymbol.play, withConfiguration: config)
        playbackButton.setImage(bigImage, for: .normal)
    }
    
}

