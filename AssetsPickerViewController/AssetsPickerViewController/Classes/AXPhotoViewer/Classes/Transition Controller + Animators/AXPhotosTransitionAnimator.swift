//
//  AXPhotosTransitionAnimator.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 6/6/18.
//

import UIKit

open class AXPhotosTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let fadeInOutTransitionRatio: Double = 1/3
    
    weak var delegate: AXPhotosTransitionAnimatorDelegate?

    let transitionInfo: AXTransitionInfo
    var fadeView: UIView?
    
    public init(transitionInfo: AXTransitionInfo) {
        self.transitionInfo = transitionInfo
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.transitionInfo.duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        fatalError("Override in subclass.")
    }

}

protocol AXPhotosTransitionAnimatorDelegate: class {
    func transitionAnimator(_ animator: AXPhotosTransitionAnimator, didCompletePresentationWith transitionView: UIImageView)
    func transitionAnimator(_ animator: AXPhotosTransitionAnimator, didCompleteDismissalWith transitionView: UIImageView)
    func transitionAnimatorDidCancelDismissal(_ animator: AXPhotosTransitionAnimator)
}
