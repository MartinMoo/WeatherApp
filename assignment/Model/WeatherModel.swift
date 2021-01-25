//
//  WeatherModel.swift
//  assignment
//
//  Created by Martin Miklas on 24/01/2021.
//

import Foundation

struct WeatherModel {

    let curTemperature: Double
    let curFeelTemp: Double
    let curDescription: String
    
    var temperatureString: String {
        return String(format: "%.1f", curTemperature)
    }
    var feelTempString: String {
        return String(format: "%.1f", curFeelTemp)
    }
    let daily: [DailyModel]

//    var conditionName: String {
//        switch conditionId {
//        case 200...232:
//            return "cloud.bolt"
//        case 300...321:
//            return "cloud.drizzle"
//        case 500...531:
//            return "cloud.rain"
//        case 600...622:
//            return "cloud.snow"
//        case 701...781:
//            return "cloud.fog"
//        case 800:
//            return "sun.max"
//        case 801...804:
//            return "cloud.bolt"
//        default:
//            return "cloud"
//        }
//    }
}

struct DailyModel {
    let dailyDt: Double
    let dailyHumidity: Int
    let dailyTemp: Double
    let dailyId: Int
}
