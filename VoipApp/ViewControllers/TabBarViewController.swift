//
//  TabBarViewController.swift
//  VoipApp
//
//  Created by Luis  Costa on 12/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    private lazy var callHistoryVC = instantiateCallHistoryViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewControllers = [
            UINavigationController(rootViewController: callHistoryVC)
        ]
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let viewControllers = self.viewControllers else { return }
        guard let navigationController = viewControllers[selectedIndex] as? UINavigationController else { return }
        
        navigationController.popViewController(animated: false)
    }
}

private extension TabBarViewController {
    func instantiateCallHistoryViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: Strings.storyboardName, bundle: nil)
        let callHistoryVC = storyboard.instantiateViewController(withIdentifier: Strings.callHistoryIdentifier)
        callHistoryVC.tabBarItem  = UITabBarItem.init(tabBarSystemItem: .history, tag: 0)
        return callHistoryVC
    }
    
    struct Strings {
        static let storyboardName = "Main"
        static let callHistoryIdentifier = "history-call-view-controller"
        static let callHistoryTitle = "History"
    }
}
