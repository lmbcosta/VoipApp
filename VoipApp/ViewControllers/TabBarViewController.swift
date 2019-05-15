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
    private lazy var contactListVC = instantiateContactListViewController()
    private lazy var callHistoryTabBarItem = UITabBarItem.init(tabBarSystemItem: .history, tag: 0)
    private lazy var contactsTabBarItem = UITabBarItem.init(tabBarSystemItem: .contacts, tag: 1)
    
    private let mainStoryboard = UIStoryboard.init(name: Strings.storyboardName, bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewControllers = [
            UINavigationController(rootViewController: callHistoryVC),
            UINavigationController(rootViewController: contactListVC)
        ]
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let viewControllers = self.viewControllers else { return }
        guard let navigationController = viewControllers[selectedIndex] as? UINavigationController else { return }
        
        navigationController.popViewController(animated: false)
    }
    
    func routeToCallHistory() {
        selectedIndex = 0
        tabBar(tabBar, didSelect: callHistoryTabBarItem)
    }
}

private extension TabBarViewController {
    func instantiateCallHistoryViewController() -> UIViewController {
        let vc = mainStoryboard.instantiateViewController(withIdentifier: Strings.callHistoryIdentifier)
        vc.tabBarItem  = callHistoryTabBarItem
        return vc
    }
    
    func instantiateContactListViewController() -> UIViewController {
        let vc = mainStoryboard.instantiateViewController(withIdentifier: Strings.contactListIdentifier)
        vc.tabBarItem = contactsTabBarItem
        return vc
    }
    
    struct Strings {
        static let storyboardName = "Main"
        static let callHistoryIdentifier = "call-history-view-controller"
        static let contactListIdentifier = "contact-list-view-controller"
        static let callHistoryTitle = "History"
    }
}
