//
//  DetailViewTableCell.swift
//  assignment
//
//  Created by Martin Miklas on 25/01/2021.
//

import UIKit

class DetailViewTableCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Weather condition id code to SF Symbol name
    var conditionName: String {
        switch conditionId{
        case 200...232:
            return "cloud.bolt.fill"
        case 300...321:
            return "cloud.drizzle.fill"
        case 500...531:
            return "cloud.rain.fill"
        case 600...622:
            return "cloud.snow.fill"
        case 701...781:
            return "cloud.fog.fill"
        case 800:
            return "sun.max.fill"
        case 801...804:
            return "cloud.bolt.fill"
        default:
            return "sun.max.fill"
        }
    }
    var conditionId: Int = 0
    
    // Set content to labels and images
    var day: DailyModel? {
        didSet {
            guard let day = day else {
                return
            }
            conditionId = day.dailyId

            // Format NSDate to day of the week
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            let date = NSDate(timeIntervalSince1970: day.dailyDt)
            let dayName = formatter.string(from: date as Date)

            dayLabel.text = dayName
            humidityLabel.text = String(day.dailyHumidity) + "%"
            temperatureLabel.text = String(format: "%.1f", day.dailyTemp) + "°C"
            
            //TODO: Multicolor
            var image = UIImage(systemName: "sun.max.fill")
            if #available(iOS 14, *) { // For some reason multicolor symbols seems to not to work in UIKit
                image = UIImage(systemName: conditionName)?.withRenderingMode(.alwaysOriginal)
            } else {
                image = UIImage(systemName: conditionName)?.withTintColor(UIColor.Custom.blue!, renderingMode: .alwaysOriginal)
            }
            weatherIcon.image = image?.withAlignmentRectInsets(UIEdgeInsets(top: -5, left: -5, bottom: -5, right: -5))
        }
    }
    
    // Views init
    let cellView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let dayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 16,weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let middleView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let weatherIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let humidityLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.Custom.blue
        label.font = UIFont.systemFont(ofSize: 12,weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let temperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 12,weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate func setupCellView() {
        
        // Add subviews
        addSubview(cellView)
        cellView.addSubview(dayLabel)
        cellView.addSubview(middleView)
        cellView.addSubview(temperatureLabel)
        
        middleView.addSubview(weatherIcon)
        middleView.addSubview(humidityLabel)
        
        // Set constraints
        cellView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        cellView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        cellView.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 15).isActive = true
        cellView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15).isActive = true
        
        dayLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        dayLabel.centerYAnchor.constraint(equalTo: cellView.centerYAnchor).isActive = true
        dayLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor).isActive = true
        dayLabel.trailingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: -10).isActive = true
        
        middleView.centerYAnchor.constraint(equalTo: cellView.centerYAnchor).isActive = true
        middleView.centerXAnchor.constraint(equalTo: cellView.centerXAnchor).isActive = true
        middleView.trailingAnchor.constraint(lessThanOrEqualTo: temperatureLabel.leadingAnchor, constant: -10).isActive = true
        
        weatherIcon.widthAnchor.constraint(equalToConstant: 40).isActive = true
        weatherIcon.topAnchor.constraint(equalTo: middleView.topAnchor).isActive = true
        weatherIcon.bottomAnchor.constraint(equalTo: middleView.bottomAnchor).isActive = true
        weatherIcon.leadingAnchor.constraint(equalTo: middleView.leadingAnchor).isActive = true
        weatherIcon.trailingAnchor.constraint(equalTo: humidityLabel.leadingAnchor, constant: -10).isActive = true

        humidityLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        humidityLabel.centerYAnchor.constraint(equalTo: middleView.centerYAnchor).isActive = true
        humidityLabel.trailingAnchor.constraint(equalTo: middleView.trailingAnchor).isActive = true

        temperatureLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        temperatureLabel.centerYAnchor.constraint(equalTo: cellView.centerYAnchor).isActive = true
        temperatureLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: 0).isActive = true
        
        
        // Set content hugging and compression
        dayLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        middleView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        temperatureLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        dayLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        middleView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        temperatureLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
}
