//
//  CAAnimation+Callbacks.swift
//  VoipApp
//
//  Created by Luís  Costa on 18/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit

public typealias CAAnimationCallback = (CAAnimation, Bool) -> Void

public class AnimationDelegate: NSObject, CAAnimationDelegate {
    var onStartCallback: CAAnimationCallback?
    var onCompleteCallback: CAAnimationCallback?
    
    public func animationDidStart(_ anim: CAAnimation) {
        if let startHandler = onStartCallback {
            startHandler(anim, true)
        }
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let completionHandler = onCompleteCallback {
            completionHandler(anim, flag)
        }
    }
}

public extension CAAnimation {
    // See if there is already a CAAnimationDelegate handling this animation
    // If there is, add onStart to it, if not create one
    func setOnStartCallbackBlock(callback:@escaping CAAnimationCallback) {
        if let myDelegate = delegate {
            if myDelegate.isKind(of: AnimationDelegate.self) {
                if let animationObj = myDelegate as? AnimationDelegate {
                    animationObj.onStartCallback = callback
                }
            }
        }
        else {
            let callbackDelegate = AnimationDelegate()
            callbackDelegate.onStartCallback = callback
            self.delegate = callbackDelegate as CAAnimationDelegate
        }
    }
    
    // See if there is already a CAAnimationDelegate handling this animation
    // If there is, add onCompletion to it, if not create one
    func setCompletionBlock(callback:@escaping CAAnimationCallback) {
        if let myDelegate = delegate {
            if myDelegate.isKind(of: AnimationDelegate.self) {
                if let animationObj = myDelegate as? AnimationDelegate {
                    animationObj.onCompleteCallback = callback
                }
            }
        }
        else {
            let callbackDelegate = AnimationDelegate()
            callbackDelegate.onCompleteCallback = callback
            self.delegate = callbackDelegate
        }
    }
}
