//
//  LocationService.swift
//  assignment
//
//  Created by Martin Miklas on 22/01/2021.
//

import CoreLocation

protocol LocationServiceDelegate: class {
    func authorizationDenied()
    func setMapRegion(center: CLLocation)
}

class LocationService: NSObject {
    var locationManager = CLLocationManager()
    weak var delegate: LocationServiceDelegate?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkAuthorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                locationManager.requestAlwaysAuthorization()
            case .denied:
                delegate?.authorizationDenied()
            case .authorizedAlways, .authorizedWhenInUse:
                startUpdatingLocation()
            default:
                break
        }
    }
    
    private func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    // Check if location permission is granted
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkAuthorizationStatus()
    }


    // User location updated, stop updating and parse location data to delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if let location = locations.last {
            delegate?.setMapRegion(center: location)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
