//
//  AudioHelper.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/20.
//

import Foundation
import AVFoundation

protocol PlayRecoredStateChangableDelegate: AnyObject {
    func didFinishPlaying()
    func updateTimeAndPower(currentTime: TimeInterval, power: Float)
}

enum AudioSessionMode {
    case record
    case play
}

class AudioRecordHelper: NSObject, AVAudioRecorderDelegate {
    
    // MARK: - properties
    
    static let shared = AudioRecordHelper()
    
    var audioRecorder: AVAudioRecorder?
   
    var audioPlayer: AVAudioPlayer?
    
    var isRecording = false
    
    var isPlaying = false
    
    var url: URL?
    
    var duration: Double?
    
    weak var delegate: PlayRecoredStateChangableDelegate?
    
    var displayLink: CADisplayLink?
    
    // MARK: - init
    
    private override init() {
        super.init()
        
        // init an audio recorder
        let filename = "User.m4a"
        let path = NSHomeDirectory() + "/Documents/" + filename
        self.url = URL(fileURLWithPath: path)
        let recordSettings: [String: Any] = [
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0
        ]
        
        guard let url = self.url else { return }
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: recordSettings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.delegate = self
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - method
    
    func settingAudioSession(toMode mode: AudioSessionMode) {
        audioPlayer?.stop()
        
        let session = AVAudioSession.sharedInstance()
        do {
            switch mode {
            case .record:
                try session.setCategory(.playAndRecord, mode: .default, options: [])
            case .play:
                try session.setCategory(.playback, mode: .default, options: [])
            }
            try session.setActive(false)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if flag == true {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: recorder.url)
                self.duration = audioPlayer?.duration
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
     func checkAudioPermission(grantedCompletion: @escaping() -> Void,
                               notGrantedCompletion: @escaping() -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                grantedCompletion()
            } else {
                notGrantedCompletion()
            }
        }
    }

    func recordAudio() {
        settingAudioSession(toMode: .record)
        audioRecorder?.prepareToRecord()
        audioRecorder?.record()
        isRecording = true
        displayLink = CADisplayLink(target: self, selector: #selector(updateTimeAndPower))
        displayLink?.add(to: RunLoop.main, forMode: .common)
    }
    
    func stopRecording() -> URL? {
        audioRecorder?.stop()
        isRecording = false
        settingAudioSession(toMode: .play)
        
        if let displayLink = displayLink {
            displayLink.invalidate()
        }
        
        return url
    }
    
    func stopPlaying() {
        if isRecording == false {
            audioPlayer?.stop()
            isPlaying = false
            audioPlayer?.currentTime = 0
        }
    }
    
    @objc func updateTimeAndPower() {
        
        guard let audioRecorder = audioRecorder else {
            return
        }
        
        let avaragePower = audioRecorder.averagePower(forChannel: 0)
        let peak = audioRecorder.peakPower(forChannel: 0)
        print("from AudioHelper Recorder_avaragePower: \(avaragePower), peak: \(peak)")

        delegate?.updateTimeAndPower(currentTime: audioRecorder.currentTime, power: avaragePower)
        
    }
    
}
