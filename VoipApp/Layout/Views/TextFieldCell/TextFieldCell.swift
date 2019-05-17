//
//  TextFieldCell.swift
//  VoipApp
//
//  Created by Luis  Costa on 17/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit

class TextFieldCell: UICollectionViewCell {
    static let height = Defaults.cellHeight
    static let identifier = Strings.identifier

    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            titleLabel.numberOfLines = 1
            titleLabel.textColor = UIColor.system
            titleLabel.textAlignment = .left
        }
    }
    
    @IBOutlet private weak var textField: UITextField! {
        didSet { textField.font = UIFont.systemFont(ofSize: 14, weight: .regular) }
    }
    
    func configure(title: String, input: VoipModels.Input, index: Int, delegate: UITextFieldDelegate?) {
        titleLabel.text = title
        textField.delegate = delegate
        textField.tag = index
        
        switch input {
        case .name(let name):
            textField.text = name
            textField.keyboardType = .default
            textField.inputAccessoryView = nil
            
        case .phoneNumber(let phoneNumber):
            textField.text = phoneNumber
            textField.keyboardType = .phonePad
            textField.setDoneButton()
        }
    }
}

private extension TextFieldCell {
    struct Defaults {
        static let cellHeight: CGFloat = 100
    }
    
    struct Strings {
        static let identifier = "TextFieldCell"
    }
}
