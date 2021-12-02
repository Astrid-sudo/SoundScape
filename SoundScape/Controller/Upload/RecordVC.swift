//
//  RecordVC.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/23.
//

import UIKit

class RecordVC: UIViewController {
    
    // MARK: - properties
    
    static let reuseIdentifier = String(describing: RecordVC.self)
    
    private let audioRecordHelper = AudioRecordHelper.shared
    
    private let waveformImageDrawer = DSWaveformImageWrapper.shared.initWaveformImageDrawer()
    
    // MARK: - UI properties
    
    private lazy var noticeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont(name: CommonUsage.font, size: 14)
        label.text = CommonUsage.Text.audioLengthNoticeWhenRecord
        return label
    }()
    
    private lazy var goEditButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(named: CommonUsage.scWhite), for: .normal)
        button.backgroundColor = UIColor(named: CommonUsage.scLightBlue)
        button.layer.cornerRadius = 10
        button.setTitle("Finish recording", for: .normal)
        button.addTarget(self, action: #selector(pushToNext), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private let waveformLiveView = DSWaveformImageWrapper.shared.createWaveformLiveView(
        frame: CGRect(x: 0,
                      y: 0,
                      width: CommonUsage.screenWidth,
                      height: 100))
    
    private lazy var recordTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scSuperLightBlue)
        label.textAlignment = .left
        label.font = UIFont(name: CommonUsage.font, size: 40)
        label.text = "00:0.0"
        return label
    }()
    
    private lazy var recordAgainLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CommonUsage.scSuperLightBlue)
        label.textAlignment = .left
        label.text = CommonUsage.Text.recordAgain
        label.isHidden = true
        return label
    }()
    
    private lazy var recordButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 30)
        let bigImage = UIImage(systemName: CommonUsage.SFSymbol.record, withConfiguration: config)
        button.setImage(bigImage, for: .normal)
        button.tintColor = UIColor(named: CommonUsage.scRed)
        button.addTarget(self, action: #selector(manipulaterecord), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setGoEditButton()
        setAudioLengthNotice()
        setWaveformLiveView()
        setRecordButton()
        checkMicPermission()
        setRecordTimeLabel()
        setRecordAgainLabel()
        audioRecordHelper.delegate = self
        view.backgroundColor = UIColor(named: CommonUsage.scBlue)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let stripeConfig = DSWaveformImageWrapper.shared.configWaveformStripe(
            color: UIColor(named: CommonUsage.scWhite),
            width: 3,
            spacing: 3.5,
            lineCap: .butt)
        
        waveformLiveView.configuration = waveformLiveView.configuration.with(
            size: self.waveformLiveView.bounds.size,
            backgroundColor: UIColor(named: CommonUsage.scBlue),
            style: .striped(stripeConfig),
            dampening: nil,
            position: .middle,
            scale: nil,
            verticalScalingFactor: nil,
            shouldDampenSides: true,
            shouldAntialias: false)
        
        waveformLiveView.shouldDrawSilencePadding = true
    }
    
    // MARK: - method
    
    private func checkMicPermission() {
        audioRecordHelper.checkAudioPermission {
            DispatchQueue.main.async {
                self.recordButton.isHidden = false
            }
        } notGrantedCompletion: {
            
            DispatchQueue.main.async {
                self.popErrorAlert(title: "Please allow SoundScape_ to access your microphone.",
                                   message: "Settings > SoundScape_ > Allow access Microphone")
            }
        }
    }
    
    // MARK: - UI method
    
    private func setNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(backToLastPage))
        navigationItem.leftBarButtonItem?.image = UIImage(systemName: CommonUsage.SFSymbol.back)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: CommonUsage.scWhite)
        navigationItem.title = CommonUsage.Text.record
    }
    
    private func setGoEditButton() {
        view.addSubview(goEditButton)
        goEditButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            goEditButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            goEditButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            goEditButton.widthAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func setAudioLengthNotice() {
        view.addSubview(noticeLabel)
        noticeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noticeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            noticeLabel.topAnchor.constraint(equalTo: goEditButton.bottomAnchor, constant: 32),
            noticeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setWaveformLiveView() {
        view.addSubview(waveformLiveView)
        waveformLiveView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waveformLiveView.topAnchor.constraint(equalTo: noticeLabel.bottomAnchor, constant: 32),
            waveformLiveView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            waveformLiveView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            waveformLiveView.heightAnchor.constraint(equalToConstant: 200)
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
    
    private func setRecordTimeLabel() {
        view.addSubview(recordTimeLabel)
        recordTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recordTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                     constant: (CommonUsage.screenWidth - 99) / 2 ),
            recordTimeLabel.bottomAnchor.constraint(equalTo: recordButton.topAnchor, constant: -24)
        ])
    }
    
    private func setRecordAgainLabel() {
        view.addSubview(recordAgainLabel)
        recordAgainLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recordAgainLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordAgainLabel.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 8)
        ])
    }
    
    // MARK: - action
    
    @objc func backToLastPage() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func manipulaterecord() {
        toggleRecordButtonImage()
        if audioRecordHelper.isRecording == false {
            waveformLiveView.reset()
            audioRecordHelper.recordAudio()
            goEditButton.isHidden = true
            recordAgainLabel.isHidden = true
        } else {
            _ = audioRecordHelper.stopRecording()
            goEditButton.isHidden = false
            recordAgainLabel.isHidden = false
        }
    }
    
    func toggleRecordButtonImage() {
        
        if audioRecordHelper.isRecording == false {
            
            let config = UIImage.SymbolConfiguration(pointSize: 30)
            let bigImage = UIImage(systemName: CommonUsage.SFSymbol.stopRecord, withConfiguration: config)
            recordButton.setImage(bigImage, for: .normal)
            
        } else {
            
            let config = UIImage.SymbolConfiguration(pointSize: 30)
            let bigImage = UIImage(systemName: CommonUsage.SFSymbol.record, withConfiguration: config)
            recordButton.setImage(bigImage, for: .normal)
            
        }
        
    }
    
    @objc func pushToNext() {
        
        guard let recordTime = recordTimeLabel.text,
              let time = Double(recordTime),
              time >= 5 else {
                  popErrorAlert(title: "Recorded audio too short.", message: "Required minimum length: 5 seconds.")
                  return
              }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let editVC = storyboard.instantiateViewController(withIdentifier: "EditVC") as? EditVC else { return }
        
        let filename = "User.m4a"
        let path = NSHomeDirectory() + "/Documents/" + filename
        let url = URL(fileURLWithPath: path)
        
        editVC.selectedFileURL = url
        editVC.originDuraion = AudioPlayHelper.shared.duration
        navigationController?.pushViewController(editVC, animated: true)
        
    }
    
}

// MARK: - conform to PlayRecoredStateChangableDelegate

extension RecordVC: RecordingUpdatableDelegate {
    
    func updateTimeAndPower(currentTime: TimeInterval, power: Float) {
        let current = String(describing: currentTime).dropLast(13)
        let roundedValue1 = String(format: "%.2f", currentTime)
        audioRecordHelper.audioRecorder?.updateMeters()
        recordTimeLabel.text = String(roundedValue1)
        
        let linear = 1 - pow(10, power / 20)
        
        print(String(current), linear)
        
        waveformLiveView.add(samples: [linear])
        
    }
    
}
