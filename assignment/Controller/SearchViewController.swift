//
//  SearchViewController.swift
//  assignment
//
//  Created by Martin Miklas on 24/01/2021.
//

import UIKit
import MapKit

class SearchViewController: UITableViewController {
    //MARK: - Properties
    var matchingLocations: [MKMapItem] = []
    var mapView: MKMapView? = nil
    let noConnectionLabel = UILabel()
    let searchController = UISearchController(searchResultsController: nil)
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        // Register custom cell for table view
        self.tableView.register(SearchViewTableCell.self, forCellReuseIdentifier: "Cell")
        setupSearchController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name:UIResponder.keyboardWillShowNotification, object: nil);
    }
    
    //MARK: - Methods for UI
    fileprivate func setupSearchController() {
        // No connection Info label
        noConnectionLabel.textColor = UIColor.Custom.red
        noConnectionLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        noConnectionLabel.translatesAutoresizingMaskIntoConstraints = false
        noConnectionLabel.numberOfLines = 0
        noConnectionLabel.alpha = 0
        noConnectionLabel.isHidden = true
        noConnectionLabel.text = Localize.Alert.Net.NoConnection
        
        view.addSubview(noConnectionLabel)
        view.bringSubviewToFront(noConnectionLabel)
        
        noConnectionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 2).isActive = true
        noConnectionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        noConnectionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noConnectionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        noConnectionLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        
        // SearchController Setup
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = Localize.Search.Placeholder
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        
        // Search Bar UI Setup
        searchController.searchBar.sizeToFit()
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.tintColor = UIColor.Custom.purple
        searchController.searchBar.searchTextField.leftView?.tintColor = UIColor.Custom.purple
    }
    
    //MARK: - Keyboard lifecycle
    @objc func keyboardWillShow(sender: NSNotification) {
        if !NetStatus.shared.isConnected {
            showNoConnectionInfo()
        }
    }
    
    // Show info for no connection
    fileprivate func showNoConnectionInfo() {
        noConnectionLabel.isHidden = false

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.noConnectionLabel.alpha = 1
        } completion: { (true) in
            UIView.animate(withDuration: 0.4, delay: 3, options: .curveEaseOut) {
                self.noConnectionLabel.alpha = 0
            }
        }
    }
}

//MARK: - Search bar Methods
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        // Check if SearchBar text is empty
        guard let searchBarText = searchController.searchBar.text else {
            return
        }
        
        // If SearchBar text is not empty
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else {
                return
            }
            if !self.isSearchBarEmpty {
                self.matchingLocations = response.mapItems
                self.tableView.reloadData()
            }
        }
    }
}

// If searchBra empty, clear table view
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if isSearchBarEmpty {
            matchingLocations = []
            self.tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !NetStatus.shared.isConnected {
            showNoConnectionInfo()
        }
    }
}

//MARK: - TableViewController Methods
extension SearchViewController {
    
    // Number of rows in TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingLocations.count
    }

    // Cell for row in TableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let location = matchingLocations[indexPath.row].placemark
        let selectedLocation: Location? = Location(city: location.name!, country: location.country!)

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SearchViewTableCell
        cell.location = selectedLocation
        return cell
    }
    
    // Selected row in TableView
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        if let latitude = matchingLocations[indexPath.row].placemark.location?.coordinate.latitude, let longitude = matchingLocations[indexPath.row].placemark.location?.coordinate.longitude {
            let locationForCity = CLLocation(latitude: latitude, longitude: longitude)
            locationForCity.fetchCityAndCountry(completion: { (city, country, error) in
                guard let city = city, let country = country, error == nil else { return }
                vc.locationCity = city
                vc.locationCountry = country
            })
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            vc.locationCoordinates = coordinates
        }
        if !NetStatus.shared.isConnected {
            self.showNoConnectionInfo()
        } else {
            navigationController?.pushViewController(vc, animated: false)
        }
    }
}
