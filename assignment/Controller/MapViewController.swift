//
//  MapViewController.swift
//  assignment
//
//  Created by Martin Miklas on 22/01/2021.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    let mapView = MKMapView()
    let zoomLevel: Double = 5000 // in meters: 5000  = 5x5km map zoom
    var currentMapType: MKMapType = .standard {
        didSet {
            mapView.mapType = currentMapType
        }
    }
    
    private let locationService = LocationService()
    private let locationManager = CLLocationManager()

    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        locationService.delegate = self
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //MARK: - UI Methods
    func setupUI() { // Boilerplate, no UIView extensions...

        let mapNavigationContainer: UIView = {
            let view = UIView()
            view.backgroundColor = .systemBackground
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        let mapTypeContainer: UIView = {
            let view = UIView()
            view.backgroundColor = .clear
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        let mapTypeSegmentedControl: UISegmentedControl = {
            let sc = UISegmentedControl(items: ["Standard","Satellite"])
            sc.selectedSegmentIndex = 0
            sc.translatesAutoresizingMaskIntoConstraints = false
            sc.addTarget(self, action: #selector(segmentedControlAction), for: .valueChanged)
            return sc
        }()
        
        let currentPositionButton: UIButton = {
            let button = UIButton()
            button.setImage(UIImage(systemName: "location")?.withTintColor(UIColor.Custom.purple!, renderingMode: .alwaysOriginal), for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(didTapLocationAction), for: .touchDown)
            return button
        }()
        
        let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
        longPress.addTarget(self, action: #selector(didAddAnnotation))
        mapView.addGestureRecognizer(longPress)
        
        view.backgroundColor = .systemBackground
        view.addSubview(mapView)
        view.addSubview(mapNavigationContainer)
        mapNavigationContainer.addSubview(mapTypeContainer)
        mapNavigationContainer.addSubview(currentPositionButton)
        mapTypeContainer.addSubview(mapTypeSegmentedControl)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        mapView.bottomAnchor.constraint(equalTo: mapNavigationContainer.topAnchor, constant: 0).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        
        mapNavigationContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        mapNavigationContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        mapNavigationContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        mapNavigationContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        mapTypeContainer.topAnchor.constraint(equalTo: mapNavigationContainer.topAnchor).isActive = true
        mapTypeContainer.bottomAnchor.constraint(equalTo: mapNavigationContainer.bottomAnchor).isActive = true
        mapTypeContainer.leadingAnchor.constraint(equalTo: mapNavigationContainer.leadingAnchor, constant: 10).isActive = true
        mapTypeContainer.trailingAnchor.constraint(equalTo: currentPositionButton.leadingAnchor, constant: -10).isActive = true
        
        mapTypeSegmentedControl.centerYAnchor.constraint(equalTo: mapTypeContainer.centerYAnchor).isActive = true
        mapTypeSegmentedControl.leadingAnchor.constraint(equalTo: mapTypeContainer.leadingAnchor).isActive = true
        let scTrailing = mapTypeSegmentedControl.trailingAnchor.constraint(greaterThanOrEqualTo: mapTypeContainer.trailingAnchor)
        scTrailing.priority = UILayoutPriority(999)
        scTrailing.isActive = true
        let scWidth = mapTypeSegmentedControl.widthAnchor.constraint(lessThanOrEqualToConstant: 350)
        scWidth.priority = UILayoutPriority(999)
        scWidth.isActive = true

        currentPositionButton.topAnchor.constraint(equalTo: mapNavigationContainer.topAnchor, constant: 5).isActive = true
        currentPositionButton.bottomAnchor.constraint(equalTo: mapNavigationContainer.bottomAnchor, constant: -5).isActive = true
        currentPositionButton.trailingAnchor.constraint(equalTo: mapNavigationContainer.trailingAnchor, constant: -10).isActive = true
        currentPositionButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        currentPositionButton.layoutIfNeeded()
        currentPositionButton.layer.cornerRadius = currentPositionButton.frame.size.width / 2
        
    }
    
    //MARK: - Button Actions Methods
    // Switch map style
    @objc fileprivate func segmentedControlAction(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentMapType = .standard
        case 1:
            currentMapType = .satellite
        default:
            currentMapType = .standard
        }
    }
    
    // Animate Center to User location button and call zoom to location method
    @objc fileprivate func didTapLocationAction(sender: UIButton) {
        sender.backgroundColor = .tertiarySystemBackground
        sender.layoutIfNeeded()
        UIView.animate(withDuration: 0.3) {
            sender.backgroundColor = .systemBackground
        }
        switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                presentLocationPermissionAlert()
            case .denied:
                presentLocationPermissionAlert()
            case .authorizedAlways, .authorizedWhenInUse:
                centerToUserLocation()
                locationService.locationManager.startUpdatingLocation()
            default:
                break
        }

    }
    
    @objc fileprivate func didAddAnnotation(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizer.State.began {
            return
        }
        
        // Get coordinates of the point
        let pressedLocation = sender.location(in: mapView)
        
        // Convert location co CLocationCoordinate2D
        let pressedCoordinates: CLLocationCoordinate2D = mapView.convert(pressedLocation, toCoordinateFrom: mapView)
        
        // Init pin
        let marker: MKPointAnnotation = MKPointAnnotation()
        marker.title = "Pin"
        
        marker.coordinate = pressedCoordinates
        mapView.addAnnotation(marker)
    }
    
    //MARK: - Map Methods
    // Zoom to user location
    private func centerToUserLocation() {
        let mapRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: zoomLevel, longitudinalMeters: zoomLevel)
        mapView.setRegion(mapRegion, animated: true)
    }
    
    fileprivate func presentLocationPermissionAlert() {
        // Alert for denied location permision
        let locationAlert: UIAlertController = {
            let alertController = UIAlertController(title: "Location Authorization", message: "GoodWeather needs location authorization to display user location. Please update location permission in your Privacy settings.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            let updateSettingsAction = UIAlertAction(title: "Update Settings", style: .default) { (_) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            
            alertController.addAction(okAction)
            alertController.addAction(updateSettingsAction)
            
            return alertController
        }()
        
        self.present(locationAlert, animated: true, completion: nil)
    }
}



// MARK: - Location Service Delegate
extension MapViewController: LocationServiceDelegate {
    
    // Zoom to user location
    func setMapRegion(center: CLLocation) {
        let mapRegion = MKCoordinateRegion(center: center.coordinate, latitudinalMeters: zoomLevel, longitudinalMeters: zoomLevel)
        DispatchQueue.main.async { [weak self] in
            self?.mapView.setRegion(mapRegion, animated: true)
        }
    }
    
    func authorizationDenied() {
        DispatchQueue.main.async { [weak self] in
            if self != nil  {
                self?.presentLocationPermissionAlert()
            }
        }
    }
}


extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let vc = DetailViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
}
