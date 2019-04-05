//
//  HelpfulMethods.swift
//  SlideUpView
//
//  Created by Orest Patlyka on 4/4/19.
//  Copyright © 2019 Orest Patlyka. All rights reserved.
//

public func resultOf<T>(_ code: () -> T) -> T {
    return code()
}
