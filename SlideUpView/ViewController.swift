//
//  TestVC.swift
//  Trax
//
//  Created by Orest Patlyka on 3/26/19.
//

import UIKit

final class ViewController: UIViewController {
    
    @IBOutlet weak var testView: UIView!
    @IBOutlet weak var testViewTrailingConstraint: NSLayoutConstraint!

    lazy private var slideUpView = {
        return SlideUpView.loadFromNib(owner: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSlideUpView()
    }
    
    private func setupSlideUpView() {
        testView.addSubview(slideUpView)
        slideUpView.configure(screenCoveringPercentage: 80)
        slideUpView.attachMeToThe(position: .bottom)
    }

}

extension ViewController {
    @IBAction func testButton(_ sender: UIButton) {
        testViewTrailingConstraint.constant = 60
    }
}
