//
//  AudioHelper.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/18.
//

import Foundation
import AVFoundation

enum AudioSessionMode {
    case record
    case play
}

class AudioHelper: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
        // MARK: - properties
    
    static let shared = AudioHelper()
    
    var audioRecorder: AVAudioRecorder?
    
    var audioPlayer: AVAudioPlayer?
    
    var isRecording = false
    
    var isPlaying = false
    
    var currentTime: Double {
        guard let audioPlayer = audioPlayer else {
            return 0.0
        }
        return audioPlayer.currentTime
    }
    
    var duration: Double {
        guard let audioPlayer = audioPlayer else {
            return 0.0
        }
        return audioPlayer.duration
    }
    
    var url: URL? {
        didSet {
            guard let url = url else { return }
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
            } catch {
                print("fail to create AVAudioPlayer")
            }
        }
    }
    
    // MARK: - init
    
    private override init() {
        super.init()
        
        //init an audio recorder
        //        let filename = "User.wav"
        //        let path = NSHomeDirectory() + "/Documents/" + filename
        //        self.url = URL(fileURLWithPath: path)
        //        let recordSettings:[String:Any] = [
        //            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
        //            AVEncoderBitRateKey: 16,
        //            AVNumberOfChannelsKey: 2,
        //            AVSampleRateKey:44100.0
        //        ]
        
        //        guard let url = self.url else { return }
        //
        //        do{
        //            audioRecorder = try AVAudioRecorder(url: url, settings: recordSettings)
        //            audioRecorder?.delegate = self
        //        }catch{
        //            print(error.localizedDescription)
        //        }
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
    
    func play() {
        if isRecording == false {
            audioPlayer?.play()
            isPlaying = true
        }
    }
    
    func stop() {
        if isRecording == false {
            audioPlayer?.stop()
            isPlaying = false
            audioPlayer?.currentTime = 0
        }
    }
    
    func pause() {
        if isRecording == false {
            audioPlayer?.pause()
            isPlaying = false
        }
    }
    
}

