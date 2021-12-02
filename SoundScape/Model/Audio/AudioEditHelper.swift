//
//  AudioEditHelper.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/24.
//

import AVFoundation

protocol EditAudioManagerDelegate: AnyObject {
    func didExport(to url: URL)
}

class AudioEditHelper {
    
    static let shared = AudioEditHelper()
    
    // MARK: - Trim
    
    private var asset: AVURLAsset?
    
    private let outputFileName = "output"
    
    weak var delegate: EditAudioManagerDelegate?
    
    private var audioFile: AVAudioFile?
    
    private var format: AVAudioFormat?
    
    var originalURL: URL? {
        didSet {
            guard let originalURL = originalURL else {
                return
            }
            asset = AVURLAsset(url: originalURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        }
    }
    
    var outputURL: URL?
    
    private init () {}
    
    func trimAudio(from head: Double, to tail: Double) {
        
        guard let asset = asset else {
            return
        }
        
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        print("message from AudioEditHelper: oriigin audio length: \(length) seconds")
        
        let startTime = head
        let finalTime = tail
        
        let fileManager = FileManager.default
        
        guard let documentDirectory = try? fileManager.url(for: .documentDirectory,
                                                              in: .userDomainMask,
                                                              appropriateFor: nil,
                                                              create: true) else { return }
        
        var outputURL = documentDirectory.appendingPathComponent("output")
        do {
            try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            
            outputURL = outputURL.appendingPathComponent("\(outputFileName).m4a")
        } catch let error {
            print(error)
        }
        
        // Remove previous existing file
        _ = try? fileManager.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset,
                                                       presetName: AVAssetExportPresetAppleM4A) else {return}
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.m4a
        
        self.outputURL = outputURL
        
        let start = startTime
        let end = finalTime
        
        let startTimeRange = CMTime(seconds: start, preferredTimescale: 1000)
        let endTimeRange = CMTime(seconds: end, preferredTimescale: 1000)
        let timeRange = CMTimeRange(start: startTimeRange, end: endTimeRange)
        
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously { [weak self] in
            guard let self = self else { return }
            switch exportSession.status {
            case .completed:
                print("exported at \(outputURL)")
                if let outputURL = self.outputURL {
                    self.delegate?.didExport(to: outputURL)
                }
            case .failed:
                print("failed \(String(describing: exportSession.error))")
            case .cancelled:
                print("cancelled \(String(describing: exportSession.error))")
            default:
                break
            }
        }
    }
    
}

