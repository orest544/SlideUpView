//
//  SlideUpViewVC.swift
//  Trax
//
//  Created by Orest Patlyka on 3/26/19.
//

import UIKit

fileprivate enum CardState {
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

// TODO: DRY
enum RoundedCorners {
    case top
    case bottom
    case all
    
    var maskedCorners: CACornerMask {
        switch self {
        case .top:
            return .topCorners
        case .bottom:
            return .bottomCorners
        case .all:
            return .allCorners
        }
    }
    
    var rectCorners: UIRectCorner {
        switch self {
        case .top:
            return .topCorners
        case .bottom:
            return .bottomCorners
        case .all:
            return .allCorners
        }
    }
    
}

protocol SlideUpViewInterface: AnyObject {
    var minimumMultiplierForCollapse: CGFloat { get set }
    var minimumMultiptierForExpande: CGFloat { get set }
    
    var notHidenAreaHeight: CGFloat { get set }
    
    var roundedCorners: RoundedCorners { get set }
    var cornerRadius: CGFloat { get set }
    
    var animationDuration: TimeInterval { get set }
    
    func configure(screenCoveringPercentage: CGFloat)
    func attachMeToThe(position: AttachedPosition)
}

final class SlideUpView: UIView, SlideUpViewInterface, NibLoadable {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var handleArea: UIView!
    
    // MARK: - Client interface
    
    /// Multiplier of height to triger collapse actions (value from 0 to 1.0)
    var minimumMultiplierForCollapse: CGFloat = 0.8
    /// Multiplier of height to triger collapse actions (value from 0 to 1.0)
    var minimumMultiptierForExpande: CGFloat = 0.2
    
    var notHidenAreaHeight: CGFloat = 60
    
    var roundedCorners: RoundedCorners = .top {
        didSet {
            roundCorners()
        }
    }
    var cornerRadius: CGFloat = 60 {
        didSet {
            roundCorners()
        }
    }
    
    var animationDuration: TimeInterval = 0.6
    
    var settings: SlideUpViewInterface {
        return self as SlideUpViewInterface
    }
    
    // MARK: - Private stuff
    
    private var slideUpViewHeight: CGFloat!
    private var slideUpViewHeightConstraint: NSLayoutConstraint!
    
    private var runningAnimation: UIViewPropertyAnimator?
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
    
    // MARK: - Configuration
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
        addGestures()
    }

    private func configureView() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        roundCorners()
    }
    
    private func roundCorners() {
        if #available(iOS 11.0, *) {
            layer.cornerRadius = cornerRadius
            layer.maskedCorners = roundedCorners.maskedCorners
        } else {
            roundCorners(corners: roundedCorners.rectCorners,
                         radius: cornerRadius)
        }
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
        
        let attachedTo: NSLayoutYAxisAnchor = resultOf {
            switch position {
            case .top:
                return superView.topAnchor
            case .bottom:
                return superView.bottomAnchor
            }
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
    private func handleCardTap(recognzier: UITapGestureRecognizer) {
        switch recognzier.state {
        case .ended:
            animateTransitionIfNeeded(state: nextStateForTapped, duration: animationDuration)
        default:
            break
        }
    }
    
    @objc
    private func handleCardPan(recognizer: UIPanGestureRecognizer) {
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
    
    private func animateTransitionIfNeeded(state: CardState, duration: TimeInterval) {
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
    
    private func changeHeightConstraint(by multiplier: CGFloat) {
        guard CGFloat(0)...CGFloat(1) ~= multiplier else {
            print("warning negative value!")
            return
        }
        
        let moveUpValue = (slideUpViewHeight * multiplier) + notHidenAreaHeight
        let moveDownValue = slideUpViewHeight - (slideUpViewHeight * multiplier)
        slideUpViewHeightConstraint.constant = isCardVisible ? moveDownValue : moveUpValue
    }
    
    private func calculateAnimationDuration(for nextState: CardState) -> TimeInterval {
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
