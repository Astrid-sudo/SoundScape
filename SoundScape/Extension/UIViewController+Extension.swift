//
//  UIViewController+Extension.swift
//  SoundScape
//
//  Created by Astrid on 2021/12/5.
//

import UIKit

extension UIViewController {
    
    func popErrorAlert(title: String?, message: String?) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert )
        
        let okButton = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
    
}
