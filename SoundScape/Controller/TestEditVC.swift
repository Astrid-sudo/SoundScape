//
//  EditVC.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/23.
//

import UIKit
import AVFoundation


class TestEditVC: UIViewController {
    
    @IBOutlet weak var startTimeHoursTextfield: UITextField!
    @IBOutlet weak var startTimeMinutesTextField: UITextField!
    @IBOutlet weak var startTimeSecondsTextField: UITextField!
    
    @IBOutlet weak var finalTimeHoursTextField: UITextField!
    @IBOutlet weak var finalTimeMinutesTextField: UITextField!
    @IBOutlet weak var finalSecondsTimeTextField: UITextField!

    var asset:  AVURLAsset?
    
    let outputFileName = "output"
    
    var originalURL: URL? {
        didSet {
            guard let originalURL = originalURL else {
                return
            }
            asset = AVURLAsset(url: originalURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey : true])
        }
    }
    
    var outputURL: URL?

    
    @IBAction func trimAudioAction(_ sender: Any) {
        
        guard let asset = asset else {
            return
        }


        var startTime : Float?
        var finalTime : Float?

        let startTimeHoursText = startTimeHoursTextfield.text ?? "00"
        let startTimeMinutesText = startTimeMinutesTextField.text ?? "00"
        let startTimeSecondsText = startTimeSecondsTextField.text ?? "00"
        let finalTimeHoursText = finalTimeHoursTextField.text ?? "00"
        let finalTimeMinutesText = finalTimeMinutesTextField.text ?? "00"
        let finalTimeSecondsText = finalSecondsTimeTextField.text ?? "00"
        
        let startTimeHours = Float(startTimeHoursText)
        let startTimeMinutes = Float(startTimeMinutesText)
        let startTimeSeconds = Float(startTimeSecondsText)
        
        let finalTimeHours = Float(finalTimeHoursText)
        let finalTimeMinutes = Float(finalTimeMinutesText)
        let finalTimeSeconds = Float(finalTimeSecondsText)

        if let startTimeHours = startTimeHours{
            startTime = startTimeHours  * 60.0
        }

        if let startTimeMinutes = startTimeMinutes{
            startTime =  (startTime ?? 0)  *  60.0 + startTimeMinutes *  60.0
        }

        if let startTimeSeconds = startTimeSeconds{
            startTime = (startTime ?? 0) + startTimeSeconds
        }

        if let finalTimeHours = finalTimeHours{
            finalTime = (finalTimeHours  *  60.0)
        }

        if let finalTimeMinutes = finalTimeMinutes{
            finalTime = (finalTime ?? 0)  *  60.0 + finalTimeMinutes  *  60.0
        }

        if let finalTimeSeconds = finalTimeSeconds{
            finalTime = (finalTime ?? 0) + finalTimeSeconds
        }
        
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        print("oriigin audio length: \(length) seconds")
        
        
        let fileManager = FileManager.default
        
        guard let documentDirectory = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { return }
        
        var outputURL = documentDirectory.appendingPathComponent("output")
        do {
            try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            
            outputURL = outputURL.appendingPathComponent("\(outputFileName).m4a")
        }catch let error {
            print(error)
        }
        
        //Remove previous existing file
        _ = try? fileManager.removeItem(at: outputURL)

        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {return}

        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.m4a
        
        self.outputURL = outputURL
        
        let start = startTime
        let end = finalTime
        
        let startTimeRange = CMTime(seconds: Double(start ?? 0), preferredTimescale: 1000)
        let endTimeRange = CMTime(seconds: Double(end ?? length), preferredTimescale: 1000)
        let timeRange = CMTimeRange(start: startTimeRange, end: endTimeRange)
        
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously{
            switch exportSession.status {
            case .completed:
                print("exported at \(outputURL)")
            case .failed:
                print("failed \(String(describing: exportSession.error))")
            case .cancelled:
                print("cancelled \(String(describing: exportSession.error))")
            default:
                break
            }
        }
    }
    
    @IBAction func playTrimmedAudio() {
        
        guard let outputURL = outputURL else {
            print("No out put URL")
            return
        }

        
        AudioPlayHelper.shared.url = outputURL
        
        AudioPlayHelper.shared.play()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

