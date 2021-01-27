//
//  FavoritesViewController.swift
//  assignment
//
//  Created by Martin Miklas on 22/01/2021.
//

import UIKit
import CoreLocation
import Network

class FavoritesViewController: UIViewController {
    //MARK: - Properties
    let inset:CGFloat = 15
    let cellsPerRow = 2
    var locations: [FavoriteLocation] = []
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var isCollectionLoaded = false

    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.view.backgroundColor = .systemBackground
        
        collectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.register(FavoriteLocationCell.self, forCellWithReuseIdentifier: "FavoriteCell")
            return collectionView
        }()


        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground

        view.addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        locations = CoreDataManager.shared.fetchLocationList()
        collectionView.reloadData()
        
        NetStatus.shared.netStatusChangeHandler = {
            if !self.isCollectionLoaded  {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
        
        // Notification if there was a change in CoreData
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
    }
    
    // Reload CollectionView with updated data from CoreData
    @objc func contextObjectsDidChange(_ notification: Notification) {
        locations = CoreDataManager.shared.fetchLocationList()
        collectionView.reloadData()
    }
}

//MARK: UICollectionView DataSource Methods
extension FavoritesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCell", for: indexPath) as! FavoriteLocationCell
        let favoriteLocation = locations[indexPath.row]
        let coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D (latitude: favoriteLocation .latitude, longitude: favoriteLocation .longitude)
        cell.coordinates = coordinates
        cell.cityName = favoriteLocation.name
        cell.countryName = favoriteLocation.country
        return cell
    }
}

//MARK: UICollectionView Delegate Methods
extension FavoritesViewController: UICollectionViewDelegate {
    // Go to DetailViewController after selecting cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.title = locations[indexPath.row].name
        vc.locationCoordinates = CLLocationCoordinate2D(latitude: locations[indexPath.row].latitude, longitude: locations[indexPath.row].longitude)
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: UICollectionView Layout Methods
extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGFloat((Float(view.frame.size.width) - Float(inset) * (Float(cellsPerRow) + 1)) / Float(cellsPerRow))
        return CGSize(width: size, height: size)
    }
}
