//
//  UITextField+doneButton.swift
//  VoipApp
//
//  Created by Luis  Costa on 18/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit

extension UITextField {
    func setDoneButton() { setDoneToolbar() }
    
    @objc func doneButtonTapped() {
        if delegate?.textFieldShouldReturn?(self) ?? true {
            self.resignFirstResponder()
        }
    }
    
    private func setDoneToolbar() {
        let toolbar = UIToolbar.init(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        toolbar.tintColor = UIColor.system
        
        let spacingButtonItem = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        
        toolbar.setItems([spacingButtonItem, doneButtonItem], animated: false)
        
        self.inputAccessoryView = toolbar
    }
}
