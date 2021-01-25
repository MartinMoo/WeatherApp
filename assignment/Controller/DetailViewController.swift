//
//  DetailViewController.swift
//  assignment
//
//  Created by Martin Miklas on 22/01/2021.
//

import UIKit
import CoreLocation
import MapKit

class DetailViewController: UITableViewController {
    var selectedLocation = MKMapItem()
    var weatherManager = WeatherManager()
    
    var tempLabel = UILabel()
    var feelTempLabel = UILabel()
    var weatherLabel = UILabel()
    var currentWeatherView = UIView()
    
    var forecastDays: [DailyModel] = []
    var currentWeather: CurrentWeather?
    var weatherData: WeatherModel? {
        didSet {
            if let data = weatherData {
                forecastDays = data.daily
                currentWeather = data.current
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = .systemBackground
        tableView.backgroundColor = .systemBackground
        
        weatherManager.delegate = self
        getWeatherData()
        
        self.tableView.register(DetailViewTableHead.self, forHeaderFooterViewReuseIdentifier: "DetailHead")
        self.tableView.register(DetailViewTableCell.self, forCellReuseIdentifier: "DetailCell")
    }
    
    fileprivate func getWeatherData() {
        let lattitude = selectedLocation.placemark.location?.coordinate.latitude
        let longitude = selectedLocation.placemark.location?.coordinate.longitude
        weatherManager.fetchWeather(latitude: lattitude!, longitude: longitude!)
    }
    
//    fileprivate func setupNavbar() {
    //TODO: Two Linse Large Title in navigationbar?
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

    
    // MARK: - UITableViewController Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastDays.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let day = forecastDays[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailViewTableCell
        cell.day = day
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DetailHead") as! DetailViewTableHead
        header.currentWeather = currentWeather
        return header
    }
    
}

extension DetailViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
//            self.forecastDays = weather.daily
            self.weatherData = weather
            self.tableView.reloadData()
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
