//
//  OverlayView.swift
//  FirebaseAdsSubscriber
//
//  Created by Prasad Pai on 8/16/16.
//  Copyright © 2016 YMedia Labs. All rights reserved.
//

import UIKit

protocol OverlayProtocol: class {
    func overlayViewBtnTapped(index: Int)
}

class OverlayView: UIView {
    
    var dismissOverlayAfter: Double?
    var overlayIndex: Int?
    
    private var localOverlayTimer: NSTimer?
    
    weak var overlayDelegate: OverlayProtocol?
    
    private let circle0 = UIImageView(image: UIImage(named: "circle_0"))
    private let circle1 = UIImageView(image: UIImage(named: "circle_1"))
    private let circle2 = UIImageView(image: UIImage(named: "circle_2"))
    
    // MARK: Life Cycle methods
    deinit {
        self.localOverlayTimer?.invalidate()
        self.localOverlayTimer = nil
    }

    // MARK: Public methods
    func createOverlayViewWithIndex(index: Int, dismissOverlayAfter: Double) {
        self.backgroundColor = UIColor.clearColor()
        self.addSubview(self.circle2)
        self.addSubview(self.circle1)
        self.addSubview(self.circle0)
        
        let tapBtn = UIButton(type: UIButtonType.Custom)
        tapBtn.backgroundColor = UIColor.clearColor()
        tapBtn.addTarget(self, action: #selector(buttonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        tapBtn.frame = CGRect(x: 0.0, y: 0.0, width: kOverlayBtnWidth, height: kOverlayBtnWidth)
        self.addSubview(tapBtn)
        
        self.overlayIndex = index
        self.dismissOverlayAfter = dismissOverlayAfter
        self.localOverlayTimer = NSTimer.scheduledTimerWithTimeInterval(dismissOverlayAfter, target: self, selector: #selector(removeOverlayViewSelector(_:)), userInfo: nil, repeats: false)
        
        self.addAnimationFor(self.circle0.layer, withBeginTime: 0.0)
        self.addAnimationFor(self.circle1.layer, withBeginTime: 0.3)
        self.addAnimationFor(self.circle2.layer, withBeginTime: 0.2)
    }
    
    // MARK: Private methods
    private func addAnimationFor(layer: CALayer, withBeginTime beginTime: CFTimeInterval) {
        let duration = 0.5
        if let dismissOverlayAfter = self.dismissOverlayAfter {
            let animation = CABasicAnimation()
            animation.autoreverses = false
            animation.removedOnCompletion = false
            animation.beginTime = CACurrentMediaTime() + beginTime
            animation.keyPath = "transform"
            animation.repeatCount = Float(2.0 * dismissOverlayAfter / duration)
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            animation.toValue = NSValue(CATransform3D: CATransform3DMakeScale(1.25, 1.25, 1.0))
            animation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)

            layer.addAnimation(animation, forKey: "animation")
        }
    }
    
    private func removeOverlayView() {
        self.localOverlayTimer?.invalidate()
        self.localOverlayTimer = nil
        self.removeFromSuperview()
    }
    
    // MARK: Action and Selector methods
    func buttonTapped(sender: AnyObject) {
        self.userInteractionEnabled = false
        if let index = self.overlayIndex {
            self.overlayDelegate?.overlayViewBtnTapped(index)
        }
        self.removeOverlayView()
    }
    
    func removeOverlayViewSelector(timer: NSTimer) {
        self.removeOverlayView()
    }
}
