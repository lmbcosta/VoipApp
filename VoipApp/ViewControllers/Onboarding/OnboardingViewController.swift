//
//  OnboardingViewController.swift
//  VoipApp
//
//  Created by Luís  Costa on 18/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    //UI
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var footerView: FooterOnboardingView!
    
    private var childrenVC: [OnboardingChildViewController] = []
    private var currentPage: Int = 0
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        navigateToCurrentPage()
    }
    
    fileprivate func setup() {
        self.navigationController?.navigationBar.isHidden = true
        self.footerView.delegate = self
        
        // page swipe
        let rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(toPreviousPage))
        rightSwipeRecognizer.direction = .right
        containerView.addGestureRecognizer(rightSwipeRecognizer)
        
        let leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(toNextPage))
        leftSwipeRecognizer.direction = .left
        containerView.addGestureRecognizer(leftSwipeRecognizer)
    }
    
    func setupOnboardingVC(withChildren children: [OnboardingChildViewController]) {
        self.childrenVC = children
    }
}

// MARK: Private methods
private extension OnboardingViewController {
    
    func navigateToCurrentPage() {
        childrenVC.forEach({ $0.remove() })
        self.add(child: childrenVC[currentPage], to: containerView)
    }
    
    @objc func toPreviousPage() {
        guard currentPage > 0 else { return }
        
        transition(to: currentPage - 1)
    }
    
    @objc func toNextPage() {
        guard currentPage < childrenVC.count - 1 else {
            appDelegate.proceedToTabBarViewController()
            return
        }
        
        transition(to: currentPage + 1)
    }
    
    func transition(to page: Int, animated: Bool = true) {
        let previousPage = currentPage
        currentPage = page
        
        navigateToCurrentPage()
        
        guard animated else { return }
        
        footerView.enableButtons(false)
        containerView.isUserInteractionEnabled = false
        
        let animCompletion = AnimationDelegate()
        animCompletion.onCompleteCallback = { [weak self] (_,_) in
            guard let self = self else { return }
            
            self.footerView.enableButtons(true)
            self.containerView.isUserInteractionEnabled = true
            self.footerView.goToNextPage(newPage: self.currentPage)
        }
        
        if currentPage < previousPage {
            containerView.slideInFromLeft(duration: 0.5, completionDelegate: animCompletion as AnyObject)
        }
        else {
            containerView.slideInFromRight(duration: 0.5, completionDelegate: animCompletion as AnyObject)
        }
    }
}

extension OnboardingViewController: FooterOnBoardViewDelegate {
    func leftButtonTapped() {
        appDelegate.proceedToTabBarViewController()
    }
    
    func rightButtonTapped() {
        self.toNextPage()
    }
}
