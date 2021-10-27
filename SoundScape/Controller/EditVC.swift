//
//  EditVC.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/23.
//

import UIKit
import DSWaveformImage

class EditVC: UIViewController {
    
    // MARK: - properties
    
    
    var trimHeadViewX: CGFloat {
        trimHeadView.center.x
    }
    
    var trimTailViewX: CGFloat {
        trimTailView.center.x
    }
    
    
    var trimHeadTime: Double {
        guard let originDuraion = originDuraion else { return 0.0}
        return (trimHeadViewX - 21) / (CommonUsage.screenWidth - 32) * originDuraion
        
    }
    
    var trimTailTime: Double {
        guard let originDuraion = originDuraion else { return 0.0 }
        return (trimTailViewX + 30)  * originDuraion / (slider.frame.width)
        //        return (trimTailViewX - 100) / (CommonUsage.screenWidth - 32) * originDuraion
    }
    var sliderCenterX: CGFloat {
        CGFloat(slider.value / slider.maximumValue) * (CommonUsage.screenWidth - 32)
    }
    
    let remotePlayerHelper = RemotePlayHelper.shared
    
    var originDuraion: Double? {
        didSet {
            guard let originDuraion = originDuraion else { return }
            durationLabel.text = String(describing: originDuraion)
            if originDuraion <= 120 {
                goUploadPageButton.isHidden = false
            } else {
                goUploadPageButton.isHidden = true
            }
        }
    }
    
    var trimmedDuration: Double? {
        
        didSet {
            
            guard let trimmedDuration = trimmedDuration else { return }
            
            durationLabel.text = String(describing: trimmedDuration)
            
        }
    }
    
    var selectedFileURL: URL? {
        
        didSet {
            
            // render waveform
            
            guard let selectedFileURL = selectedFileURL else { return }
            
            self.updateWaveformImages(localURL: selectedFileURL)
            
            let waveformAnalyzer = WaveformAnalyzer(audioAssetURL: selectedFileURL)
            waveformAnalyzer?.samples(count: 10) { samples in
                print("sampled down to 10, results are \(samples ?? [])")
            }
            
            // prepare player
            remotePlayerHelper.url = selectedFileURL
            TrimAudioManager.shared.originalURL = selectedFileURL
            
        }
    }
    
    private var trimerViewDidAdd = false
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TrimAudioManager.shared.delegate = self
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
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
        setSlider()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if trimerViewDidAdd == false {
            setTrimHeadView()
            setTrimHeadPreciseView()
            setTrimTailView()
            setTrimTailPreciseView()
            trimerViewDidAdd = true
        }
        
    }
    
    // MARK: - deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - method
    
    private func addObserver() {
        
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
                                               selector: #selector(setDurationText),
                                               name: .didItemDurationChange,
                                               object: nil)
    }
    
    @objc func goUpload() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let uploadVC = storyboard.instantiateViewController(withIdentifier: "UploadVC") as? UploadVC else { return }
        uploadVC.selectedFileURL = selectedFileURL
        uploadVC.selectedFileDuration = originDuraion
        navigationController?.pushViewController(uploadVC, animated: true)
        
    }
    
    @objc func setDurationText(notification: Notification) {
        guard let duration = notification.userInfo?["UserInfo"] as? Double else { return }
        print("EditVC recieved duration \(duration)")
        slider.maximumValue = Float(duration)
        self.originDuraion = duration
    }
    
    @objc func trim() {
        
        TrimAudioManager.shared.trimAudio(from: trimHeadTime, to: trimTailTime)
    }
    /*
     let button = UIButton()
     let config = UIImage.SymbolConfiguration(pointSize: 50)
     let bigImage = UIImage(systemName: CommonUsage.SFSymbol.play, withConfiguration: config)
     button.setImage(bigImage, for: .normal)
     button.tintColor = .black
     button.addTarget(self, action: #selector(manipulatePlayback), for: .touchUpInside)
     button.isHidden = true

     */

    @objc func changeButtImage() {
        
        if remotePlayerHelper.state == .stopped
            || remotePlayerHelper.state == .buffering
            || remotePlayerHelper.state == .paused
            || remotePlayerHelper.state == .loaded {
            let config = UIImage.SymbolConfiguration(pointSize: 50)
            let bigImage = UIImage(systemName: CommonUsage.SFSymbol.play, withConfiguration: config)

            playButton.setImage(bigImage, for: .normal)
        }
        
        if remotePlayerHelper.state == .playing {
            let config = UIImage.SymbolConfiguration(pointSize: 50)
            let bigImage = UIImage(systemName: CommonUsage.SFSymbol.pause, withConfiguration: config)
            playButton.setImage(bigImage, for: .normal)
        }
        
    }
    
    @objc func updatePlaybackTime(notification: Notification) {
        guard let currentTime = notification.userInfo?["UserInfo"] as? Double else { return }
        print("EditVC recieved current time \(currentTime)")
        
        DispatchQueue.main.async { [self] in
            self.currentTimeLabel.text = String(describing: currentTime)
            self.slider.value = Float(currentTime)
            remotePlayerHelper.limitCurrentTime(head: trimHeadTime, tail: trimTailTime)
            print("headTime: \(trimHeadTime), tailTime: \(trimTailTime), originDuration: \(originDuraion), sliderWidth: \(slider.frame.width), tailCenterX: \(trimTailViewX)")
        }
    }
    
    private func updateWaveformImages(localURL: URL) {
        // always uses background thread rendering
        
        let config = Waveform.Style.StripeConfig.init(color: UIColor(named: CommonUsage.scOrange) ?? .orange, width: 2, spacing: 2, lineCap: .butt)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.waveformImageDrawer.waveformImage(fromAudioAt: localURL,
                                                   with: Waveform.Configuration(size: self.waveformImageView.bounds.size,
                                                                                backgroundColor: .clear, style: .striped(config) ,
                                                                                dampening: nil,
                                                                                position: .middle,
                                                                                scale: 10.0 ,
                                                                                verticalScalingFactor: 0.5,
                                                                                shouldAntialias: true),
                                                   completionHandler: { image in
                DispatchQueue.main.async {
                    self.waveformImageView.image = image
                }
            })
            
        }
        
    }
    
    private func calculateDuration() {
        
        //        guard let originDuraion = originDuraion else { return }
        //        trimmedDuration = (trimTailViewX - trimHeadViewX) / CommonUsage.screenWidth * originDuraion
        
        trimmedDuration = trimTailTime - trimHeadTime
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
    
    @objc func scrubToTime() {
        remotePlayerHelper.seek(position: Double(slider.value))
    }
    
    @objc func handleHeadPanGesture(pan: UIPanGestureRecognizer) {
        
        let translation = pan.translation(in: view)
        print("*****translation \(translation)******************")
        guard let trimHeadView = pan.view else {
            return
        }
        
        if pan.state == .changed {
            var middlePoint = trimHeadView.center.x + translation.x
            let bounds = view.bounds.inset(by: view.safeAreaInsets)
            middlePoint = min(max(middlePoint, bounds.minX + 43), sliderCenterX + 30)
            if trimTailViewX - middlePoint < -54 {
                middlePoint = trimTailViewX + 54
            }
            trimHeadView.center.x = middlePoint
        }
        
        if pan.state == .ended {
            let velocity = pan.velocity(in: view)
            let vectorToFinalPoint = velocity.x / 15
            let bounds = view.bounds.inset(by: view.safeAreaInsets)
            var finalPoint = trimHeadView.center.x
            finalPoint += vectorToFinalPoint
            finalPoint = min(max(finalPoint, bounds.minX + 43), sliderCenterX + 30)
            if trimTailViewX - finalPoint < -54 {
                finalPoint = trimTailViewX + 54
            }
            trimHeadView.center.x = finalPoint
        }
        
        pan.setTranslation(.zero, in: view)
        
        //        trimHeadViewX = trimHeadView.center.x
        calculateDuration()
    }
    
    @objc func handleTailPanGesture(pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: view)
        print("*****translation \(translation)******************")
        guard let trimTailView = pan.view else {
            return
        }
        
        if pan.state == .changed {
            var middlePoint = trimTailView.center.x + translation.x
            let bounds = view.bounds.inset(by: view.safeAreaInsets)
            middlePoint = min(max(middlePoint, sliderCenterX - 13), bounds.maxX - 43)
            if trimTailViewX - middlePoint < -54 {
                middlePoint = trimHeadViewX + 54
            }
            trimTailView.center.x = middlePoint
        }
        
        if pan.state == .ended {
            let velocity = pan.velocity(in: view)
            let vectorToFinalPoint = velocity.x / 15
            let bounds = view.bounds.inset(by: view.safeAreaInsets)
            var finalPoint = trimTailView.center.x
            finalPoint += vectorToFinalPoint
            finalPoint = min(max(finalPoint, sliderCenterX - 13), bounds.maxX - 43)
            
            if trimTailViewX - finalPoint < -54 {
                finalPoint = trimTailViewX + 54
            }
            trimTailView.center.x = finalPoint
        }
        //        trimTailViewX = trimTailView.center.x
        pan.setTranslation(.zero, in: view)
        
        calculateDuration()
    }
    
    // MARK: - UI properties
    
    private lazy var goUploadPageButton: UIButton = {
        let button = UIButton()
        button.setTitle("Go upload", for: .normal)
        button.setTitleColor(UIColor(named: CommonUsage.scWhite), for: .normal)
        button.backgroundColor = UIColor(named: CommonUsage.scRed)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(goUpload), for: .touchUpInside)
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
        button.addTarget(self, action: #selector(trim), for: .touchUpInside)
        button.layer.cornerRadius = 15
        
        return button
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 50)
        let bigImage = UIImage(systemName: CommonUsage.SFSymbol.play, withConfiguration: config)
        button.setImage(bigImage, for: .normal)
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
    
    private lazy var slider: UISlider = {
        let slider = UISlider()
        
        slider.backgroundColor = .clear
        slider.maximumTrackTintColor = .clear
        slider.minimumTrackTintColor = .clear
        
        let verticalLine = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 100))
        let verticalLineImage = verticalLine.snapshot()
        guard let verticalLineImage = verticalLineImage else { return UISlider() }
        let colorImage = verticalLineImage.withTintColor(.green, renderingMode: .automatic)
        slider.setThumbImage(colorImage, for: .normal)
        
        slider.minimumValue = 0
        //        slider.maximumValue = 100
        slider.value = 0
        slider.isEnabled = true
        slider.isContinuous = true
        
        slider.addTarget(
            self,
            action:
                #selector(scrubToTime),
            for: UIControl.Event.valueChanged)
        
        return slider
    }()
    
    private lazy var trimHeadView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 100, alpha: 0.01)
        let trimHeadPanReconizer = UIPanGestureRecognizer(target: self, action: #selector(handleHeadPanGesture))
        view.addGestureRecognizer(trimHeadPanReconizer)
        return view
    }()
    
    private lazy var trimTailView: UIView = {
        let view = UIView()
        //        view.backgroundColor = .red
        view.backgroundColor = UIColor(red: 139, green: 0, blue: 0, alpha: 0.01)
        
        let trimTailPanReconizer = UIPanGestureRecognizer(target: self, action: #selector(handleTailPanGesture))
        view.addGestureRecognizer(trimTailPanReconizer)
        return view
    }()
    
    private lazy var trimHeadPreciseView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        return view
    }()
    
    private lazy var trimTailPreciseView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemIndigo
        return view
    }()
    
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
            lowCutButton.topAnchor.constraint(equalTo: goUploadPageButton.bottomAnchor, constant: 16),
            lowCutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            lowCutButton.heightAnchor.constraint(equalToConstant: 60),
            lowCutButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setWaveformImageView() {
        view.addSubview(waveformImageView)
        waveformImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waveformImageView.topAnchor.constraint(equalTo: lowCutButton.bottomAnchor, constant: 16),
            waveformImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            waveformImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            waveformImageView.heightAnchor.constraint(equalToConstant: 80)
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
            playButton.topAnchor.constraint(equalTo: trimButton.bottomAnchor, constant: 8),
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setCurrentTimeLabel() {
        view.addSubview(currentTimeLabel)
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentTimeLabel.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 8),
            currentTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setDurationTitleLabel() {
        view.addSubview(durationTitleLabel)
        durationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            durationTitleLabel.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: 4),
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
    
    private func setSlider() {
        view.addSubview(slider)
        slider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            slider.centerYAnchor.constraint(equalTo: waveformImageView.centerYAnchor),
            slider.leadingAnchor.constraint(equalTo: waveformImageView.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: waveformImageView.trailingAnchor)
        ])
    }
    
    private func setTrimHeadView() {
        
        view.addSubview(trimHeadView)
        
        trimHeadView.frame = CGRect(x: slider.center.x - slider.frame.width / 2 - 2,
                                    y: slider.center.y - 100,
                                    width: 60,
                                    height: 200)
        view.layoutIfNeeded()
    }
    
    private func setTrimTailView() {
        view.addSubview(trimTailView)
        
        trimTailView.frame = CGRect(x: CommonUsage.screenWidth - 75,
                                    y: slider.center.y - 100,
                                    width: 60,
                                    height: 200)
        
        view.layoutIfNeeded()
        
    }
    
    private func setTrimHeadPreciseView() {
        
        trimHeadView.addSubview(trimHeadPreciseView)
        trimHeadPreciseView.frame = CGRect(x: 0,
                                           y: 0,
                                           width: 3,
                                           height: 200)
        
    }
    
    private func setTrimTailPreciseView() {
        
        trimTailView.addSubview(trimTailPreciseView)
        
        trimTailPreciseView.frame = CGRect(x: trimTailView.frame.width,
                                           y: 0,
                                           width: 3,
                                           height: 200)
        view.layoutIfNeeded()
    }
    
    
}

extension EditVC: TrimAudioManagerDelegate {
    
    func didExport(to url: URL) {
        selectedFileURL = url
    }
}

