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
    
    func createWaveformImageView(frame: CGRect) ->  WaveformImageView {
       return  WaveformImageView(frame: frame)
    }
    
    func initWaveformImageDrawer() -> WaveformImageDrawer {
        return WaveformImageDrawer()
        
    }
    
    func configWaveformStripe(color: UIColor?,
                        width: CGFloat,
                        spacing: CGFloat,
                        lineCap: CGLineCap) -> Waveform.Style.StripeConfig {
        
        return Waveform.Style.StripeConfig.init(color: color ?? .white,
                                                     width: width,
                                                     spacing: spacing,
                                                     lineCap: lineCap)
    }
    

}
