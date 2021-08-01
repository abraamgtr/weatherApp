//
//  WeatherModel.swift
//  weather-app
//
//  Created by mohammad 141 on 8/30/20.
//  Copyright © 2020 mohammad 141. All rights reserved.
//

import Foundation
import UIKit

class weather {
    private let place: String!
    private let lat: String!
    private let long: String!
    private let main: String!
    private let temp:Float!
    private let pressure: Float!
    private let humidity: Float!
    private let windSpeed: Float!
    private let weatherImage:UIImage!
    private let weatherDescription: weatherImage!
    
    init(place: String, lat: String, long: String, main: String, temp: Float, humidity: Float,pressure: Float,windSpeed: Float, image: UIImage, weatherDescription: weatherImage) {
        self.place = place
        self.lat = lat
        self.long = long
        self.main = main
        self.temp = temp
        self.humidity = humidity
        self.pressure = pressure
        self.windSpeed = windSpeed
        self.weatherImage = image
        self.weatherDescription = weatherDescription
    }
    
    func getWeatherPlace() -> String {
        return self.place
    }
    
    func getWeatherLatitude() -> String {
        return self.lat
    }
    
    func getWeatherLongitude() -> String {
        return self.long
    }
    
    func getWeatherMainDesc() -> String {
        return self.main
    }
    
    func getWeatherTemp() -> Float {
        return self.temp
    }
    
    func  getWeatherHumidity() -> Float {
        return self.humidity
    }
    
    func  getWeatherPressure() -> Float {
        return self.pressure
    }
    
    func  getWindSpeed() -> Float {
        return self.windSpeed
    }
    
    func getWeatherImage() -> UIImage {
        return self.weatherImage
    }
    
    func getweatherDescription() -> weatherImage {
        return self.weatherDescription
    }
}
class forecastWeather {
    private let time: String!
    private let main: String!
    private let temp:Float!
    private let weatherImage:String!
    private let weatherDescription: String!
    private let weatherNetwork = DataModel()
    
    init(time: String, main: String, temp: Float, image: String, weatherDescription: String) {
        self.time = time
        self.main = main
        self.temp = temp
        self.weatherImage = image
        self.weatherDescription = weatherDescription
    }
    
    func getWeatherTime() -> Date {
        // convert string date to date
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from:self.time)!
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let finalDate = calendar.date(from:components)
        return finalDate!
    }
    
    func getFormattedTime() -> Date {
        // convert string date to date
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "HH:mm:ss"
        let date = dateFormatter.date(from:self.time)!
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let finalDate = calendar.date(from:components)
        return finalDate!
    }
    
    func getWeatherMainDesc() -> String {
        return self.main
    }
    
    func getWeatherTemp() -> Float {
        return self.temp
    }
    
    func getWeatherImage() -> String {
        return self.weatherImage
    }
    
    func getweatherDescription() -> String {
        return self.weatherDescription
    }
}
