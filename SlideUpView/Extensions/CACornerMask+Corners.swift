//
//  CACornerMask+Corners.swift
//  SlideUpView
//
//  Created by Orest Patlyka on 4/4/19.
//  Copyright © 2019 Orest Patlyka. All rights reserved.
//

import QuartzCore

extension CACornerMask {
    static var allCorners: CACornerMask {
        return [.layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner]
    }
    
    static var topCorners: CACornerMask {
        return [.layerMinXMinYCorner,
                .layerMaxXMinYCorner]
    }
    
    static var bottomCorners: CACornerMask {
        return [.layerMinXMaxYCorner,
                .layerMaxXMaxYCorner]
    }
}
