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
    var coordinates: Coordinates? {
        didSet {
            guard let coordinates = coordinates else {
                return
            }
            let placemark = CLLocation(latitude: coordinates.lat, longitude: coordinates.long)
            placemark.fetchCityAndCountry { city, country, error in
                guard let city = city, let country = country, error == nil else { return }
                self.cityLabel.text = city
                self.countryLabel.text = country
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
        label.text = "Cii"
        return label
    }()
    
    let countryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hoo"
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
    }
    
}
