//
//  OnboardingChildViewController.swift
//  VoipApp
//
//  Created by Luís  Costa on 18/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit

class OnboardingChildViewController: UIViewController {
    //UI
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    var currentPage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    private func setupView() {
        // Title
        self.titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        self.titleLabel.textAlignment = .center
        self.titleLabel.textColor = .blue
        self.titleLabel.numberOfLines = 0
        self.titleLabel.lineBreakMode = .byWordWrapping
        
        // Description
        self.descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        self.descriptionLabel.textAlignment = .center
        self.descriptionLabel.textColor = .blue
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.lineBreakMode = .byWordWrapping
        
        updateContentForCurrentPage()
    }
    
    private func updateContentForCurrentPage() {
        let strings = getOnboardText(forIndex: currentPage)
        
        self.titleLabel.text = strings.title
        self.descriptionLabel.text = strings.description
    }
    
    private func getOnboardText(forIndex index: Int) -> (title: String, description: String) {
        let titles = [
            "Welcome to Voip App",
            "Call History",
            "Contact List",
            "Contact Detail"
        ]
        
        let descriptions = [
            "Check how easy is to use VoipApp. Just follow the next steps",
            "Check your recent incoming/outgoing calls. \n\nReply or make a new call tapping on them. \n\nTo delete them, simply slide from right to left. \n\nYou can simulate a incoming call by tapping to top left button.",
            "Sincronize your iOS contacts and filter out those who have a VoipApp number. \n\nSlide to your left on VoipApp contacts to edit or delete them. \n\nTap to simulate a incoming call.",
            "Create/Edit contacts info. It will be sincronized with you iOS Contacts."
        ]
        
        return (title: titles[index], description: descriptions[index])
    }
}
