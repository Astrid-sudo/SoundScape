//
//  DSWaveformImageWrapper.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/25.
//

import UIKit
import SwiftUI
import DSWaveformImage

// Temporary placeholder class that mimics old WaveformImageView API
class WaveformImageViewPlaceholder: UIView {
    var image: UIImage?
    var configuration: Waveform.Configuration = Waveform.Configuration(
        size: .zero,
        backgroundColor: .clear,
        style: .filled(.white)
    )
    var shouldDrawSilencePadding: Bool = false

    func reset() {
        image = nil
    }
}

// Temporary placeholder class that mimics old WaveformLiveView API
class WaveformLiveViewPlaceholder: UIView {
    var configuration: Waveform.Configuration = Waveform.Configuration(
        size: .zero,
        backgroundColor: .clear,
        style: .filled(.white)
    )
    var shouldDrawSilencePadding: Bool = false

    func reset() {
        // Placeholder
    }

    func add(samples: [Float]) {
        // Placeholder - in real implementation this would update the waveform
    }
}

class DSWaveformImageWrapper {

    static let shared = DSWaveformImageWrapper()

    private init () {}

    func initWaveformAnalyzer(audioAssetURL: URL) -> WaveformAnalyzer? {
        let waveformAnalyzer = WaveformAnalyzer()
        Task {
            let samples = try? await waveformAnalyzer.samples(fromAudioAt: audioAssetURL, count: 10)
            print("sampled down to 10, results are \(samples ?? [])")
        }
        return waveformAnalyzer
    }

    func initWaveformImageDrawer() -> WaveformImageDrawer {
        return WaveformImageDrawer()
    }

    // Returns placeholder waveform view
    // TODO: Integrate DSWaveformImage 14.x SwiftUI views properly
    func createWaveformImageView(frame: CGRect) -> WaveformImageViewPlaceholder {
        let view = WaveformImageViewPlaceholder(frame: frame)
        view.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        return view
    }

    // Returns placeholder live waveform view
    // TODO: Integrate DSWaveformImage 14.x SwiftUI views properly
    func createWaveformLiveView(frame: CGRect) -> WaveformLiveViewPlaceholder {
        let view = WaveformLiveViewPlaceholder(frame: frame)
        view.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        return view
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

    func configWaveform(waveformImageView: WaveformImageViewPlaceholder,
                        config: Waveform.Style.StripeConfig) -> Waveform.Configuration {
        let waveformConfiguration = Waveform.Configuration(size: waveformImageView.bounds.size,
                                                           backgroundColor: .clear,
                                                           style: .striped(config))
        return waveformConfiguration
    }

}
