//
//  TestVC.swift
//  Trax
//
//  Created by Orest Patlyka on 3/26/19.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var testView: UIView!
    @IBOutlet weak var testViewTrailingConstraint: NSLayoutConstraint!

    var slideUpView: SlideUpView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSlideUpView()
    }

    private func setupSlideUpView() {
        testView.translatesAutoresizingMaskIntoConstraints = false
        slideUpView = SlideUpView.loadFromNib(owner: self)
    
        //testView.addSubview(slideUpView)
        testView.addSubview(slideUpView)
        slideUpView.configure(screenCoveringPercentage: 70)
        slideUpView.attachMeToThe(position: .bottom)
    }

}

extension ViewController {
    @IBAction func testButton(_ sender: UIButton) {
        print("Test tapped")
        testViewTrailingConstraint.constant = 60
    }
}
