//
//  FavoritesViewController.swift
//  assignment
//
//  Created by Martin Miklas on 22/01/2021.
//

import UIKit

class FavoritesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .systemBackground


        //TODO: Create colection view for favorites cities, local persistence CoreData?
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let locations = CoreDataManager.shared.fetchLocationList()
        for location in locations {
            print(location.name)
            print(location.longitude)
            print(location.latitude)
        }
    }
}
