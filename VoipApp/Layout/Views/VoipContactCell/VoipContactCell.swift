//
//  VoipContactCell.swift
//  VoipApp
//
//  Created by Luis Costa on 08/05/2019.
//  Copyright © 2019 Luis Costa. All rights reserved.
//

import UIKit

class VoipContactCell: UITableViewCell {
    
    static let height: CGFloat = Defaults.cellHeight
    
    // UI
    @IBOutlet private weak var thumbnail: UIImageView! {
        didSet { thumbnail.contentMode = .scaleAspectFit }
    }
    
    @IBOutlet private weak var dateLabel: UILabel! {
        didSet {
            dateLabel.numberOfLines = 1
            dateLabel.font = Defaults.secondaryFont
            dateLabel.textColor = Defaults.secondaryColor
            dateLabel.textAlignment = .right
        }
    }
    
    @IBOutlet private weak var nameLabel: UILabel! {
        didSet {
            nameLabel.numberOfLines = 1
            nameLabel.font = Defaults.mainFont
            nameLabel.textColor = Defaults.mainColor
            nameLabel.textAlignment = .left
        }
    }
    
    @IBOutlet private weak var typeLabel: UILabel! {
        didSet {
            typeLabel.numberOfLines = 1
            typeLabel.font = Defaults.secondaryFont
            typeLabel.textColor = Defaults.secondaryColor
            typeLabel.textAlignment = .left
        }
    }
    
    override func layoutSubviews() {
        thumbnail.layer.cornerRadius = thumbnail.bounds.height / 2
    }
    
    func configure(name: String, dateText: String?, image: UIImage?, callType: String?) {
        //nameLabel.text = name
        dateLabel.text = dateText
        let contactImage = image ?? Defaults.placeholder
        thumbnail.image = contactImage
        typeLabel.text = callType
    }
}

private extension VoipContactCell {
    struct Defaults {
        static let mainFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        static let secondaryFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        static let mainColor = UIColor.black
        static let secondaryColor = UIColor.lightGray
        static let placeholder = UIImage.init(named: "placeholder")
        static let cellHeight: CGFloat = 50
    }
}
