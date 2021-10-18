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
    
    // MARK: - properties
    
    private let waveformImageDrawer = WaveformImageDrawer()
    
//    private let audioURL = Bundle.main.url(forResource: "example_sound_2", withExtension: "m4a")
    
//    private let audioURL = Bundle.main.url(forResource: "example_sound", withExtension: "wav")
    
    private let audioURL = Bundle.main.url(forResource: "memories", withExtension: "mp3")

    lazy var audioHelper = AudioHelper()
    
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
    }
    
    @IBAction func pauseAudio(_ sender: UIButton) {
        audioHelper.pause()
    }
    
    @IBAction func stopAudio(_ sender: UIButton) {
        audioHelper.stop()
    }
    // MARK: - method
    
    private func updateWaveformImages() {
        // always uses background thread rendering
        
        guard let audioURL = audioURL else { return }

        waveformImageDrawer.waveformImage(fromAudioAt: audioURL,
                                          size: waveformView.bounds.size,
                                          style: .striped,
                                          position: .middle) { image in
            // need to jump back to main queue
            DispatchQueue.main.async {
                self.waveformView.image = image
            }
        }
    }
    
    private func setAudioHelper() {
        audioHelper.url = audioURL
    }
    
}
