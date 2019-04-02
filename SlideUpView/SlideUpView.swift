//
//  SlideUpViewVC.swift
//  Trax
//
//  Created by Orest Patlyka on 3/26/19.
//

import UIKit

enum CardState {
    case expanded
    case collapsed
    
    var inversed: CardState {
        switch self {
        case .collapsed:
            return .expanded
        case .expanded:
            return .collapsed
        }
    }
    
}

enum AttachedPosition {
    case top
    case bottom
}

final class SlideUpView: UIView, NibLoadable {
    
    // MARK: - IBOutlets
    
    //@IBOutlet private var contentView: UIView!
    @IBOutlet private weak var handleArea: UIView!
    
    // MARK: - Client interface
    
    /// Multiplier of height to triger collapse actions (value from 0 to 1.0)
    var minimumMultiplierForCollapse: CGFloat = 0.8
    /// Multiplier of height to triger collapse actions (value from 0 to 1.0)
    var minimumMultiptierForExpande: CGFloat = 0.2
    
    var notHidenAreaHeight: CGFloat = 60
    
    /// Can be changed (for example: [.bottomLeft, .bottomRight])
    var roundedCorners: UIRectCorner = [.topLeft, .topRight]
    var cornerRadius: CGFloat = 60
    
    var animationDuration: TimeInterval = 0.6
    
    // MARK: - Private staff
    
    private var slideUpViewHeight: CGFloat!
    private var slideUpViewHeightConstraint: NSLayoutConstraint!
    
    private var runningAnimation: UIViewPropertyAnimator?
    
    // TODO: Change to enum state
    private var isCardVisible = false
    
    private var collapsingCondition: Bool {
        return isCardVisible && slideUpViewHeightConstraint.constant < slideUpViewHeight * minimumMultiplierForCollapse
    }

    private var expandingCondition: Bool {
        return !isCardVisible && slideUpViewHeightConstraint.constant > slideUpViewHeight * minimumMultiptierForExpande + notHidenAreaHeight
    }
    
    private var nextState: CardState {
        // TODO: Think
        switch 0 {
        case _ where collapsingCondition == true:
            return .collapsed
        case _ where expandingCondition == true:
            return .expanded
        default:
            return isCardVisible ? .expanded: .collapsed
        }
    }
    
    private var nextStateForTapped: CardState {
        return nextState.inversed
    }
    
    private var slideUpViewContentHeight: CGFloat {
        return slideUpViewHeight - notHidenAreaHeight
    }
    
    // MARK: - Init and configuring
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    private func commonInit() {
        configureXib()
        configureView()
    }

    private func configureXib() {
//        Bundle.main.loadNibNamed(String(describing: type(of: self)),
//                                 owner: self,
//                                 options: nil)
//        addSubview(contentView)
        
       // contentView.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        superview?.translatesAutoresizingMaskIntoConstraints = false
        
//        NSLayoutConstraint.activate([
//            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
//            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
//            trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
//            bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
//        ])
    }
    
    private func configureView() {
        clipsToBounds = true
        
        layer.cornerRadius = cornerRadius
        if #available(iOS 11.0, *) {
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            roundCorners(corners: roundedCorners, radius: cornerRadius)
        }

        addGestures()
    }
    
    private func addGestures() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(recognzier:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCardPan(recognizer:)))
        
        handleArea.addGestureRecognizer(tapGestureRecognizer)
        handleArea.addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: - Client methods
    
    // TODO: Think and rename
    func configure(screenCoveringPercentage: CGFloat) {
        guard let superView = superview else { return }
        guard CGFloat(0)...CGFloat(100) ~= screenCoveringPercentage else { return }
        
        slideUpViewHeight = superView.frame.height * screenCoveringPercentage / 100
    }
    
    func attachMeToThe(position: AttachedPosition) {
        guard let superView = superview else { return }
        
        var attachedTo: NSLayoutYAxisAnchor!
        switch position {
        case .top:
            attachedTo = superView.topAnchor
        case .bottom:
            attachedTo = superView.bottomAnchor
        }
        
        let bottomConstraint = bottomAnchor.constraint(equalTo: attachedTo, constant: 0)
        slideUpViewHeightConstraint = heightAnchor.constraint(equalToConstant: notHidenAreaHeight)

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 0),
            trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: 0),
            bottomConstraint,
            slideUpViewHeightConstraint
        ])
    }

    
    //////
    @objc
    func handleCardTap(recognzier: UITapGestureRecognizer) {
        switch recognzier.state {
        case .ended:
            animateTransitionIfNeeded(state: nextStateForTapped, duration: animationDuration)
        default:
            break
        }
    }
    
    @objc
    func handleCardPan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            let translation = recognizer.translation(in: handleArea)
            var fractionComplete = translation.y / slideUpViewHeight
            fractionComplete = isCardVisible ? fractionComplete : -fractionComplete
            changeHeightConstraint(by: fractionComplete)
        case .ended:
//            let duration = calculateAnimationDuration(for: nextState)
            animateTransitionIfNeeded(state: nextState, duration: animationDuration)
        default:
            break
        }
    }
    
    func animateTransitionIfNeeded(state: CardState, duration: TimeInterval) {
        guard runningAnimation == nil else { return }
        
        handleArea.isUserInteractionEnabled = false
        
        let heightAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .expanded:
                self.slideUpViewHeightConstraint.constant = self.slideUpViewHeight
            case .collapsed:
                self.slideUpViewHeightConstraint.constant = self.notHidenAreaHeight
            }
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        }
        
        heightAnimator.addCompletion { _ in
            self.isCardVisible = self.slideUpViewHeightConstraint.constant > self.notHidenAreaHeight
            self.runningAnimation = nil
            self.handleArea.isUserInteractionEnabled = true
        }
        
        heightAnimator.startAnimation()
        runningAnimation = heightAnimator
    }
    
    func changeHeightConstraint(by multiplier: CGFloat) {
        guard CGFloat(0)...CGFloat(1) ~= multiplier else {
            print("warning negative value!")
            return
        }
        
        let moveUpValue = (slideUpViewHeight * multiplier) + notHidenAreaHeight
        let moveDownValue = slideUpViewHeight - (slideUpViewHeight * multiplier)
        slideUpViewHeightConstraint.constant = isCardVisible ? moveDownValue : moveUpValue
    }
    
    func calculateAnimationDuration(for nextState: CardState) -> TimeInterval {
        let standartAnimationDuration: TimeInterval = 0.6
        
        let movedAreaHeight = slideUpViewHeight - handleArea.frame.height
        
        var distanceToEndAnimation = CGFloat(0)
        
        switch nextState {
        case .collapsed:
            distanceToEndAnimation = slideUpViewHeightConstraint.constant - handleArea.frame.height
        case .expanded:
            distanceToEndAnimation = slideUpViewHeight - slideUpViewHeightConstraint.constant
        }
        
        var animationDurationMultiplier = distanceToEndAnimation / movedAreaHeight
        if animationDurationMultiplier < 0.5 {
            animationDurationMultiplier = 0.5
        }

        return standartAnimationDuration * TimeInterval(animationDurationMultiplier)
    }
    
    
}
