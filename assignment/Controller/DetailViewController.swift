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
    var locationCity: String = ""
    var locationCountry: String = ""
    var dataLoaded = false
    
    var latitude: Double = 0
    var longitude: Double = 0
    var weatherManager = WeatherManager()
    var addToFavorites = true

    var forecastDays: [DailyModel] = []

    let tableView = UITableView()
    var spinnerView = UIActivityIndicatorView()
    let header = DetailViewTableHead(frame: CGRect.zero)
    let scrollView = UIScrollView()
    let noConnectionLabel = UILabel()
    let favoriteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16,weight: .semibold)
        return button
    }()
    
    // Navbar Titles
    let largeTitle = UILabel()
    let smallTitle = UILabel()
    var titleText = NSMutableAttributedString()
    var smallTitleText = NSAttributedString()
    private var navBarObserver: NSKeyValueObservation?
    var date = ""
    
    //MARK: - Update Header and TableView
    var currentWeather: CurrentWeather? {
        didSet {
            dataLoaded = true
            self.removeSpinner()
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

        // get the current date and time
        let currentDateTime = Date()

        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium

        // get the date time String from the date object
        date = formatter.string(from: currentDateTime)

        self.view.backgroundColor = .systemBackground
        tableView.backgroundColor = .systemBackground

        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false

        weatherManager.delegate = self

        self.tableView.register(DetailViewTableCell.self, forCellReuseIdentifier: "DetailCell")
        
        checkCoordinatesAndUpdateUI()
        setupUI()

        // Notification if there was a change in CoreData
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
        
        checkIfLocationExistInFavorites()
        
        NetStatus.shared.netStatusChangeHandler = {
            if !NetStatus.shared.isConnected {
                self.showNoConnectionInfo()
            } else {
                self.hideNoConnectionInfo()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !NetStatus.shared.isConnected {
            showNoConnectionInfo()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

            // Landscape
            if size.width > size.height {
                self.smallTitle.attributedText = smallTitleText
            } else { // Portrait
                self.smallTitle.attributedText = titleText
            }
            self.view.layoutIfNeeded()
    }
     
    //MARK: - Methods for UI
    private func setupUI() {
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
        
        scrollView.alwaysBounceVertical = true
        
    }
    
    private func updateStrings() {
        titleText = NSMutableAttributedString()
        titleText.append(NSAttributedString(string: date + "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold), NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel]))

        titleText.append(NSAttributedString(string: locationCity, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold), NSAttributedString.Key.foregroundColor: UIColor.label]))
        
        smallTitleText = NSAttributedString(string: date + " " + locationCity)
    }
    
    private func setupNavBar() {
        updateStrings()

        largeTitle.translatesAutoresizingMaskIntoConstraints = false
        largeTitle.attributedText = self.titleText

        // Set small Title
        smallTitle.backgroundColor = .clear
        smallTitle.numberOfLines = 2
        smallTitle.font = UIFont.systemFont(ofSize: 14)
        smallTitle.textAlignment = .center
        smallTitle.textColor = .label
        smallTitle.attributedText = titleText
        smallTitle.translatesAutoresizingMaskIntoConstraints = false
        self.navigationItem.titleView = smallTitle


        // Small title for landscape
        if isLandscape() {
            self.smallTitle.frame.size.width = view.frame.size.height - 90
            self.smallTitle.attributedText = smallTitleText
        }
    }
    
    private func isLandscape() -> Bool {
        if self.view.frame.size.width > self.view.frame.size.height {
            return true
        }
        return false
    }
    
    private func showSpinner() {
        if !dataLoaded {
            spinnerView.style = .large
            spinnerView.translatesAutoresizingMaskIntoConstraints = false
            spinnerView.hidesWhenStopped = true
            spinnerView.startAnimating()

            self.scrollView.addSubview(spinnerView)

            spinnerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 140).isActive = true
            spinnerView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        }
    }
    
    private func removeSpinner() {
        spinnerView.stopAnimating()
    }
    
    // Show info if no internet connection
    private func showNoConnectionInfo() {
        DispatchQueue.main.async {
            self.removeSpinner()
            self.noConnectionLabel.isHidden = false
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
                self.noConnectionLabel.alpha = 1
            }
        }
    }
    
    // Show info if no internet connection
    private func hideNoConnectionInfo() {
        DispatchQueue.main.async {
            self.noConnectionLabel.isHidden = false
            self.getWeatherData()
            UIView.animate(withDuration: 0.3) {
                self.noConnectionLabel.alpha = 0
            } completion: { (true) in
                self.noConnectionLabel.isHidden = true
            }
        }
    }
    
    private func checkCoordinatesAndUpdateUI() {
        // Check Coordinates and update local coordinates and location name
        if let checkedLatitude = locationCoordinates?.latitude, let checkedLongitude = locationCoordinates?.longitude {
            latitude = checkedLatitude
            longitude = checkedLongitude
            let placemark = CLLocation(latitude: checkedLatitude, longitude: checkedLongitude)
            placemark.fetchCityAndCountry { (city, country, error) in
                guard let city = city, let country = country, error == nil else { return }
                self.locationCity = city
                self.locationCountry = country
                self.setupNavBar()
                self.checkIfLocationExistInFavorites()
            }
        }
        getWeatherData()
    }
    
    //MARK: - Methods for add/remove favorites locations to CoreData
    @objc func addLocationToCoreData(sender: UIButton) {
        CoreDataManager.shared.addLocation(name: locationCity, country: locationCountry, longitude: longitude, latitude: latitude)
        checkIfLocationExistInFavorites()
    }
    
    @objc func removeLocationFromCoreData(sender: UIButton) {
        CoreDataManager.shared.deleteLocation( lat: latitude, long: longitude)
        checkIfLocationExistInFavorites()
    }
    
    private func checkIfLocationExistInFavorites() {

        if CoreDataManager.shared.locationExists(lat: latitude, long: longitude) {
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
    private func getWeatherData() {
        if NetStatus.shared.isConnected {
            self.showSpinner()
            weatherManager.fetchWeather(latitude: latitude, longitude: longitude)
        }
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
