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
        let firstViewController = MapViewController()
        let secondViewController = SearchViewController()
        let thirdViewController = FavoritesViewController()
        
        // Icons setup
        let mapSymbol = UIImage(systemName: "map")?.withTintColor(UIColor.Custom.gray!, renderingMode: .alwaysOriginal)
        let searchSymbol = UIImage(systemName: "magnifyingglass")?.withTintColor(UIColor.Custom.gray!, renderingMode: .alwaysOriginal)
        let starSymbol = UIImage(systemName: "star")?.withTintColor(UIColor.Custom.gray!, renderingMode: .alwaysOriginal)
        
        // TabBar items setup
        firstViewController.tabBarItem = UITabBarItem(title: "Map", image: mapSymbol, selectedImage: mapSymbol?.withTintColor(UIColor.Custom.purple!))
        secondViewController.tabBarItem = UITabBarItem(title: "Search", image: searchSymbol, selectedImage: searchSymbol?.withTintColor(UIColor.Custom.purple!))
        thirdViewController.tabBarItem = UITabBarItem(title: "Favorites", image: starSymbol, selectedImage: starSymbol?.withTintColor(UIColor.Custom.purple!))


        let tabBarList = [firstViewController,secondViewController,thirdViewController]
        self.setViewControllers(tabBarList, animated: false)
        
        //TODO: Create method for badge
        self.tabBar.items?[2].badgeValue = "1"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
