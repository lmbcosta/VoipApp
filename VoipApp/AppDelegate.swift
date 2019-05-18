//
//  AppDelegate.swift
//  VoipApp
//
//  Created by Luis  Costa on 08/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        self.window?.rootViewController = buildOnboatdingViewController()
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        DatabaseManager.shared.saveContext()
    }
    
    func proceedToTabBarViewController() {
        guard let snapshot = self.window?.snapshotView(afterScreenUpdates: true) else { return }
        
        let tabBar = TabBarViewController.init()
        tabBar.view.addSubview(snapshot)
        
        self.window?.rootViewController = tabBar
        
        UIView.animate(withDuration: 0.3, animations: {
            snapshot.layer.opacity = 0
            snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
        }, completion: { _ in
            snapshot.removeFromSuperview()
        })
    }
}

private extension AppDelegate {
    func buildOnboatdingViewController() -> UIViewController? {
        let storyboard = UIStoryboard.init(name: "Onboarding", bundle: nil)
        
        guard let onboardingVC = storyboard.instantiateViewController(withIdentifier: "onboarding-view-controller") as? OnboardingViewController else {
            return nil
        }
        
        var childrenVC: [OnboardingChildViewController] = []
        
        for i in 0..<4{
            if let childVC = storyboard.instantiateViewController(withIdentifier: "onboarding-child-view-controller") as? OnboardingChildViewController {
                childVC.currentPage = i
                childrenVC.append(childVC)
            }
        }
        
        onboardingVC.setupOnboardingVC(withChildren: childrenVC)
        
        return UINavigationController(rootViewController: onboardingVC)
    }
}

