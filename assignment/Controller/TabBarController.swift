//
//  TabBarController.swift
//  assignment
//
//  Created by Martin Miklas on 22/01/2021.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View controllers
        let mapViewController = MapViewController()
        let searchViewController = SearchViewController()
        let favoritesViewController = FavoritesViewController()
        let navController = UINavigationController()
        navController.viewControllers = [mapViewController ]
        let navAppearance = UINavigationBarAppearance()
        
        // Icons setup
        let mapSymbol = UIImage(systemName: "map")?.withTintColor(UIColor.Custom.gray!, renderingMode: .alwaysOriginal)
        let searchSymbol = UIImage(systemName: "magnifyingglass")?.withTintColor(UIColor.Custom.gray!, renderingMode: .alwaysOriginal)
        let starSymbol = UIImage(systemName: "star")?.withTintColor(UIColor.Custom.gray!, renderingMode: .alwaysOriginal)
        
        // TabBar style setup
        UITabBar.appearance().barTintColor = .systemBackground
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.Custom.gray!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.Custom.purple!], for: .selected)
        
        // NavBar Setup
        navAppearance.configureWithOpaqueBackground()
               
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = UIColor.Custom.purple
        
        // TabBar items setup
        navController.tabBarItem = UITabBarItem(title: "Map", image: mapSymbol, selectedImage: mapSymbol?.withTintColor(UIColor.Custom.purple!))
        searchViewController.tabBarItem = UITabBarItem(title: "Search", image: searchSymbol, selectedImage: searchSymbol?.withTintColor(UIColor.Custom.purple!))
        favoritesViewController.tabBarItem = UITabBarItem(title: "Favorites", image: starSymbol, selectedImage: starSymbol?.withTintColor(UIColor.Custom.purple!))


        let tabBarList = [navController,searchViewController,favoritesViewController]
        self.setViewControllers(tabBarList, animated: false)
        
        //TODO: Create method for badge
        self.tabBar.items?[2].badgeValue = "1"
    }
}
