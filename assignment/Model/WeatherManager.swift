//
//  WeatherManager.swift
//  assignment
//
//  Created by Martin Miklas on 24/01/2021.
//


import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/onecall?appid=ff554f01a90bb15acaa4b59c8e15462e&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
//    func fetchWeather(cityName: String) {
//        let urlString = "\(weatherURL)&q=\(cityName)"
//        performRequest(with: urlString)
//    }
    
    func fetchWeather(latitude: Double, longitude: Double) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)&exclude=minutely,hourly,alerts"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            
            // Data for current weather
            let temp = decodedData.current.temp
            let feelTemp = decodedData.current.feels_like
            let description = decodedData.current.weather[0].description
            
            // Data for weather forecast
            var daily: [DailyModel] = []
            var ignoreFirst = true
            for day in decodedData.daily {
                if ignoreFirst {
                    ignoreFirst = false
                } else {
                    let newDay = DailyModel(dailyDt: day.dt, dailyHumidity: day.humidity, dailyTemp: day.temp.day, dailyId: day.weather[0].id)
                    daily.append(newDay)
                }
            }
            
            let currentWeather: CurrentWeather = CurrentWeather(curTemperature: temp, curFeelTemp: feelTemp, curDescription: description)

            // Feed return data to weather model
            let weather = WeatherModel(current: currentWeather, daily: daily)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
