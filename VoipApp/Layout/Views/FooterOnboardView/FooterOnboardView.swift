//
//  FooterOnboardView.swift
//  VoipApp
//
//  Created by Luís  Costa on 18/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit

protocol FooterOnBoardViewDelegate: class {
    func leftButtonTapped()
    func rightButtonTapped()
}

class FooterOnboardingView: UIView {
    
    //UI
    @IBOutlet var contentView: UIView!
    @IBOutlet private weak var leftButton: UIButton! {
        didSet {
            leftButton.setTitle("Skip Tutorial", for: .normal)
            leftButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            leftButton.tintColor = .darkGray
            leftButton.addTarget(self, action: #selector(self.leftButtonTapped), for: .touchUpInside)
        }
    }
    
    @IBOutlet private weak var rightButton: UIButton! {
        didSet {
            rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            rightButton.clipsToBounds = true
            rightButton.layer.masksToBounds = true
            rightButton.addTarget(self, action: #selector(self.rightButtonTapped), for: .touchUpInside)
            rightButton.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
            rightButton.titleLabel?.adjustsFontSizeToFitWidth = true
        }
    }
    
    @IBOutlet private weak var pageControl: UIPageControl! {
        didSet {
            pageControl.numberOfPages = 4
            pageControl.currentPage = 0
            pageControl.currentPageIndicatorTintColor = .blue
            pageControl.pageIndicatorTintColor = .lightGray
        }
    }
    
    //delegate
    weak var delegate: FooterOnBoardViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.customInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupInitialState()
    }
    
    fileprivate func customInit() {
        Bundle.main.loadNibNamed("FooterOnboardingView", owner: self, options: nil)
        self.addSubview(contentView)
        self.contentView.frame = self.bounds
        self.setupInitialState()
    }
    
    fileprivate func setupInitialState() {
        pageControl.updateCurrentPageDisplay()
        goToNextPage(newPage: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rightButton.layer.cornerRadius = rightButton.frame.height / 2
    }
    
    @objc fileprivate func rightButtonTapped() {
        delegate?.rightButtonTapped()
    }
    
    @objc fileprivate func leftButtonTapped() {
        delegate?.leftButtonTapped()
    }
}

private extension FooterOnboardingView {
    struct Defaults {
        let regularFont = UIFont.systemFont(ofSize: 15, weight: .regular)
    }
}

// Public methods
extension FooterOnboardingView {
    func goToNextPage(newPage: Int) {
        switch newPage {
        case 0, 1, 2:
            pageControl.currentPage = newPage
            pageControl.updateCurrentPageDisplay()
            leftButton.isHidden = false
            rightButton.setTitle("Next", for: .normal)
            rightButton.tintColor = .blue
            rightButton.backgroundColor = .white
        case 3:
            pageControl.currentPage = newPage
            pageControl.updateCurrentPageDisplay()
            leftButton.isHidden = true
            rightButton.setTitle(NSLocalizedString("Begin", comment: ""), for: .normal)
            rightButton.tintColor = .white
            rightButton.backgroundColor = .blue
        default:
            break
        }
    }
    
    func enableButtons(_ value: Bool) {
        self.leftButton.isEnabled = value
        self.rightButton.isEnabled = value
    }
}
