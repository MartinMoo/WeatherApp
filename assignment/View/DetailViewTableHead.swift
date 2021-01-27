//
//  DetailViewTableHead.swift
//  assignment
//
//  Created by Martin Miklas on 25/01/2021.
//

import UIKit

class DetailViewTableHead: UIView {
    //MARK: - Properties
    // Set content to labels
    var currentWeather: CurrentWeather? {
        didSet {
            guard let data = currentWeather else {
                return
            }
            tempLabel.text = String(format: "%.1f", data.curTemperature) + "°C"
            weatherLabel.text = data.curDescription.capitalizingFirstLetter()
            feelTempLabel.text = Localize.Detail.FeelsLike + String(format: "%.1f", data.curFeelTemp) + "°C"
        }
    }
    
    let cellView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let tempLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 64, weight: .black)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let weatherLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let feelTempLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.Custom.gray
        label.font = UIFont.systemFont(ofSize: 16,weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Init
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        if frame == .zero {
            translatesAutoresizingMaskIntoConstraints = false
        }
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    //MARK: - Implementation
    fileprivate func setupView() {

        // Add subviews
        addSubview(cellView)
        cellView.addSubview(tempLabel)
        cellView.addSubview(weatherLabel)
        cellView.addSubview(feelTempLabel)

        // Set constraints
        cellView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        cellView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        cellView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        cellView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15).isActive = true
        
        tempLabel.topAnchor.constraint(equalTo: cellView.topAnchor).isActive = true
        tempLabel.bottomAnchor.constraint(equalTo: weatherLabel.topAnchor).isActive = true
        tempLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor).isActive = true
        tempLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor).isActive = true

        weatherLabel.bottomAnchor.constraint(equalTo: feelTempLabel.topAnchor).isActive = true
        weatherLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor).isActive = true
        weatherLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor).isActive = true

        feelTempLabel.bottomAnchor.constraint(equalTo: cellView.bottomAnchor,constant: -15).isActive = true
        feelTempLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor).isActive = true
        feelTempLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor).isActive = true
    }
}
