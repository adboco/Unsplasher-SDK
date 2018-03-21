//
//  UIScrollViewExtension.swift
//  Example
//
//  Created by Adrián Bouza Correa on 08/03/2018.
//  Copyright © 2018 adboco. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    fileprivate struct AssociatedObjectKeys {
        static var pullRefreshCompletion = "AssociatedObjectKey_pullRefresh"
    }
    
    fileprivate typealias Action = (() -> Void)?
    
    // Set our computed property type to a closure
    fileprivate var pullRefreshAction: Action? {
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.pullRefreshCompletion, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let pullRefreshAction = objc_getAssociatedObject(self, &AssociatedObjectKeys.pullRefreshCompletion) as? Action
            return pullRefreshAction
        }
    }
    
    func addPullToRefresh(title: String? = nil, completion: @escaping () -> Void) {
        let refreshControl: UIRefreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)
            if let title = title {
                refreshControl.attributedTitle = NSAttributedString(string: title)
            }
            
            return refreshControl
        }()
        
        self.pullRefreshAction = completion
        self.refreshControl = refreshControl
    }
    
    func endRefreshing() {
        guard let refreshControl = self.refreshControl else { return }
        refreshControl.endRefreshing()
    }
    
    @objc fileprivate func refresh(_ completion: () -> Void) {
        guard let action = self.pullRefreshAction else { return }
        action?()
    }
    
}
