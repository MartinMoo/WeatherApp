//
//  TabBarController.swift
//  assignment
//
//  Created by Martin Miklas on 23/01/2021.
//

import UIKit

class TabBarController: UITabBarController {
    var badgeValue: Int = 0 {
        didSet { // Update the Badge for favorites locations
            if badgeValue != 0 {
                self.tabBar.items?[2].badgeValue = String(badgeValue)
            } else {
                self.tabBar.items?[2].badgeValue = nil
            }
        }
    }

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
        searchViewController.title = Localize.Search.Title
        favoritesViewController.title = Localize.Favorites.Title

        // Tab Bar Icons setup
        let mapSymbol = UIImage(systemName: "map")?.withTintColor(UIColor.Custom.gray!, renderingMode: .alwaysOriginal)
        let searchSymbol = UIImage(systemName: "magnifyingglass")?.withTintColor(UIColor.Custom.gray!, renderingMode: .alwaysOriginal)
        let starSymbol = UIImage(systemName: "star")?.withTintColor(UIColor.Custom.gray!, renderingMode: .alwaysOriginal)
        
        // TabBar Style setup
        UITabBar.appearance().barTintColor = .systemBackground
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.Custom.gray!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.Custom.purple!], for: .selected)
        
        // NavBar Style setup
        let backSymbol = UIImage(systemName: "arrow.left.circle.fill")?.withTintColor(UIColor.Custom.purple!, renderingMode: .alwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = backSymbol
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backSymbol
        UINavigationBar.appearance().backgroundColor = .systemBackground
        UINavigationBar.appearance().prefersLargeTitles = true
        
        // TabBar items/buttons setup
        navMapController.tabBarItem = UITabBarItem(title: Localize.TabBar.Map, image: mapSymbol, selectedImage: mapSymbol?.withTintColor(UIColor.Custom.purple!))
        navSearchController.tabBarItem = UITabBarItem(title: Localize.TabBar.Search, image: searchSymbol, selectedImage: searchSymbol?.withTintColor(UIColor.Custom.purple!))
        navFavoritesController.tabBarItem = UITabBarItem(title: Localize.TabBar.Favorites, image: starSymbol, selectedImage: starSymbol?.withTintColor(UIColor.Custom.purple!))

        // Add items to TabBar
        let tabBarList = [navMapController,navSearchController,navFavoritesController]
        self.setViewControllers(tabBarList, animated: false)
        
        // Initial check for favorites locations
        updateBadgeValue()

        // Notification if there was a change in CoreData
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
    }
    
    // Update badge value on notification from observer
    @objc func contextObjectsDidChange(_ notification: Notification) {
        updateBadgeValue()
    }
    
    // Get list from CoreData and update bardge value
    func updateBadgeValue() {
        let list = CoreDataManager.shared.fetchLocationList()
        badgeValue = list.count
    }
}
