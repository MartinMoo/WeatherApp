//
//  FavoritesViewController.swift
//  assignment
//
//  Created by Martin Miklas on 22/01/2021.
//

import UIKit

class FavoritesViewController: UIViewController {
    let inset:CGFloat = 15
    let cellsPerRow = 2
    var locations: [FavoriteLocation] = []
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locations = CoreDataManager.shared.fetchLocationList()
        collectionView.reloadData()
    }
    

}

//MARK: UICollectionView DataSource Methods
extension FavoritesViewController: UICollectionViewDataSource, UICollectionViewDelegate  {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCell", for: indexPath) as! FavoriteLocationCell
        let coordinates = Coordinates(lat: locations[indexPath.row].latitude, long: locations[indexPath.row].longitude)
        cell.coordinates = coordinates
        return cell
    }
}

//MARK: UICollectionView Layout Methods
extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGFloat((Float(view.frame.size.width) - Float(inset) * (Float(cellsPerRow) + 1)) / Float(cellsPerRow))
        return CGSize(width: size, height: size)
    }
    
}
