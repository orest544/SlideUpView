//
//  UIRectCorner+CornerMask.swift
//  SlideUpView
//
//  Created by Orest Patlyka on 4/2/19.
//  Copyright © 2019 Orest Patlyka. All rights reserved.
//

import UIKit

extension UIRectCorner {
    
    var maskCorners: [CACornerMask] {
        let rectCorners: [UIRectCorner] = [.bottomLeft, .bottomRight, .topLeft, .topRight]
        
        var masks = [CACornerMask]()
        for rectCorner in rectCorners {
            guard self.contains(rectCorner) else { continue }
            guard let maskCorner = rectCorner.maskCorner else { continue }
            masks.append(maskCorner)
        }
        
        return masks
    }
    
    private var maskCorner: CACornerMask? {
        switch self {
        case _ where self == .topLeft:
            //            masks.append(.layerMinXMinYCorner)
            return .layerMinXMinYCorner
        case _ where self == .topRight:
            //            masks.append(.layerMaxXMinYCorner)
            return .layerMaxXMinYCorner
        case _ where self == .bottomLeft:
            //            masks.append(.layerMinXMaxYCorner)
            return .layerMinXMaxYCorner
        case _ where self == .bottomRight:
            //            masks.append(.layerMaxXMaxYCorner)
            return .layerMaxXMaxYCorner
        default:
            return nil
        }
    }
}
