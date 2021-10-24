//
//  RecordVC.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/23.
//

import UIKit

class RecordVC: UIViewController {
    
    // MARK: - properties
    
    let audioRecordHelper = AudioRecordHelper.shared
    
    // MARK: - UI properties
    
    private lazy var recordButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: CommonUsage.SFSymbol.record), for: .normal)
        button.tintColor = .red
              button.addTarget(self, action: #selector(manipulaterecord), for: .touchUpInside)
        return button
    }()
    
    private lazy var playbackButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: CommonUsage.SFSymbol.play), for: .normal)
        button.tintColor = .black
              button.addTarget(self, action: #selector(manipulatePlayback), for: .touchUpInside)
        return button
    }()
    
    private lazy var stopButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: CommonUsage.SFSymbol.stopPlay), for: .normal)
        button.tintColor = .black
              button.addTarget(self, action: #selector(stopPlaying), for: .touchUpInside)
        return button
    }()

    private lazy var goEditButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: CommonUsage.SFSymbol.edit), for: .normal)
        button.tintColor = .red
        button.addTarget(self, action: #selector(pushToNext), for: .touchUpInside)
        return button
    }()
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRecordButton()
        setPlaybackButton()
        setStopButton()
        setGoEditButton()
        
        audioRecordHelper.delegate = self
        view.backgroundColor = UIColor(named: CommonUsage.scBlue)

    }
    
    // MARK: - UI method
    
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
            playbackButton.leadingAnchor.constraint(equalTo: recordButton.trailingAnchor, constant: 50),
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
    
    private func setGoEditButton() {
        view.addSubview(goEditButton)
        goEditButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            goEditButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            goEditButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
    }
    
    // MARK: - action
    
    @objc func manipulaterecord() {
        
        if audioRecordHelper.isRecording == false {
            audioRecordHelper.recordAudio()
            recordButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.stopRecord), for: .normal)
        } else {
            audioRecordHelper.stopRecording()
            recordButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.record), for: .normal)

        }
        
    }
    
    @objc func manipulatePlayback() {
       
        if audioRecordHelper.isPlaying == false {
            audioRecordHelper.playRecordedSound()
            playbackButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.pause), for: .normal)
        
        } else {
            
            audioRecordHelper.pausePlayRecorded()
            playbackButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.play), for: .normal)
        }
    }
    
    @objc func stopPlaying() {
        
        audioRecordHelper.stopPlaying()
        
        playbackButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.play), for: .normal)
    
    }

    @objc func pushToNext() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let editVC = storyboard.instantiateViewController(withIdentifier: "EditVC") as? EditVC else { return }
        
        let filename = "User.wav"
        let path = NSHomeDirectory() + "/Documents/" + filename
        let url = URL(fileURLWithPath: path)

        editVC.selectedFileURL = url
        navigationController?.pushViewController(editVC, animated: true)

    }
    
}

extension RecordVC: PlayRecoredStateChangableDelegate {
    
    func didFinishPlaying() {
        playbackButton.setImage(UIImage(systemName: CommonUsage.SFSymbol.play), for: .normal)
    }
    
}
