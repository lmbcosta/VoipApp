//
//  UIViewController+Child.swift
//  VoipApp
//
//  Created by Luís  Costa on 18/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit

extension UIViewController {
    // Called from Parent view controller
    func add(child: UIViewController?, to view: UIView? = nil) {
        guard let child = child else { return }
        
        // Add Child View Controller
        addChild(child)
        
        // Add Child View as Subview
        let parent: UIView = view ?? self.view
        parent.addSubview(child.view)
        child.view.frame = parent.bounds
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        child.didMove(toParent: self)
    }
    
    // Called from Child View Controller
    func remove() {
        guard parent != nil else { return }
        
        // Notify Child View Controller
        willMove(toParent: nil)
        
        // Remove Child View From Superview
        removeFromParent()
        
        // Notify Child View Controller
        view.removeFromSuperview()
    }
}
