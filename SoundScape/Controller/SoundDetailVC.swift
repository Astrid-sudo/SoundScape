//
//  ViewController.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/18.
//

import UIKit
import DSWaveformImage
import AVFAudio

class SoundDetailVC: UIViewController {
    
    // MARK: - UI properties
    
    @IBOutlet weak var waveformView: WaveformImageView!
    
    @IBOutlet weak var waveformProgressView: WaveformImageView!
    
    // MARK: - properties
    
    private let waveformImageDrawer = WaveformImageDrawer()
    
    //    private let audioURL = Bundle.main.url(forResource: "example_sound_2", withExtension: "m4a")
    
    //    private let audioURL = Bundle.main.url(forResource: "example_sound", withExtension: "wav")
    
    private let audioURL = Bundle.main.url(forResource: "memories", withExtension: "mp3")
    
    lazy var audioHelper = AudioHelper()
    
    private var playbackRateObserver: NSObjectProtocol!
    
    var timer: Timer?
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAudioHelper()
    }
    
    override func viewDidLayoutSubviews() {
        
        updateWaveformImages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // get access to the raw, normalized amplitude samples
        guard let audioURL = audioURL else { return }
        let waveformAnalyzer = WaveformAnalyzer(audioAssetURL: audioURL)
        waveformAnalyzer?.samples(count: 10) { samples in
            print("sampled down to 10, results are \(samples ?? [])")
        }
    }
    
    // MARK: - action
    
    @IBAction func playAudio(_ sender: UIButton) {
        
        audioHelper.play()
        
        timer = Timer.scheduledTimer(timeInterval: 0.1,
                                     target: self,
                                     selector: #selector(updatePlaybackTime),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @IBAction func pauseAudio(_ sender: UIButton) {
        
        audioHelper.pause()
        
        if let timer = timer {
            timer.invalidate()
        }
    }
    
    @IBAction func stopAudio(_ sender: UIButton) {
        
        audioHelper.stop()
        
        if let timer = timer {
            timer.invalidate()
        }
        
    }
    // MARK: - method
    
    private func updateWaveformImages() {
        // always uses background thread rendering
        
        guard let audioURL = audioURL else { return }
        
        waveformImageDrawer.waveformImage(fromAudioAt: audioURL,
                                          size: waveformView.bounds.size,
                                          color: .systemPink,
                                          style: .striped,
                                          position: .middle) { image in
            // need to jump back to main queue
            DispatchQueue.main.async {
                
                self.waveformView.image = image
                
            }
        }
        
        waveformImageDrawer.waveformImage(fromAudioAt: audioURL,
                                          size: waveformProgressView.bounds.size,
                                          color: .green,
                                          style: .striped,
                                          position: .middle) { image in
            // need to jump back to main queue
            DispatchQueue.main.async {
                
                self.waveformProgressView.image = image
            }
        }
    }
    
    func updateProgressWaveform(_ progress: Double) {
        
        let fullRect = waveformProgressView.bounds
        let newWidth = Double(fullRect.size.width) * progress
        
        let maskLayer = CAShapeLayer()
        let maskRect = CGRect(x: 0.0, y: 0.0, width: newWidth, height: Double(fullRect.size.height))
        
        let path = CGPath(rect: maskRect, transform: nil)
        maskLayer.path = path
        
        waveformProgressView.layer.mask = maskLayer
    }
    
    @objc func updatePlaybackTime() {
        
        print(audioHelper.currentTime)
        
        updateProgressWaveform(audioHelper.currentTime / audioHelper.duration)
    }
    
    private func setAudioHelper() {
        
        audioHelper.url = audioURL
    }
    
}
