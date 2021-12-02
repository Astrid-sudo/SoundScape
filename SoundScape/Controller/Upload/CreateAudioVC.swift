//
//  CreateAudioVC.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/19.
//

import UIKit
import UniformTypeIdentifiers

class CreateAudioVC: UIViewController {

    private let animationView = LottieWrapper.shared.createLottieAnimationView(lottieType: .waveformBounce,
                                                                               frame: CGRect(x: 0,
                                                                                             y: 100,
                                                                                             width: CommonUsage.screenWidth,
                                                                                             height: 200))

    private lazy var recordButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(named: CommonUsage.scWhite), for: .normal)
        button.addTarget(self, action: #selector(goRecordPage), for: .touchUpInside)
        button.backgroundColor = UIColor(named: CommonUsage.scLightBlue)
        button.layer.cornerRadius = 15
        button.setTitle(CommonUsage.Text.record, for: .normal)
        return button
    }()
    
    private lazy var selectFileButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(named: CommonUsage.scWhite), for: .normal)
        button.addTarget(self, action: #selector(selectDocument), for: .touchUpInside)
        button.backgroundColor = UIColor(named: CommonUsage.scLightBlue)
        button.layer.cornerRadius = 15
        button.setTitle(CommonUsage.Text.selectFile, for: .normal)
        return button
    }()

    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: CommonUsage.scBlue)
        setNavigationBar()
        addLottie()
        setSelectFileButton()
        setRecordButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animationView.play()

        AudioPlayerWindow.shared.window?.isHidden = true
        if AudioPlayHelper.shared.isPlaying {
            AudioPlayHelper.shared.stop()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        animationView.stop()
    }
    
    // MARK: - action
    
    @objc func selectDocument() {
        if #available(iOS 14.0, *) {
            let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.mpeg4Audio], asCopy: true)
            
            controller.delegate = self
            present(controller, animated: true, completion: nil)
            
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    @objc func goRecordPage() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let recordVC = storyboard.instantiateViewController(withIdentifier:
                                                                    RecordVC.reuseIdentifier) as? RecordVC else { return }
        navigationController?.pushViewController(recordVC, animated: true)
    }
    
    // MARK: - method
    
    private func setNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.title = CommonUsage.Text.upload
        navigationController?.navigationBar.barTintColor = UIColor(named: CommonUsage.scBlue)
        let font = UIFont(name: CommonUsage.fontBungee, size: 28)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font,
                                                                   NSAttributedString.Key.foregroundColor: UIColor(named: CommonUsage.scWhite)]
    }

    private func addLottie() {
        view.addSubview(animationView)
    }
    
    private func setSelectFileButton() {
        view.addSubview(selectFileButton)
        selectFileButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectFileButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48),
            selectFileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48),
            selectFileButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            selectFileButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setRecordButton() {
        view.addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48),
            recordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48),
            recordButton.bottomAnchor.constraint(equalTo: selectFileButton.topAnchor, constant: -16),
            recordButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
}

// MARK: - conform to UIDocumentPickerDelegate

extension CreateAudioVC: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        if let url = urls.last {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let editVC = storyboard.instantiateViewController(withIdentifier: "EditVC") as? EditVC else { return }
            editVC.selectedFileURL = url
            editVC.originDuraion = AudioPlayHelper.shared.duration
            navigationController?.pushViewController(editVC, animated: true)
        }
    }
    
}
