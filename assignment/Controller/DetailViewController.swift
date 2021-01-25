//
//  DetailViewController.swift
//  assignment
//
//  Created by Martin Miklas on 22/01/2021.
//

import UIKit
import CoreLocation
import MapKit

class DetailViewController: UIViewController {
    var selectedLocation = MKMapItem()
    var latitude: Double = 0
    var longitude: Double = 0
    var weatherManager = WeatherManager()
    var addToFavorites = true

    var forecastDays: [DailyModel] = []
    
    var currentWeather: CurrentWeather? {
        didSet {
            if let data = currentWeather { // Pass updated data to header view
                header.currentWeather = data
                UIView.animate(withDuration: 0.3) {
                    self.header.alpha = 1
                }
            }
        }
    }
    var weatherData: WeatherModel? {
        didSet {
            if let data = weatherData { // Pass updated data to tableView
                forecastDays = data.daily
                currentWeather = data.current
                UIView.animate(withDuration: 0.3, delay: 0.2) {
                    self.tableView.alpha = 1
                    self.favoriteButton.alpha = 1
                }
            }
        }
    }
    
    let tableView = UITableView()
    let header = DetailViewTableHead(frame: CGRect.zero)
    let scrollView = UIScrollView()
    let favoriteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16,weight: .semibold)
        return button
    }()

    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        latitude = (selectedLocation.placemark.location?.coordinate.latitude)!
        longitude = (selectedLocation.placemark.location?.coordinate.longitude)!

        self.view.backgroundColor = .systemBackground
        tableView.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false

        weatherManager.delegate = self
        getWeatherData()
        
        self.tableView.register(DetailViewTableCell.self, forCellReuseIdentifier: "DetailCell")
        
        setupUI()
    }
    
    
    //MARK: - Methods for UI
    fileprivate func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        header.translatesAutoresizingMaskIntoConstraints = false

        header.alpha = 0
        tableView.alpha = 0
        favoriteButton.alpha = 0
        
        view.addSubview(scrollView)
        scrollView.addSubview(header)
        scrollView.addSubview(tableView)
        scrollView.addSubview(favoriteButton)
        
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
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
        
        if addToFavorites == true {
            favoriteButton.setTitleColor(UIColor.Custom.purple, for: .normal)
            favoriteButton.setTitle("Add to favorites", for: .normal)
            favoriteButton.addTarget(self, action: #selector(addLocationToCoreData), for: .touchUpInside)
        } else {
            favoriteButton.setTitleColor(UIColor.Custom.red, for: .normal)
            favoriteButton.setTitle("Remove from favorites", for: .normal)
            favoriteButton.addTarget(self, action: #selector(removeLocationFromCoreData), for: .touchUpInside)
        }
    }
    
    @objc func addLocationToCoreData(sender: UIButton) {
        print("Add")
        CoreDataManager.shared.addLocation(name: selectedLocation.name!, longitude: longitude, latitude: latitude)
    }
    
    @objc func removeLocationFromCoreData(sender: UIButton) {
        print("Remove") 
    }
    

    //MARK: - Get weather data
    fileprivate func getWeatherData() {
        weatherManager.fetchWeather(latitude: latitude, longitude: longitude)
    }
    
//    fileprivate func setupNavbar() {
    //TODO: Add Two Linees Large Title/ compact in navigationbar
//        let dateLabel: UILabel = {
//            let label = UILabel()
//            label.textColor = UIColor.Custom.gray
//            label.font = UIFont.systemFont(ofSize: 16)
//            label.translatesAutoresizingMaskIntoConstraints = false
//            return label
//        }()
//        let cityLabel: UILabel = {
//            let label = UILabel()
//            label.textColor = .label
//            label.font = UIFont.systemFont(ofSize: 16)
//            label.translatesAutoresizingMaskIntoConstraints = false
//            return label
//        }()
//
//        let titleView: UIView = {
//            let view = UIView()
//            return view
//        }()
//
//        titleView.addSubview(dateLabel)
//        titleView.addSubview(cityLabel)
//        let backImage = UIImage(systemName: "arrow.left.circle.fill")?.withTintColor(UIColor.Custom.purple!, renderingMode: .alwaysOriginal)
//        UINavigationBar.appearance().tintColor = UIColor.Custom.purple
//        UINavigationBar.appearance().backIndicatorImage = backImage
//        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImage

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
