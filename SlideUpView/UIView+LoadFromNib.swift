//
//  UIView+NibLoadable.swift
//  SlideUpView
//
//  Created by Orest Patlyka on 4/2/19.
//  Copyright © 2019 Orest Patlyka. All rights reserved.
//

import UIKit

protocol NibLoadable: AnyObject {
    static func loadFromNib(owner: Any?) -> Self
}

extension NibLoadable {
    static func loadFromNib(owner: Any?) -> Self {
        return Bundle.main.loadNibNamed(String(describing: Self.self),
                                        owner: owner,
                                        options: nil)?.first as! Self
    }
}
