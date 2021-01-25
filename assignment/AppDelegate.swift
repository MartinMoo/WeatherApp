//
//  AppDelegate.swift
//  assignment
//
//  Created by Moo Maa on 22/01/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let tabBarController = TabBarController()
        window = UIWindow()
        window?.makeKeyAndVisible()
        window?.rootViewController = tabBarController
        window?.backgroundColor = .systemBackground
        
        if CoreDataManager.shared.isEntityEmpty(entity: "FavoriteLocation") {
            addInitialLocationList()
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func addInitialLocationList() {
        CoreDataManager.shared.addLocation(name: "Praha", longitude: 0, latitude: 0)
        CoreDataManager.shared.addLocation(name: "Bratislava", longitude: 10, latitude: 10)
        CoreDataManager.shared.addLocation(name: "Zilina", longitude: 20, latitude: 20)
        CoreDataManager.shared.addLocation(name: "Liptovsky Mikulas", longitude: 30, latitude: 30)
    }
}

