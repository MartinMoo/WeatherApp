//
//  FavoriteLocationCell.swift
//  assignment
//
//  Created by Martin Miklas on 26/01/2021.
//

import UIKit
import MapKit

class FavoriteLocationCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Set content to labels
    var coordinates: CLLocationCoordinate2D? {
        didSet {
            guard let coordinates = coordinates else {
                return
            }
            let zoomInKm: Double = 20
            let latitudeDelta =  (zoomInKm / 4) / 111 // Rough approximation to off-center map of location based on zoom level in latitude degrees (it's not a friend with device rotation)
            let placemark = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude) // Coordinates for reverese geocoding
            let location2D = CLLocationCoordinate2D(latitude: coordinates.latitude - latitudeDelta, longitude: coordinates.longitude) // Coordinates for mapView

            // Update labels and map with location names based on specified coordinates
            placemark.fetchCityAndCountry { city, country, error in
                guard let city = city, let country = country, error == nil else { return }
                self.cityLabel.text = city
                self.countryLabel.text = country
                self.zoomToLocation(centerCooridnate: location2D, zoomInKm: zoomInKm)
                UIView.animate(withDuration: 0.4) {
                    self.contentView.alpha = 1
                }
            }
        }
    }
    
    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isUserInteractionEnabled = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        return blurEffectView
    }()
    
    let cityLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let countryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let viewToBlur: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate func setupCellView() {
        contentView.addSubview(viewToBlur)
        contentView.addSubview(cityLabel)
        contentView.addSubview(countryLabel)
        
        viewToBlur.addSubview(mapView)
        viewToBlur.addSubview(blurView)
        
        contentView.clipsToBounds = true
        
        viewToBlur.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        viewToBlur.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        viewToBlur.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        viewToBlur.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        mapView.topAnchor.constraint(equalTo: viewToBlur.topAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: viewToBlur.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: viewToBlur.trailingAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: viewToBlur.bottomAnchor).isActive = true
        
        blurView.topAnchor.constraint(equalTo: cityLabel.topAnchor, constant: -6).isActive = true
        blurView.leadingAnchor.constraint(equalTo: viewToBlur.leadingAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: viewToBlur.trailingAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: viewToBlur.bottomAnchor).isActive = true
        
        cityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        cityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        cityLabel.bottomAnchor.constraint(equalTo: countryLabel.topAnchor,constant: -3).isActive = true
        
        countryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        countryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        countryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -6).isActive = true
        
        // Additional UI changes after main views are rendered and ready to be changed
        contentView.layoutIfNeeded()
        contentView.layer.cornerRadius = contentView.frame.size.height / 15
        
        // Set Cell to be hidden before filling it with content
        contentView.alpha = 0
    }
    
    // Zoom map view to specified coordinates
    fileprivate func zoomToLocation(centerCooridnate location: CLLocationCoordinate2D, zoomInKm radius: CLLocationDistance) {
        let span = radius * 2000
        let region: MKCoordinateRegion = MKCoordinateRegion(center: location, latitudinalMeters: span, longitudinalMeters: span)
        mapView.setRegion(region, animated: false)
    }
}

