//
//  ViewController.swift
//  Tracker Home
//
//  Created by Марат Хасанов on 22.12.2023.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    //MainTabBarController
    
    private func setupTabBar() {
        let titleTrackers = localizedText(text: "trackerTitleText")
        let titleStatistics = localizedText(text: "statisticTitleText")
        let tabBarItem0 = createTabBar(title: titleTrackers, image: UIImage(named: "ic 28x28"), vC: TrackerViewController())
        
        let tabBarItem1 = createTabBar(title: titleStatistics, image: UIImage(named: "ic 28x28-2"), vC: StatisticsViewController())
        
        let tabBarSeparator = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 1))
        tabBarSeparator.backgroundColor = .udGray
        tabBar.addSubview(tabBarSeparator)
        
        setViewControllers([tabBarItem0, tabBarItem1], animated: true)
    }

    private func createTabBar(title: String, image: UIImage?, vC: UIViewController) -> UINavigationController {
        let setting = UINavigationController(rootViewController: vC)
        setting.navigationBar.prefersLargeTitles = true
        setting.tabBarItem.title = title
        setting.tabBarItem.image = image
        setting.viewControllers.first?.navigationItem.title = title
        return setting
    }
}

