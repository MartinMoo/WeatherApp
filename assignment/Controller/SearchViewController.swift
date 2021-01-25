//
//  SearchViewController.swift
//  assignment
//
//  Created by Martin Miklas on 24/01/2021.
//

import UIKit
import MapKit

class SearchViewController: UITableViewController {
    var matchingLocations: [MKMapItem] = []
    var mapView: MKMapView? = nil
    let searchController = UISearchController(searchResultsController: nil)
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Register custom cell for table view
        self.tableView.register(SearchViewTableCell.self, forCellReuseIdentifier: "Cell")
        setupSearchController()
    }
    
    //MARK: - Methods for UI
    func setupSearchController() {
        // SearchController Setup
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        
        // Search Bar UI Setup
        searchController.searchBar.sizeToFit()
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.tintColor = UIColor.Custom.purple
        searchController.searchBar.searchTextField.leftView?.tintColor = UIColor.Custom.purple
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
        vc.selectedLocation = matchingLocations[indexPath.row]
        vc.title = matchingLocations[indexPath.row].name
        vc.view.backgroundColor = .systemBackground
        searchController.searchBar.resignFirstResponder()
        navigationController?.pushViewController(vc, animated: true)
    }
}
