//
//  MapViewController.swift
//  assignment
//
//  Created by Martin Miklas on 22/01/2021.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    //MARK: - Properties
    let mapView = MKMapView()
    let noConnectionLabel = UILabel()
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
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        locationService.delegate = self
        
        setupUI()
        populateMapWithAnnotation()
        
        // Notification if there was a change in CoreData
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
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
    func setupUI() {

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
            let sc = UISegmentedControl(items: [Localize.Map.Standard,Localize.Map.Satellite])
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
        
        noConnectionLabel.textColor = UIColor.Custom.red
        noConnectionLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        noConnectionLabel.translatesAutoresizingMaskIntoConstraints = false
        noConnectionLabel.numberOfLines = 0
        noConnectionLabel.alpha = 0
        noConnectionLabel.isHidden = true
        noConnectionLabel.text = Localize.Alert.Net.NoConnection
        
        // Gesture Recognizer for adding markers on map
        let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
        longPress.addTarget(self, action: #selector(didAddAnnotation))
        mapView.addGestureRecognizer(longPress)
        
        view.backgroundColor = .systemBackground
        view.addSubview(mapView)
        view.addSubview(noConnectionLabel)
        view.addSubview(mapNavigationContainer)
        mapNavigationContainer.addSubview(mapTypeContainer)
        mapNavigationContainer.addSubview(currentPositionButton)
        mapTypeContainer.addSubview(mapTypeSegmentedControl)
        
        noConnectionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        noConnectionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        noConnectionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noConnectionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        noConnectionLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        
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
        
        // Check if Location Service is authorized
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
        
        sender.backgroundColor = .tertiarySystemBackground
        sender.layoutIfNeeded()
        UIView.animate(withDuration: 0.3) {
            sender.backgroundColor = .systemBackground
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

        // Place Annotation on map
        mapView.addAnnotation(createAnnotation(latitude: pressedCoordinates.latitude, longitude: pressedCoordinates.longitude))
    }
    
    //MARK: - Map Methods
    // Zoom to user location
    fileprivate func centerToUserLocation() {
        let mapRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: zoomLevel, longitudinalMeters: zoomLevel)
        mapView.setRegion(mapRegion, animated: true)
    }
    
    fileprivate func presentLocationPermissionAlert() {
        // Alert for denied location permision
        let locationAlert: UIAlertController = {
            let alertController = UIAlertController(title: Localize.Alert.Location.Title, message: Localize.Alert.Location.Message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: Localize.Alert.Ok, style: .default, handler: nil)
            let updateSettingsAction = UIAlertAction(title: Localize.Alert.UpdateSettings, style: .default) { (_) in
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
    
    // Add Favorite locations to map
    fileprivate func populateMapWithAnnotation() {
        // Clear old annotations
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        
        // Get list of favorite locations from CoreData
        let favoriteLocations = CoreDataManager.shared.fetchLocationList()
        
        for location in favoriteLocations {
            // Place Annotation on map
            mapView.addAnnotation(createAnnotation(latitude: location.latitude, longitude: location.longitude))
        }
    }
    
    fileprivate func createAnnotation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> MKPointAnnotation {
        // Convert location co CLLocationCoordinate2D
        let locationCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let locationForCity = CLLocation(latitude: latitude, longitude: longitude)
        
        // Init pin
        let marker: MKPointAnnotation = MKPointAnnotation()
        locationForCity.fetchCity(completion: { (city, error) in
            guard let city = city, error == nil else { return }
            marker.title = city
        })
        
        marker.coordinate = locationCoordinates
        return marker
    }
    
    // Update favorite annotations on map
    @objc func contextObjectsDidChange(_ notification: Notification) {
        populateMapWithAnnotation()
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
    // Annotation Selected, push DetailViewController
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let vc = DetailViewController()
        
        // Get coordinates from annotation and pass it to next viewController
        vc.locationCoordinates = view.annotation?.coordinate
        if NetStatus.shared.isConnected {
            navigationController?.pushViewController(vc, animated: true)
        } else {
            showNoConnectionInfo()
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {}

