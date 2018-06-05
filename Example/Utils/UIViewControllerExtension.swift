//
//  UIViewControllerExtension.swift
//  Example
//
//  Created by Adrián Bouza Correa on 08/03/2018.
//  Copyright © 2018 adboco. All rights reserved.
//

import UIKit

extension UIViewController {
    
    fileprivate struct AssociatedObjectKeys {
        static var scrollView = "AssociatedObjectKey_scrollView"
        static var gradientColors = "AssociatedObjectKey_gradientColors"
        static var gradientLayer = "AssociatedObjectKey_gradientLayer"
        static var basicAnimation = "AssociatedObjectKey_basicAnimation"
    }
    
    fileprivate var scrollView: UIScrollView? {
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.scrollView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let scrollView = objc_getAssociatedObject(self, &AssociatedObjectKeys.scrollView) as? UIScrollView
            return scrollView
        }
    }
    
    fileprivate var gradientLayer: CAGradientLayer? {
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.gradientLayer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let gradientLayer = objc_getAssociatedObject(self, &AssociatedObjectKeys.gradientLayer) as? CAGradientLayer
            return gradientLayer
        }
    }
    
    fileprivate var basicAnimation: CABasicAnimation? {
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.basicAnimation, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let basicAnimation = objc_getAssociatedObject(self, &AssociatedObjectKeys.basicAnimation) as? CABasicAnimation
            return basicAnimation
        }
    }
    
    func setAnimatedGradientBackground(attachTo scrollView: UIScrollView, from fromColors: [UIColor], to toColors: [UIColor]) {
        self.scrollView = scrollView
        self.scrollView?.backgroundColor = UIColor.clear
        
        gradientLayer = fromColors.gradient()
        gradientLayer?.speed = 0
        gradientLayer?.timeOffset = 0
        
        basicAnimation = CABasicAnimation(keyPath: "colors")
        basicAnimation?.duration = 1.0
        basicAnimation?.isRemovedOnCompletion = false
        basicAnimation?.fromValue = gradientLayer?.colors
        basicAnimation?.toValue = toColors.compactMap({ $0.cgColor })
        
        guard let gradient = gradientLayer, let animation = basicAnimation else {
            return
        }
        
        view.layer.insertSublayer(gradient, at: 0)
        gradient.timeOffset = 0
        gradient.bounds = self.view.bounds
        gradient.frame = self.view.bounds
        gradient.add(animation, forKey: "Change Colors")
        
        view.addObserver(self, forKeyPath: #keyPath(UIView.bounds), options: .new, context: nil)
        self.scrollView?.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: .new, context: nil)
        
        updateAnimatedGradientBackground()
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, let gradient = gradientLayer else {
            return
        }
        switch keyPath {
        case #keyPath(UIView.bounds):
            guard let objectView = object as? UIView else {
                return
            }
            gradient.frame = objectView.bounds
        case #keyPath(UIScrollView.contentOffset):
            updateAnimatedGradientBackground()
        default:
            break
        }
    }
    
    func updateAnimatedGradientBackground() {
        guard let scrollView = self.scrollView, let animation = basicAnimation, let gradient = gradientLayer else { return }
        
        let offset = scrollView.contentOffset.y / scrollView.contentSize.height
        
        if offset >= 0 && offset <= CGFloat(animation.duration) {
            gradient.timeOffset = CFTimeInterval(offset)
        } else if offset >= CGFloat(animation.duration) {
            gradient.timeOffset = CFTimeInterval(animation.duration)
        }
        
        updateNavigationBarColor()
    }
    
    fileprivate func updateNavigationBarColor() {
        guard let navigationBar = navigationController?.navigationBar, let gradient = gradientLayer else { return }
        
        if let gradientLayer = gradient.presentation(),
            let colors = gradientLayer.value(forKey: "colors") as? [CGColor],
            let firstColor = colors.first {
            navigationBar.barTintColor = UIColor(cgColor: firstColor)
        } else if let color = gradient.colors as? [CGColor],
            let firstColor = color.first {
            navigationBar.barTintColor = UIColor(cgColor: firstColor)
        }
    }
    
}
