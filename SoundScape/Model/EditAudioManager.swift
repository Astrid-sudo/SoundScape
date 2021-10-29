//
//  EditAudioManager.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/24.
//

import AVFoundation

protocol EditAudioManagerDelegate: AnyObject {
    func didExport(to url: URL)
}

class EditAudioManager {
    
    static let shared = EditAudioManager()
    
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
            
            prepareEQ(fileURL: originalURL)
            
        }
    }
    
    var outputURL: URL?
    
    // MARK: - EQ
    
    private let engine = AVAudioEngine()
    private let renderEngine = AVAudioEngine()
   
    private let player = AVAudioPlayerNode()
    private let renderPlayer = AVAudioPlayerNode()

    private let aVAudioUnitEQ = AVAudioUnitEQ(numberOfBands: 1)
    private let renderUnitEQ = AVAudioUnitEQ(numberOfBands: 1)
    
    private var buffer: AVAudioPCMBuffer?
    private var outputFile: AVAudioFile?
    
    private var needsRenderFileScheduled = true
    private var needsFileScheduled = true
    private var isPlayerReady = false
    var highPassOn = false
    
    private init () {}
    
    func trimAudio(from head: Double, to tail: Double) {
        
        guard let asset = asset else {
            return
        }
        
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        print("message from EditAudioManager: oriigin audio length: \(length) seconds")
        
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
        
        //Remove previous existing file
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
    
    private func prepareEQ(fileURL: URL) {
        do {
            let file = try AVAudioFile(forReading: fileURL)
            format = file.processingFormat
            
            //          audioLengthSamples = file.length
            //          audioSampleRate = format.sampleRate
            //          audioLengthSeconds = Double(audioLengthSamples) / audioSampleRate
            
            audioFile = file
            
            if let format = format {
                configPlaybackEngine(with: format)
                setRenderEngine(with: format)            }
            
        } catch {
            print("Error reading the audio file: \(error.localizedDescription)")
        }
        
    }
    
    private func configPlaybackEngine(with format: AVAudioFormat) {
        
        aVAudioUnitEQ.bands[0].bandwidth = 1
        aVAudioUnitEQ.bands[0].filterType = .lowShelf
        aVAudioUnitEQ.bands[0].frequency = 200
        aVAudioUnitEQ.bands[0].gain = -96
        
        aVAudioUnitEQ.bypass = true
        aVAudioUnitEQ.bands[0].bypass = false
        
        engine.attach(player)
        engine.attach(aVAudioUnitEQ)
        
        engine.connect(player, to: aVAudioUnitEQ, format: format)
        engine.connect(aVAudioUnitEQ, to: engine.mainMixerNode, format: format)
        engine.prepare()
        
        do {

            try engine.start()
            
            scheduleAudioFile()
            isPlayerReady = true
        } catch {
            print("Error starting the player: \(error.localizedDescription)")
        }
    }
    
    private func scheduleAudioFile() {
        guard let file = audioFile,
              needsFileScheduled else { return }
        
        needsFileScheduled = false
        
        player.scheduleFile(file, at: nil) {
            self.needsFileScheduled = true
        }
    }
    
    private func scheduleAudioFileToRender() {
        guard let file = audioFile,
              needsRenderFileScheduled
             else { return }
        
        
        renderPlayer.scheduleFile(file, at: nil) {
            self.needsRenderFileScheduled = true
        }
    }

    
    func manipulateHighPass() {
        
        if highPassOn {
            
            highPassOn.toggle()
            aVAudioUnitEQ.bypass = true
            
        } else {
            
            highPassOn.toggle()
            aVAudioUnitEQ.bypass = false
            
        }
        
    }
    
    func manipulatePlay() {
        if player.isPlaying == false {
            
            if needsFileScheduled {
                scheduleAudioFile()
            }
            
            player.play()
            
        } else {
            
            player.pause()
        }
    }
    
    func renderEQtoFile(completion: @escaping (_ url: URL) -> Void) {
        engine.stop()
//        setRenderEngine()
        prepareDestination()
        renderAudioManually(completion: completion)
    }
    
    // Enable Offline Manual Rendering Mode
    
    private func setRenderEngine(with format: AVAudioFormat) {
        
        renderUnitEQ.bands[0].bandwidth = 1
        renderUnitEQ.bands[0].filterType = .lowShelf
        renderUnitEQ.bands[0].frequency = 200
        renderUnitEQ.bands[0].gain = -96
        
        renderUnitEQ.bypass = !highPassOn
        renderUnitEQ.bands[0].bypass = false
        
        renderEngine.attach(renderPlayer)
        renderEngine.attach(renderUnitEQ)
        
        renderEngine.connect(renderPlayer, to: renderUnitEQ, format: format)
        renderEngine.connect(renderUnitEQ, to: renderEngine.mainMixerNode, format: format)

        do {
            // The maximum number of frames the engine renders in any single render call.
            let maxFrames: AVAudioFrameCount = 4096
                try renderEngine.enableManualRenderingMode(.offline, format: format,
                                                     maximumFrameCount: maxFrames)
            
            try renderEngine.start()
            scheduleAudioFileToRender()

        } catch {
            fatalError("Enabling manual rendering mode failed: \(error).")
        }
        
    }
    
    //    Prepare the Output Destinations
    
    private func prepareDestination() {
        
        buffer = AVAudioPCMBuffer(pcmFormat: renderEngine.manualRenderingFormat,
                                  frameCapacity: renderEngine.manualRenderingMaximumFrameCount)
        
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let outputURL = documentsURL.appendingPathComponent("soundscape.m4a")
            
            guard let audioFile = audioFile else { return }
            
            outputFile = try AVAudioFile(forWriting: outputURL, settings: audioFile.fileFormat.settings)
        } catch {
            fatalError("Unable to open output audio file: \(error).")
            
        }
        
    }
    
    //    Manually Render the Audio
    
    private func renderAudioManually(completion: @escaping (_ url: URL) -> Void) {
        
        guard let audioFile = audioFile,
              let buffer = buffer,
              let outputFile = outputFile else { return }
        
        while renderEngine.manualRenderingSampleTime < audioFile.length {
            do {
                let frameCount = audioFile.length - renderEngine.manualRenderingSampleTime
                let framesToRender = min(AVAudioFrameCount(frameCount), buffer.frameCapacity)
                
                let status = try renderEngine.renderOffline(framesToRender, to: buffer)
                
                switch status {
                    
                case .success:
                    // The data rendered successfully. Write it to the output file.
                    try outputFile.write(from: buffer)
                    
                case .insufficientDataFromInputNode:
                    // Applicable only when using the input node as one of the sources.
                    break
                    
                case .cannotDoInCurrentContext:
                    // The engine couldn't render in the current render call.
                    // Retry in the next iteration.
                    break
                    
                case .error:
                    // An error occurred while rendering the audio.
                    fatalError("The manual rendering failed.")
                }
            } catch {
                fatalError("The manual rendering failed: \(error).")
            }
        }
        
        if  renderEngine.manualRenderingSampleTime == audioFile.length {
            completion(outputFile.url)
            print("successfully export EQed file \(outputFile.url)")

        }
        
    }
    
}

