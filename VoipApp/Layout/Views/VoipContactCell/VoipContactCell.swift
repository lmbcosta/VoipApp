//
//  VoipContactCell.swift
//  VoipApp
//
//  Created by Luis  Costa on 14/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit

class VoipContactCell: UITableViewCell {
    static let identifier = Defaults.identifier
    static let height = Defaults.cellHeight
    
    // UI
    @IBOutlet private weak var nameLabel: UILabel! {
        didSet {
            nameLabel.numberOfLines = 1
            nameLabel.font = Defaults.mainFont
            nameLabel.textColor = Defaults.mainColor
            nameLabel.textAlignment = .left
        }
    }
    
    @IBOutlet private weak var phoneLabel: UILabel! {
        didSet {
            phoneLabel.numberOfLines = 1
            phoneLabel.font = Defaults.secondaryFont
            phoneLabel.textColor = Defaults.secondaryColor
            phoneLabel.textAlignment = .left
        }
    }
    
    @IBOutlet private weak var voipAppLabel: UILabel! {
        didSet {
            voipAppLabel.numberOfLines = 1
            voipAppLabel.font = Defaults.mainFont
            voipAppLabel.textColor = Defaults.mainColor
            voipAppLabel.textAlignment = .right
            voipAppLabel.text = Strings.voipNumberText
        }
    }
    
    func configure(name: String, phoneNumber: String, isVoipNumber: Bool) {
        nameLabel.text = name
        phoneLabel.text = phoneNumber
        voipAppLabel.isHidden = !isVoipNumber
    }
}

private extension VoipContactCell {
    struct Defaults {
        static let mainFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        static let secondaryFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        static let mainColor = UIColor.black
        static let secondaryColor = UIColor.darkGray
        static let cellHeight: CGFloat = 60
        static let identifier = "VoipContactCell"
    }
    
    struct Strings {
        static let voipNumberText = "Voip Number"
    }
}
