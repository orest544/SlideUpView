//
//  TestVC.swift
//  Trax
//
//  Created by Orest Patlyka on 3/26/19.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var testView: UIView!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!

    var slideUpView: SlideUpView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSlideUpView()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        setupSlideUpView()
//    }

    private func setupSlideUpView() {
        testView.translatesAutoresizingMaskIntoConstraints = false
        slideUpView = SlideUpView.loadFromNib(owner: self)
        //testView.addSubview(slideUpView)
        view.addSubview(slideUpView)
        slideUpView.configure(screenCoveringPercentage: 70)
        slideUpView.attachMeToThe(position: .bottom)
    }
    
    private func addTestView() {
        let testView = Bundle.main.loadNibNamed("TestView", owner: self, options: nil)?.first as! UIView
        //testView.backgroundColor = .red
        testView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(testView)
        
        NSLayoutConstraint.activate([
            testView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            testView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            testView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            testView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }

}

extension ViewController {
    @IBAction func testButton(_ sender: UIButton) {
        print("Test tapped")
        trailingConstraint.constant = 60
        testView.layoutIfNeeded()
        slideUpView.layoutIfNeeded()
        slideUpView.updateConstraints()
    }
}
