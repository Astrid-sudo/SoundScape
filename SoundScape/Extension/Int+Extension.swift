//
//  Int+Extension.swift
//  SoundScape
//
//  Created by Astrid on 2021/12/5.
//

import UIKit

extension Int {
    
    var adjusted: CGFloat {
        
        return CGFloat(self) * UIProperties.ratio
    }
}
