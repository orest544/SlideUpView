//
//  TestView.swift
//  SlideUpView
//
//  Created by Orest Patlyka on 3/31/19.
//  Copyright © 2019 Orest Patlyka. All rights reserved.
//

import UIKit

class TestView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    private func commonInit() {
//        Bundle.main.loadNibNamed("TestView", owner: self, options: nil)
//        addSubview(contentView)
        //backgroundColor = .black
        
//        contentView.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
        
        let paddings: CGFloat = 20
        
//        NSLayoutConstraint.activate([
//            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: paddings),
//            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -paddings),
//            contentView.topAnchor.constraint(equalTo: topAnchor, constant: paddings),
//            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -paddings)
//        ])
    }

}
