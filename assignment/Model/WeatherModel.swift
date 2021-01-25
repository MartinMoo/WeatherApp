//
//  WeatherModel.swift
//  assignment
//
//  Created by Martin Miklas on 24/01/2021.
//

import Foundation

struct WeatherModel {
    let current: CurrentWeather
    let daily: [DailyModel]
}

struct CurrentWeather {
    let curTemperature: Double
    let curFeelTemp: Double
    let curDescription: String
}

struct DailyModel {
    let dailyDt: Double
    let dailyHumidity: Int
    let dailyTemp: Double
    let dailyId: Int
}
