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
}

enum AudioSessionMode {
    case record
    case play
}

class AudioRecordHelper: NSObject, AVAudioRecorderDelegate {
    
    // MARK: - properties
    
    static let shared = AudioRecordHelper()
    
    var audioRecorder: AVAudioRecorder?
   
    var audioPlayer: AVAudioPlayer? {
        didSet{
            audioPlayer?.delegate = self
        }
    }
    
    var isRecording = false
    
    var isPlaying = false
    
    var url: URL?
    
    var duration: Double?
    
    weak var delegate: PlayRecoredStateChangableDelegate?
    
    // MARK: - init
    
    private override init() {
        super.init()
        
        //init an audio recorder
        let filename = "User.wav"
        let path = NSHomeDirectory() + "/Documents/" + filename
        //        let url = URL(fileURLWithPath: path)
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
                print(duration)

            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func recordAudio() {
        settingAudioSession(toMode: .record)
        audioRecorder?.prepareToRecord()
        audioRecorder?.record()
        isRecording = true
    }
    
    func stopRecording() -> URL? {
        audioRecorder?.stop()
        isRecording = false
        settingAudioSession(toMode: .play)
        
        return url
    }
    
    func playRecordedSound() {
        if isRecording == false {
//            audioPlayer?.stop()
//            audioPlayer?.currentTime = 0
            audioPlayer?.play()
             isPlaying = true
        }
    }
    
    func pausePlayRecorded() {
        if isRecording == false {
            audioPlayer?.pause()
             isPlaying = false
        }
    }
    
    func stopPlaying() {
        if isRecording == false {
            audioPlayer?.stop()
            isPlaying = false
            audioPlayer?.currentTime = 0
        }
    }
    
}

extension AudioRecordHelper: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.didFinishPlaying()
    }
}
