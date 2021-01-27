//
//  DetailViewController.swift
//  assignment
//
//  Created by Martin Miklas on 23/01/2021.
//

import UIKit
import CoreLocation
import MapKit
import Network

class DetailViewController: UIViewController {
    //MARK: - Properties
    var locationCoordinates: CLLocationCoordinate2D?
    var locationName: String = ""
    var locationCountry: String = ""
    
    var latitude: Double = 0
    var longitude: Double = 0
    var weatherManager = WeatherManager()
    var addToFavorites = true

    var forecastDays: [DailyModel] = []

    let tableView = UITableView()
    let header = DetailViewTableHead(frame: CGRect.zero)
    let scrollView = UIScrollView()
    let noConnectionLabel = UILabel()
    let favoriteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16,weight: .semibold)
        return button
    }()
    
    //MARK: - Update Header and TableView
    var currentWeather: CurrentWeather? {
        didSet {
            if let data = currentWeather { // Pass updated data to Header view
                header.currentWeather = data
                UIView.animate(withDuration: 0.3) {
                    self.header.alpha = 1
                }
            }
        }
    }
    var weatherData: WeatherModel? {
        didSet {
            if let data = weatherData { // Pass updated data to TableView
                forecastDays = data.daily
                currentWeather = data.current
                UIView.animate(withDuration: 0.3, delay: 0.2) {
                    self.tableView.alpha = 1
                }
            }
        }
    }

    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        tableView.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false

        weatherManager.delegate = self

        self.tableView.register(DetailViewTableCell.self, forCellReuseIdentifier: "DetailCell")
        
        
        setupUI()
        checkCoordinatesAndUpdateUI()

        // Notification if there was a change in CoreData
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
        
        checkIfLocationExistInFavorites()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !NetStatus.shared.isConnected {
            showNoConnectionInfo()
        }
    }
     
    //MARK: - Methods for UI
    fileprivate func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        header.translatesAutoresizingMaskIntoConstraints = false
        
        noConnectionLabel.textColor = UIColor.Custom.red
        noConnectionLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        noConnectionLabel.translatesAutoresizingMaskIntoConstraints = false
        noConnectionLabel.numberOfLines = 0
        noConnectionLabel.alpha = 0
        noConnectionLabel.isHidden = true
        noConnectionLabel.text = Localize.Alert.Net.NoConnection

        header.alpha = 0
        tableView.alpha = 0
        
        view.addSubview(scrollView)
        scrollView.addSubview(header)
        scrollView.addSubview(tableView)
        scrollView.addSubview(favoriteButton)
        
        view.addSubview(noConnectionLabel)
        view.bringSubviewToFront(noConnectionLabel)
        
        noConnectionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        noConnectionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        noConnectionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noConnectionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        noConnectionLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        header.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        header.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        header.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        header.bottomAnchor.constraint(equalTo: tableView.topAnchor).isActive = true

        tableView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        tableView.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        tableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: favoriteButton.topAnchor,constant: -15).isActive = true
        
        favoriteButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor,constant: 15).isActive = true
        favoriteButton.trailingAnchor.constraint(lessThanOrEqualTo: scrollView.trailingAnchor, constant: 0).isActive = true
        favoriteButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -15).isActive = true
        
    }
    
    // Show info for no connection
    func showNoConnectionInfo() {
        noConnectionLabel.isHidden = false

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.noConnectionLabel.alpha = 1
        } completion: { (true) in
            UIView.animate(withDuration: 0.4, delay: 3, options: .curveEaseOut) {
                self.noConnectionLabel.alpha = 0
            }
        }
    }
    
    fileprivate func checkCoordinatesAndUpdateUI() {
        // Check Coordinates and update local coordinates and location name
        if let checkedLatitude = locationCoordinates?.latitude, let checkedLongitude = locationCoordinates?.longitude {
            latitude = checkedLatitude
            longitude = checkedLongitude
            let placemark = CLLocation(latitude: checkedLatitude, longitude: checkedLongitude)
            placemark.fetchCityAndCountry { (city, country, error) in
                guard let city = city, let country = country, error == nil else { return }
                self.locationName = city
                self.locationCountry = country
                self.title = self.locationName
            }
        }
        getWeatherData()
    }
    
    //TODO: Add Two Linees Large Title/ compact in navigationbar
    
    //MARK: - Methods for add/remove favorites locations to CoreData
    @objc func addLocationToCoreData(sender: UIButton) {
        CoreDataManager.shared.addLocation(name: locationName, country: locationCountry, longitude: longitude, latitude: latitude)
        checkIfLocationExistInFavorites()
    }
    
    @objc func removeLocationFromCoreData(sender: UIButton) {
        CoreDataManager.shared.deleteLocation(name: locationName, country: locationCountry, lat: latitude, long: longitude)
        checkIfLocationExistInFavorites()
    }
    
    fileprivate func checkIfLocationExistInFavorites() {
        if CoreDataManager.shared.locationExists(name: locationName, country: locationCountry, lat: latitude, long: longitude) {
            favoriteButton.setTitle(Localize.Detail.RemovesFromFavorites, for: .normal)
            favoriteButton.setTitleColor(UIColor.Custom.red, for: .normal)
            favoriteButton.addTarget(self, action: #selector(removeLocationFromCoreData), for: .touchUpInside)
        } else {
            favoriteButton.setTitle(Localize.Detail.AddToFavorites, for: .normal)
            favoriteButton.setTitleColor(UIColor.Custom.purple, for: .normal)
            favoriteButton.addTarget(self, action: #selector(addLocationToCoreData), for: .touchUpInside)
        }
    }
    
    // Update buttons for adding/removing location (If location removed in detail view from favorites/search)
    @objc func contextObjectsDidChange(_ notification: Notification) {
        checkIfLocationExistInFavorites()
    }
    

    //MARK: - Get weather data
    fileprivate func getWeatherData() {
        weatherManager.fetchWeather(latitude: latitude, longitude: longitude)
    }
}


// MARK: - UITableViewController Methods
extension DetailViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let day = forecastDays[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailViewTableCell
        cell.day = day
        return cell
    }
}

//MARK: - Weather Manager Delegate methods
// Update tableView with weather data
extension DetailViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.weatherData = weather
            self.tableView.reloadData()
        }
    }
    func didFailWithError(error: Error) {
        print(error)
    }
}
