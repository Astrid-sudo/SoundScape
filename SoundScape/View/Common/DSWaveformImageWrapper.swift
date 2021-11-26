//
//  DSWaveformImageWrapper.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/25.
//

import UIKit
import DSWaveformImage

class DSWaveformImageWrapper {
    
    static let shared = DSWaveformImageWrapper()
    
    private init () {}
    
    func initWaveformAnalyzer(audioAssetURL: URL) -> WaveformAnalyzer? {
        let waveformAnalyzer = WaveformAnalyzer(audioAssetURL: audioAssetURL)
        waveformAnalyzer?.samples(count: 10) { samples in
            print("sampled down to 10, results are \(samples ?? [])")
        }
        return waveformAnalyzer
    }
    
    func initWaveformImageDrawer() -> WaveformImageDrawer {
        return WaveformImageDrawer()
    }
    
    func createWaveformImageView(frame: CGRect) ->  WaveformImageView {
        return  WaveformImageView(frame: frame)
    }
    
    func createWaveformLiveView(frame: CGRect) -> WaveformLiveView {
        return WaveformLiveView(frame: frame)
    }
    
    func configWaveformStripe(color: UIColor?,
                              width: CGFloat,
                              spacing: CGFloat,
                              lineCap: CGLineCap) -> Waveform.Style.StripeConfig {
        let waveformStripeConfiguration = Waveform.Style.StripeConfig.init(color: color ?? .white,
                                                                           width: width,
                                                                           spacing: spacing,
                                                                           lineCap: lineCap)
        return waveformStripeConfiguration
    }
    
    func configWaveform(waveformImageView: WaveformImageView,
                        config: Waveform.Style.StripeConfig) -> Waveform.Configuration {
        let waveformConfiguration = Waveform.Configuration(size: waveformImageView.bounds.size,
                                                           backgroundColor: .clear,
                                                           style: .striped(config))
        return waveformConfiguration
    }
    
}
