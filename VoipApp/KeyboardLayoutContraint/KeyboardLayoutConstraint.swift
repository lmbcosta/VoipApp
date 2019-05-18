//
//  KeyboardLayoutConstraint.swift
//  VoipApp
//
//  Created by Luís  Costa on 18/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit

class KeyboardLayoutConstraint: NSLayoutConstraint {
    
    private var offset: CGFloat = 0
    private var keyboardVisibleHeight: CGFloat = 0
    
    var bottomViewOffset: CGFloat = 0
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        offset = constant
        
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardLayoutConstraint.keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardLayoutConstraint.keyboardWillHideNotification(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Notification
    
    @objc func keyboardWillShowNotification(_ notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let frame = frameValue.cgRectValue
                keyboardVisibleHeight = frame.size.height - KeyboardLayoutConstraint.safeAreaBottom()
            }
            
            self.updateConstant()
            switch (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber, userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber) {
            case let (.some(duration), .some(curve)):
                
                let options = UIView.AnimationOptions(rawValue: curve.uintValue)
                
                UIView.animate(
                    withDuration: TimeInterval(duration.doubleValue),
                    delay: 0,
                    options: options,
                    animations: {
                        UIApplication.shared.keyWindow?.layoutIfNeeded()
                        return
                }, completion: { _ in
                })
            default:
                
                break
            }
            
        }
        
    }
    
    @objc func keyboardWillHideNotification(_ notification: NSNotification) {
        keyboardVisibleHeight = 0
        self.updateConstant()
        
        if let userInfo = notification.userInfo {
            
            switch (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber, userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber) {
            case let (.some(duration), .some(curve)):
                
                let options = UIView.AnimationOptions(rawValue: curve.uintValue)
                
                UIView.animate(
                    withDuration: TimeInterval(duration.doubleValue),
                    delay: 0,
                    options: options,
                    animations: {
                        UIApplication.shared.keyWindow?.layoutIfNeeded()
                        return
                }, completion: { _ in
                })
            default:
                break
            }
        }
    }
    
    func updateConstant() {
        if keyboardVisibleHeight > 0 {
            keyboardVisibleHeight += bottomViewOffset
            self.constant = -offset + keyboardVisibleHeight
        }
        else {
            self.constant = offset
        }
    }
    
    static func safeAreaBottom() -> CGFloat {
        
        guard let rootView = UIApplication.shared.keyWindow else {
            return 0.0
        }
        if #available(iOS 11.0, *) {
            return rootView.safeAreaInsets.bottom
        }
        else {
            return 0.0
        }
    }
}
