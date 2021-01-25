//
//  WeatherData.swift
//  assignment
//
//  Created by Martin Miklas on 24/01/2021.
//

import Foundation

struct WeatherData: Codable {
    let current: Current
    let daily: [Daily]
}

struct Current: Codable {
    let temp: Double
    let feels_like: Double
    let weather: [Weather]
}

struct Weather: Codable {
    let description: String
    let id: Int
}

struct Daily: Codable {
    let dt: Double
    let humidity: Int
    let temp: Temp
    let weather: [Weather]
}

struct Temp: Codable {
    let day: Double
}
