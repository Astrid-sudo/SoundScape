//
//  CGFloat+Extension.swift
//  SoundScape
//
//  Created by Astrid on 2021/12/5.
//

import UIKit

extension CGFloat {
    
    var adjusted: CGFloat {
        
        return self * UIProperties.ratio
    }
}
