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
    var weatherManager = WeatherManager()
    
    var tempLabel = UILabel()
    var feelTempLabel = UILabel()
    var weatherLabel = UILabel()
    var currentWeatherView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        navigationItem.largeTitleDisplayMode = .never
        weatherManager.delegate = self
        setupNavbar()
        setupUI()
        let lattitude = selectedLocation.placemark.location?.coordinate.latitude
        let longitude = selectedLocation.placemark.location?.coordinate.longitude
        weatherManager.fetchWeather(latitude: lattitude!, longitude: longitude!)
    }
    
    fileprivate func setupNavbar() {
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
        

    }
    
    fileprivate func setupUI() {
        
        currentWeatherView.backgroundColor = .clear
        currentWeatherView.translatesAutoresizingMaskIntoConstraints = false
        currentWeatherView.alpha = 0

        tempLabel.textColor = .label
        tempLabel.font = UIFont.systemFont(ofSize: 64, weight: .black)
        tempLabel.translatesAutoresizingMaskIntoConstraints = false

        weatherLabel.textColor = .label
        weatherLabel.font = UIFont.systemFont(ofSize: 32)
        weatherLabel.translatesAutoresizingMaskIntoConstraints = false

        feelTempLabel.textColor = UIColor.Custom.gray
        feelTempLabel.font = UIFont.systemFont(ofSize: 16,weight: .semibold)
        feelTempLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(currentWeatherView)
        currentWeatherView.addSubview(tempLabel)
        currentWeatherView.addSubview(weatherLabel)
        currentWeatherView.addSubview(feelTempLabel)
        
        // Add default content to generate intrinsic content size
        tempLabel.text = " "
        weatherLabel.text = " "
        feelTempLabel.text = " "
        
        currentWeatherView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        currentWeatherView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        currentWeatherView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        
        tempLabel.heightAnchor.constraint(equalToConstant: tempLabel.intrinsicContentSize.height).isActive = true
        tempLabel.topAnchor.constraint(equalTo: currentWeatherView.topAnchor).isActive = true
        tempLabel.bottomAnchor.constraint(equalTo: weatherLabel.topAnchor, constant: -5).isActive = true
        tempLabel.leadingAnchor.constraint(equalTo: currentWeatherView.leadingAnchor).isActive = true
        tempLabel.trailingAnchor.constraint(equalTo: currentWeatherView.trailingAnchor).isActive = true
        
        weatherLabel.heightAnchor.constraint(equalToConstant: weatherLabel.intrinsicContentSize.height).isActive = true
        weatherLabel.bottomAnchor.constraint(equalTo: feelTempLabel.topAnchor, constant: -5).isActive = true
        weatherLabel.leadingAnchor.constraint(equalTo: currentWeatherView.leadingAnchor).isActive = true
        weatherLabel.trailingAnchor.constraint(equalTo: currentWeatherView.trailingAnchor).isActive = true
        
        feelTempLabel.heightAnchor.constraint(equalToConstant: feelTempLabel.intrinsicContentSize.height).isActive = true
        feelTempLabel.bottomAnchor.constraint(equalTo: currentWeatherView.bottomAnchor).isActive = true
        feelTempLabel.leadingAnchor.constraint(equalTo: currentWeatherView.leadingAnchor).isActive = true
        feelTempLabel.trailingAnchor.constraint(equalTo: currentWeatherView.trailingAnchor).isActive = true
        
        //TODO: Make it a TableView under "normal" views, or make it a UITableController with custom head for current day and rows for forecast
    }
}

extension DetailViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.tempLabel.text = weather.temperatureString + "°C"
            self.weatherLabel.text = weather.curDescription.capitalizingFirstLetter()
            self.feelTempLabel.text = "Feels like " + weather.feelTempString + "°C"
            UIView.animate(withDuration: 0.5, delay: 0.2) {
                self.currentWeatherView.alpha = 1
            }
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
