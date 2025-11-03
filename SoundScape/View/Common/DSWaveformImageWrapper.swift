//
//  DSWaveformImageWrapper.swift
//  SoundScape
//
//  Created by Astrid on 2021/11/25.
//

import UIKit
import SwiftUI
import DSWaveformImage
import AVFoundation

// MARK: - Static Waveform View (displays pre-rendered image)

class WaveformImageViewPlaceholder: UIView {
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    var configuration: Waveform.Configuration = Waveform.Configuration(
        size: .zero,
        backgroundColor: .clear,
        style: .filled(.white)
    )
    var shouldDrawSilencePadding: Bool = false

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .clear
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(imageView)
    }

    func reset() {
        image = nil
        imageView.image = nil
    }

    override var bounds: CGRect {
        didSet {
            imageView.frame = bounds
        }
    }
}

// MARK: - Live Waveform View (for real-time recording)

class WaveformLiveViewPlaceholder: UIView {
    var configuration: Waveform.Configuration {
        didSet {
            updateConfiguration()
        }
    }
    var shouldDrawSilencePadding: Bool = false

    private var samples: [Float] = []
    private let maxSamples = 200 // Number of bars to display

    override init(frame: CGRect) {
        self.configuration = Waveform.Configuration(
            size: frame.size,
            backgroundColor: .clear,
            style: .filled(.white)
        )
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        self.configuration = Waveform.Configuration(
            size: .zero,
            backgroundColor: .clear,
            style: .filled(.white)
        )
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = configuration.backgroundColor
        contentMode = .redraw
    }

    private func updateConfiguration() {
        backgroundColor = configuration.backgroundColor
        setNeedsDisplay()
    }

    func reset() {
        samples.removeAll()
        setNeedsDisplay()
    }

    func add(samples newSamples: [Float]) {
        // Add new samples
        samples.append(contentsOf: newSamples)

        // Keep only the most recent samples to avoid memory issues
        if samples.count > maxSamples {
            samples = Array(samples.suffix(maxSamples))
        }

        // Redraw
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard !samples.isEmpty,
              let context = UIGraphicsGetCurrentContext() else {
            return
        }

        context.saveGState()

        // Extract color from configuration
        let color: UIColor
        var barWidth: CGFloat = 3.0
        var barSpacing: CGFloat = 3.5

        switch configuration.style {
        case .filled(let fillColor):
            color = fillColor
        case .gradient(let colors):
            color = colors.first ?? .white
        case .striped(let config):
            color = config.color
            barWidth = config.width
            barSpacing = config.spacing
        @unknown default:
            color = .white
        }

        color.setFill()

        let width = rect.width
        let height = rect.height
        let midY = height / 2

        // Calculate how many bars we can fit
        let barCount = min(samples.count, Int(width / (barWidth + barSpacing)))
        guard barCount > 0 else {
            context.restoreGState()
            return
        }

        // Use the most recent samples
        let displaySamples = Array(samples.suffix(barCount))

        // Draw each sample as a vertical bar
        for (index, sample) in displaySamples.enumerated() {
            let xPosition = CGFloat(index) * (barWidth + barSpacing)
            let normalizedSample = min(abs(sample), 1.0) // Clamp to [0, 1]
            let barHeight = CGFloat(normalizedSample) * height * 0.8 // 80% of height

            let barRect = CGRect(
                x: xPosition,
                y: midY - barHeight / 2,
                width: barWidth,
                height: max(2, barHeight) // Minimum height of 2
            )

            let path = UIBezierPath(roundedRect: barRect, cornerRadius: barWidth / 2)
            path.fill()
        }

        context.restoreGState()
    }

    override var bounds: CGRect {
        didSet {
            if bounds.size != oldValue.size {
                configuration = Waveform.Configuration(
                    size: bounds.size,
                    backgroundColor: configuration.backgroundColor,
                    style: configuration.style
                )
            }
        }
    }
}

// MARK: - Main Wrapper Class

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

    // Returns waveform view that displays static audio file
    func createWaveformImageView(frame: CGRect) -> WaveformImageViewPlaceholder {
        let view = WaveformImageViewPlaceholder(frame: frame)
        view.backgroundColor = .clear
        return view
    }

    // Returns live waveform view for recording
    func createWaveformLiveView(frame: CGRect) -> WaveformLiveViewPlaceholder {
        let view = WaveformLiveViewPlaceholder(frame: frame)
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
