//
//  UIView+Animations.swift
//  VoipApp
//
//  Created by Luís  Costa on 18/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit

extension UIView {
    func slideInFromLeft(duration: TimeInterval = 0.5, completionDelegate: AnyObject? = nil) {
        // Create a CATransition animation
        let slideInFromLeftTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate = completionDelegate as? CAAnimationDelegate {
            slideInFromLeftTransition.delegate = delegate
        }
        
        // Customize the animation's properties
        slideInFromLeftTransition.type = .push
        slideInFromLeftTransition.subtype = .fromLeft
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        slideInFromLeftTransition.fillMode = .removed
        
        // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
    }
    
    func slideInFromRight(duration: TimeInterval = 0.5, completionDelegate: AnyObject? = nil) {
        // Create a CATransition animation
        let slideInFromRightTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate = completionDelegate as? CAAnimationDelegate {
            slideInFromRightTransition.delegate = delegate
        }
        
        // Customize the animation's properties
        slideInFromRightTransition.type = .push
        slideInFromRightTransition.subtype = .fromRight
        slideInFromRightTransition.duration = duration
        slideInFromRightTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromRightTransition.fillMode = .removed
        
        // Add the animation to the View's layer
        self.layer.add(slideInFromRightTransition, forKey: "slideInFromRightTransition")
    }
}
