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

        // View Controllers
        let mapViewController = MapViewController()
        let searchViewController = SearchViewController()
        let favoritesViewController = FavoritesViewController()
        
        // Nav Controllers
        let navMapController = UINavigationController()
        let navSearchController = UINavigationController()
        let navFavoritesController = UINavigationController()
        
        navMapController.viewControllers = [mapViewController]
        navSearchController.viewControllers = [searchViewController]
        navFavoritesController.viewControllers = [favoritesViewController]

        // View Controllers titles
        searchViewController.title = "Search"
        favoritesViewController.title = "Favorites"

        // Icons setup
        let mapSymbol = UIImage(systemName: "map")?.withTintColor(UIColor.Custom.gray!, renderingMode: .alwaysOriginal)
        let searchSymbol = UIImage(systemName: "magnifyingglass")?.withTintColor(UIColor.Custom.gray!, renderingMode: .alwaysOriginal)
        let starSymbol = UIImage(systemName: "star")?.withTintColor(UIColor.Custom.gray!, renderingMode: .alwaysOriginal)
        
        // TabBar style setup
        UITabBar.appearance().barTintColor = .systemBackground
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.Custom.gray!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.Custom.purple!], for: .selected)
        
        // NavBar Setup
        let backSymbol = UIImage(systemName: "arrow.left.circle.fill")?.withTintColor(UIColor.Custom.purple!, renderingMode: .alwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = backSymbol
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backSymbol
        UINavigationBar.appearance().backgroundColor = .systemBackground
        UINavigationBar.appearance().prefersLargeTitles = true
        
        // TabBar items setup
        navMapController.tabBarItem = UITabBarItem(title: "Map", image: mapSymbol, selectedImage: mapSymbol?.withTintColor(UIColor.Custom.purple!))
        navSearchController.tabBarItem = UITabBarItem(title: "Search", image: searchSymbol, selectedImage: searchSymbol?.withTintColor(UIColor.Custom.purple!))
        navFavoritesController.tabBarItem = UITabBarItem(title: "Favorites", image: starSymbol, selectedImage: starSymbol?.withTintColor(UIColor.Custom.purple!))

        let tabBarList = [navMapController,navSearchController,navFavoritesController]
        self.setViewControllers(tabBarList, animated: false)
        
        //TODO: Create method for badge
        self.tabBar.items?[2].badgeValue = "1"
    }
}
