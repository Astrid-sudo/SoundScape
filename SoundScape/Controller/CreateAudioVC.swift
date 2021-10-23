//
//  CreateAudioVC.swift
//  SoundScape
//
//  Created by Astrid on 2021/10/19.
//

import UIKit
import UniformTypeIdentifiers


class CreateAudioVC: UIViewController {
    
    // MARK: - properties
    
    
    // MARK: - UI properties
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: CommonUsage.scBlue)
        
    }
    
    // MARK: - UI method
    
    // MARK: - action
    
    @IBAction func selectFile(_ sender: Any) {
        if #available(iOS 14.0, *) {
            let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.audio], asCopy: true)
            
            controller.delegate = self
            present(controller, animated: true, completion: nil)

        } else {
            // Fallback on earlier versions
        }
        
    }
}

extension CreateAudioVC: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            
        if let url = urls.first {
            print(url)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let uploadVC = storyboard.instantiateViewController(withIdentifier: "UploadVC") as? UploadVC else { return }
            uploadVC.selectedFileURL = url
            navigationController?.pushViewController(uploadVC, animated: true)

        }
        

    }
    
}
