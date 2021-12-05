//
//  UIProperties.swift
//  SoundScape
//
//  Created by Astrid on 2021/12/5.
//

import Foundation
import UIKit

struct UIProperties {
    
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
    static let base: CGFloat = 375
    static var ratio: CGFloat {
        return screenWidth / base
    }
    
    static let safeAreaHeight = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 45.adjusted
    
    static var tabBarHeight: CGFloat {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let sCTabBarController = storyboard.instantiateViewController(identifier: "SCTabBarController") as? SCTabBarController else { return 0 }
        let tabBarHeight = sCTabBarController.tabBar.frame.size.height
        return tabBarHeight
    }
    
    static var audioImages: [UIImage?] = [UIImage(named: Constant.animalDog),
                                          UIImage(named: Constant.animalCat),
                                          UIImage(named: Constant.animalCatPaw),
                                          UIImage(named: Constant.animalDuck),
                                          UIImage(named: Constant.city),
                                          UIImage(named: Constant.meaningfulCake),
                                          UIImage(named: Constant.meaningfulFlower),
                                          UIImage(named: Constant.meaningfulWine),
                                          UIImage(named: Constant.natureMountain),
                                          UIImage(named: Constant.natureOcean),
                                          UIImage(named: Constant.natureRiver),
                                          UIImage(named: Constant.uniqueRice),
                                          UIImage(named: Constant.untitledArtwork),
                                          UIImage(named: Constant.cityCafe)
    ]
    
}

protocol ReuseID {}
protocol CellReuseID: ReuseID {}
protocol StoryboardID: ReuseID {}

extension ReuseID {
    
    static var reuseIdentifier: String {
        get {
            String(describing: self)
        }
    }
}

extension UICollectionReusableView: CellReuseID {}
extension UITableViewCell: CellReuseID {}
extension UITableViewHeaderFooterView: CellReuseID {}
extension UIViewController: StoryboardID {}
